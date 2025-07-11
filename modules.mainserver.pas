unit modules.mainserver;

interface

uses
  System.SysUtils, System.Classes, Web.HTTPApp, Web.Stencils
  , modules.envclass   // used to provide some @ENV functionality in the WebStencils templates
  , modules.translator // Does the actual work of accessing the AWS Translate service
  , System.DateUtils
  ;

type
  TWebModule1 = class(TWebModule)
    WebStencilsEngine: TWebStencilsEngine;
    WebFileDispatcher: TWebFileDispatcher;
    WebStencilsProcessor1: TWebStencilsProcessor;
    procedure WebModuleCreate(Sender: TObject);
    procedure WebModuleDestroy(Sender: TObject);
    procedure WebStencilsEngineValue(Sender: TObject; const AObjectName, APropName: string; var AReplaceText: string; var AHandled: Boolean);
    procedure WebModule1TranslateTextActionAction(Sender: TObject; Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
    procedure WebModule1SwapActionAction(Sender: TObject; Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
    procedure WebModule1SetNewLangActionAction(Sender: TObject; Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
    procedure WebStencilsEngineFile(Sender: TObject;
      const AFilename: string; var AText: string; var AHandled: Boolean);
    procedure WebStencilsEnginePathInit(Sender: TObject;
      const ARequest: TWebPostProcessorRequest);
  private
    FEnvironmentSettings: TEnvironmentSettings;
    FResourcesPath: string;
    FIsSwapped: boolean;
    FTranslator: ITranslationManager;
    FLanguages: TLanguageList;
    FTimer: TDateTime;
    procedure Init;
    function ReturnLanguageTable: string;
  end;

var
  WebModuleClass: TComponentClass = TWebModule1;

implementation
uses
  System.IOUtils,
  FMX.Types,
  modules.consts;

{%CLASSGROUP 'System.Classes.TPersistent'}

{$R *.dfm}

procedure TWebModule1.Init;
begin
  // Set the path for resources based on the platform and build configuration
  var BinaryPath := TPath.GetDirectoryName(ParamStr(0));
{$IFDEF MSWINDOWS}
  FResourcesPath := TPath.Combine(BinaryPath, '../../');
{$ELSE}
  FResourcesPath := BinaryPath;
{$ENDIF}
  WebStencilsEngine.RootDirectory := TPath.Combine(FResourcesPath, 'html');
  WebFileDispatcher.RootDirectory := WebStencilsEngine.RootDirectory;
  FEnvironmentSettings            := TEnvironmentSettings.Create;

  // Make the TEnvironmentSettings class automatically available to the webpages
  WebStencilsEngine.AddVar('env', FEnvironmentSettings);

  // Start off with the plain and translated text boxes unswapped
  FIsSwapped := False;

  // Initialize the translation workhorse
  FTranslator := TTranslationManager.Create;

  FLanguages := TLanguageList.GetInstance;
  FLanguages.SetLanguages(FTranslator.AvailableLanguages);
  WebStencilsEngine.AddVar('Translator', FLanguages);
end;

function TWebModule1.ReturnLanguageTable: string;
const
  cMaxLangsPerLine = 10;
begin
{
  This returns a HTML which looks like this:

			<div>
			  <ul class="navbar-nav me-auto mb-2 mb-lg-0">
					<li class="nav-item">
					  <a id="detected" name="detected" class="nav-link active text-primary" aria-current="page" href="#">%%% LANG GOES HERE %%%</a>
					</li>
					<li class="nav-item dropdown">
					  <a class="nav-link dropdown-toggle" href="#" role="button" data-bs-toggle="dropdown" aria-expanded="false">
						&nbsp;
					  </a>
					  <ul class="dropdown-menu">
              <table class="table" name="langtable" id="langtable">
                <tbody>
                  <tr class="nav-auto">
                  <td class="clickable"><label id="langauto" hx-get="/setnewlang?lang=auto" hx-params="*" hx-trigger="click">Auto</label></td>
                  <td class="clickable"><label id="langen" hx-get="/setnewlang?lang=en" hx-params="*" hx-trigger="click">English</label></td>
                  <td class="clickable"><label id="langfr" hx-get="/setnewlang?lang=fr" hx-params="*" hx-trigger="click">French</label></td>
                  etc...
                  </tr>
                  <tr class="nav-auto">
                  <td class="clickable"><label id="langge" hx-get="/setnewlang?lang=ge" hx-params="*" hx-trigger="click">German</label></td>
                  <td class="clickable"><label id="langde" hx-get="/setnewlang?lang=de" hx-params="*" hx-trigger="click">Danish</label></td>
                  etc...
                  </tr>
                </tbody>
              </table>
			      </ul>
			     </li>
				</div>

}

  Result := cLangBlockPart1 + cDetectedDiv + FTranslator.SourceLanguageName + '</div></a>' + sLineBreak;
  Result := Result + cLangBlockPart2 + sLineBreak;

  Result := Result + '<table class="table" name="langtable" id="langtable"><tbody>';
  var LCnt: integer := 0;
  var LLeft, LRight, LActive: string;
  for var LCode in FLanguages.Languages do
  begin
    if LCnt = 0 then
      Result := Result + '<tr class="nav-item">';
    // For the active language we put a HTML entity check mark against it...
    if LCode.LanguageCode.Equals(FTranslator.SourceLanguageCode) then
      LActive := '&nbsp;&check;'
    else
      LActive := '';
    Result := Result + '<td class="clickable"><label id="lang'
                     + LCode.LanguageCode
                     + '" hx-get="/setnewlang?lang='
                     + LCode.LanguageCode
                     + '" hx-params="*" hx-trigger="click" hx-target="#langblock" hx-swap="outerHTML" >'
                     + LCode.LanguageName
                     + LActive
                     + '</label></td>'
                     + sLineBreak;
    Inc(LCnt);
    if LCnt = cMaxLangsPerLine then
    begin
      Result := Result + '</tr>';
      LCnt := 0;
    end;
  end;
  if LCnt > 0 then Result := Result + '</tr>' + sLineBreak;  // finish uneven row
  Result := Result + '</tbody></table>' + sLineBreak;
  Result := Result + '</ul></li></div>' + sLineBreak;
end;

procedure TWebModule1.WebModule1SetNewLangActionAction(Sender: TObject; Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
begin
  // This method gets called when the user clicks on one of the available languages in the language dropdown
  // It sets the new source language and triggers the translate action so that any text in the "original text" box
  // is translated to the newly selected destination language
  // setnewlang
  Handled := True;
  var LLang: string := Request.ContentFields.Values['lang'];
  if LLang.IsEmpty then  // if no language code parameter then set it to whatever it was before
    LLang := FTranslator.SourceLanguageCode;
  FTranslator.SourceLanguageCode := LLang;
  Response.Content := ReturnLanguageTable;
  Handled := True;
end;

procedure TWebModule1.WebModule1SwapActionAction(Sender: TObject; Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
begin
  //
  // This method swaps the original and translated content boxes around by using an HTMX field
  //
  // It is more 'correct' and extensible to actually do this by choosing alternate
  // external templates rather than using this hard-coded constants, but I wanted to
  // show the flexibility of the WebStencils engine and that it's TRUE Delphi
  // power behind it.

  // If there is already something in the text area, we preserve it when we
  // swap the content
  var LOGContent: string := Request.ContentFields.Values['ogcontent'];
  var LTranslatedContent: string := Request.ContentFields.Values['transcontent'];

  if FIsSwapped then
    Response.Content := Format(cLangNormal, [LOGContent, LTranslatedContent])
  else
    Response.Content := Format(cLangSwapped, [LTranslatedContent, LOGContent]);
  FIsSwapped := not FIsSwapped;
  Handled := True;
end;

procedure TWebModule1.WebModule1TranslateTextActionAction(Sender: TObject; Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
begin
  // This routine gets called when the "translate" button is clicked - either manually, by the user, or
  // virtually thanks to them pasting some text into the original content box
  var LString: string := Request.ContentFields.Values['ogcontent'];
  var LTranslatedString: string := FTranslator.TranslateString(LString);
  // The handlePaste event gets detached when we use hx-swap - so this DIV prefix forces it to reattach
  Response.Content := '<div hx-swap-oob="innerHTML:#detectedlang" hx-on:htmx:after-swap="handlePaste();">' + FTranslator.DetectedLanguageName + '</div>' + LTranslatedString;
  Handled := True;
end;

procedure TWebModule1.WebModuleCreate(Sender: TObject);
begin
  inherited;
  FTimer := Now; // Default the timer to when then app starts
  Init;
end;

procedure TWebModule1.WebModuleDestroy(Sender: TObject);
begin
  FreeAndNil(FEnvironmentSettings);
  inherited;
end;

procedure TWebModule1.WebStencilsEngineFile(Sender: TObject; const AFilename: string; var AText: string; var AHandled: Boolean);
begin
  if SameText('languagetable.html', AFilename) then
  begin
    AText := ReturnLanguageTable;
    AHandled := True;
  end;
end;

procedure TWebModule1.WebStencilsEnginePathInit(Sender: TObject; const ARequest: TWebPostProcessorRequest);
begin
  if SameText(ARequest.OriginalPath, '/') then
    FTimer := Now;
end;

procedure TWebModule1.WebStencilsEngineValue(Sender: TObject;
                                             const AObjectName, APropName: string;
                                             var AReplaceText: string;
                                             var AHandled: Boolean);
begin
  // Some special custom values we expose manually
  if SameText(AObjectName, 'system') then
  begin
    if SameText(APropName, 'timestamp') then // @system.timestamp in the template
      AReplaceText := FormatDateTime('yyyy-mm-dd hh:nn:ss', Now)
    else if SameText(APropName, 'year') then // @system.year in the template
      AReplaceText := FormatDateTime('yyyy', Now)
    else if SameText(APropName, 'timer') then // @system.timer in the template - for diagnostics
      AReplaceText := Format('%.4f', [SecondSpan(Now, FTimer)])
    else if SameText(APropName, 'timerreset') then // @system.timerreset in the template - resets it to zero
      FTimer := Now
    else
      AReplaceText := Format('SYSTEM_%s_NOT_FOUND', [APropName.ToUpper]); // oops, invalid system.something
    AHandled := True;
  end;
end;

end.
