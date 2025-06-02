unit modules.mainserver;

interface

uses
  System.SysUtils, System.Classes, Web.HTTPApp, Web.Stencils,
  modules.envclass, AWS.Translate;

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
  private
    FEnvironmentSettings: TEnvironmentSettings;
    FClient: ITranslateClient;
    FResourcesPath: string;
    FIsSwapped: boolean;
    procedure Init;
    function DoTranslate(const OriginalText: string): string;
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

function TWebModule1.DoTranslate(const OriginalText: string): string;
var
  LRequest: ITranslateTranslateTextRequest;
  LResponse: ITranslateTranslateTextResponse;
begin
  LRequest := TTranslateTranslateTextRequest.Create('auto', 'en', OriginalText);
  LResponse := FClient.TranslateText(LRequest);
  if LResponse.IsSuccessful then
  begin
//    if SourceLanguageCode.Equals('auto') then
//      DetectedLanguageCode := LResponse.SourceLanguageCode;
//    Result := LResponse.TranslatedText + '<br />Source: ' + LResponse.SourceLanguageCode + '<br />Target: ' + LResponse.TargetLanguageCode;
    Result := LResponse.TranslatedText;
  end;end;

procedure TWebModule1.Init;
var
  LResources: string;
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

  // Initialize the AWS translation string
  FClient := TTranslateClient.Create;
end;

procedure TWebModule1.WebModule1SwapActionAction(Sender: TObject; Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
begin
  //
  // This function swaps the original and translated content boxes around by using an HTMX field
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
  // vortually thanks to them pasting some text into the original content box
  var LString: string := Request.ContentFields.Values['ogcontent'];
  Response.Content := DoTranslate(LString);
  Handled := True;
end;

procedure TWebModule1.WebModuleCreate(Sender: TObject);
begin
  inherited;
  Init;
end;

procedure TWebModule1.WebModuleDestroy(Sender: TObject);
begin
  FreeAndNil(FEnvironmentSettings);
  inherited;
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
    else
      AReplaceText := Format('SYSTEM_%s_NOT_FOUND', [APropName.ToUpper]); // oops, invalid system.something
  AHandled := True;
  end;
end;

end.
