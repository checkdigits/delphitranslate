unit modules.translator;

interface
uses
  System.Classes,
  System.SysUtils,
  System.Generics.Collections,
  System.SyncObjs,
  AWS.Translate;     // Does the actual work of accessing the AWS Translate service;

type

  ITranslationManager = interface(IInterface)
  ['{72804F92-804C-4FE7-94D8-FCF6E47BD119}']

    procedure SetAvailableLanguages(const Value: TDictionary<string, string>);
    procedure SetDetectedLanguageCode(const Value: string);
    procedure SetSourceLanguageCode(const Value: string);
    procedure SetTargetLanguageCode(const Value: string);
    procedure SetTranslationSuccessful(const Value: Boolean);

    function GetAvailableLanguages: TDictionary<string, string>;
    function GetDetectedLanguageCode: string;
    function GetDetectedLanguageName: string;
    function GetSourceLanguageCode: string;
    function GetTargetLanguageCode: string;
    function GetSourceLanguageName: string;
    function GetTargetLanguageName: string;
    function GetTranslationSuccessful: Boolean;

    function TranslateString(const OriginalText: string): string;
    property SourceLanguageCode: string                      read GetSourceLanguageCode    write SetSourceLanguageCode;
    property SourceLanguageName: string                      read GetSourceLanguageName;
    property DetectedLanguageCode: string                    read GetDetectedLanguageCode  write SetDetectedLanguageCode;
    property DetectedLanguageName: string                    read GetDetectedLanguageName;
    property TargetLanguageCode: string                      read GetTargetLanguageCode    write SetTargetLanguageCode;
    property TargetLanguageName: string                      read GetTargetLanguageName;
    property AvailableLanguages: TDictionary<string, string> read GetAvailableLanguages    write SetAvailableLanguages;
    property TranslationSuccessful: boolean                  read GetTranslationSuccessful write SetTranslationSuccessful;
    function LanguageNameFromCode(const LanguageCode: string): string;
    function LanguageCodeFromName(const LanguageName: string): string;
    function GetAutoLanguageCode: string;
    function GetAutoLanguageName: string;
  end;

  TTranslationManager = class(TInterfacedObject, ITranslationManager)
  private
    FDetectedLanguageCode: string;
    FSourceLanguageCode: string;
    FTargetLanguageCode: string;
    FAvailableLanguages: TDictionary<string, string>;
    FClient: ITranslateClient;
    FTranslationSuccessful: boolean;
    procedure SetAvailableLanguages(const Value: TDictionary<string, string>);
    procedure SetDetectedLanguageCode(const Value: string);
    procedure SetSourceLanguageCode(const Value: string);
    procedure SetTargetLanguageCode(const Value: string);
    procedure SetTranslationSuccessful(const Value: Boolean);
    function GetAvailableLanguages: TDictionary<string, string>;
    function GetDetectedLanguageCode: string;
    function GetDetectedLanguageName: string;
    function GetSourceLanguageCode: string;
    function GetSourceLanguageName: string;
    function GetTargetLanguageCode: string;
    function GetTargetLanguageName: string;
    function GetTranslationSuccessful: Boolean;
    procedure UpdateAvailableLanguages;
  public
    constructor Create;
    destructor Destroy; override;
    function TranslateString(const OriginalText: string): string;
    property SourceLanguageCode: string                      read GetSourceLanguageCode    write SetSourceLanguageCode;
    property SourceLanguageName: string                      read GetSourceLanguageName;
    property DetectedLanguageCode: string                    read GetDetectedLanguageCode  write SetDetectedLanguageCode;
    property DetectedLanguageName: string                    read GetDetectedLanguageName;
    property TargetLanguageName: string                      read GetTargetLanguageName;
    property TargetLanguageCode: string                      read GetTargetLanguageCode    write SetTargetLanguageCode;
    property AvailableLanguages: TDictionary<string, string> read GetAvailableLanguages    write SetAvailableLanguages;
    property TranslationSuccessful: boolean                  read GetTranslationSuccessful write SetTranslationSuccessful;
    function LanguageNameFromCode(const LanguageCode: string): string;
    function LanguageCodeFromName(const LanguageName: string): string;
    function GetAutoLanguageCode: string;
    function GetAutoLanguageName: string;
  end;

  TLanguage = class
  private
    FLanguageCode: string;
    FLanguageName: string;
  public
    property LanguageCode: string read FLanguageCode write FLanguageCode;
    property LanguageName: string read FLanguageName write FLanguageName;
  end;

  TLanguageList = class
  private
    class var FInstance: TLanguageList;
    class var FLock: TCriticalSection;
    FItems: TObjectList<TLanguage>;
    constructor Create;
    function GetLanguages: TObjectList<TLanguage>;
  public
    class constructor ClassCreate;
    class destructor ClassDestroy;
    destructor Destroy; override;
    class function GetInstance: TLanguageList;
    property Languages: TObjectList<TLanguage> read GetLanguages;
    procedure SetLanguages(ALanguageList: TDictionary<string, string>);
  end;


implementation

const
  cTransAuto = 'auto';
  cTransAutoName = 'Automatic';
  cTransDefault = 'en';
  cTransUnknownLanguageCode = 'Unknown language code';
  cTransUnknownLanguageName = 'Unknown language name';

{ TTranslationManager }

constructor TTranslationManager.Create;
begin
  FAvailableLanguages := TDictionary<string, string>.Create;
  FSourceLanguageCode := cTransAuto;    // try to work out the original text's language
  FTargetLanguageCode := cTransDefault; // Assume they want to translate into English

  // Initialize the AWS translation subsystem
  FClient := TTranslateClient.Create;
  UpdateAvailableLanguages;
end;

destructor TTranslationManager.Destroy;
begin
  FreeAndNil(FAvailableLanguages);
  inherited;
end;

function TTranslationManager.GetAutoLanguageCode: string;
begin
  Result := cTransAuto;
end;

function TTranslationManager.GetAutoLanguageName: string;
begin
  Result := cTransAutoName;
end;

function TTranslationManager.GetAvailableLanguages: TDictionary<string, string>;
begin
  Result := FAvailableLanguages;
end;

function TTranslationManager.GetDetectedLanguageCode: string;
begin
  Result := FDetectedLanguageCode;
end;

function TTranslationManager.GetDetectedLanguageName: string;
begin
  Result := LanguageNameFromCode(FDetectedLanguageCode);
end;

function TTranslationManager.GetSourceLanguageCode: string;
begin
  Result := FSourceLanguageCode;
end;

function TTranslationManager.GetSourceLanguageName: string;
begin
  Result := LanguageNameFromCode(FSourceLanguageCode);
end;

function TTranslationManager.GetTargetLanguageCode: string;
begin
  Result := FTargetLanguageCode;
end;

function TTranslationManager.GetTargetLanguageName: string;
begin
  Result := LanguageNameFromCode(FTargetLanguageCode);
end;

function TTranslationManager.GetTranslationSuccessful: Boolean;
begin
  Result := FTranslationSuccessful;
end;

function TTranslationManager.LanguageCodeFromName(const LanguageName: string): string;
begin
  if FAvailableLanguages.Count = 0 then UpdateAvailableLanguages;
  if SameText(LanguageName, cTransAutoName) then
    Result := cTransAuto
  else
    if FAvailableLanguages.ContainsKey(LanguageName) then
       FAvailableLanguages.TryGetValue(LanguageName, Result)
    else
      Result := cTransUnknownLanguageName + ': ' + LanguageName;
end;

function TTranslationManager.LanguageNameFromCode(const LanguageCode: string): string;
begin
  if FAvailableLanguages.Count = 0 then UpdateAvailableLanguages;
  if SameText(LanguageCode, cTransAuto) then
    Result := cTransAutoName
  else
    if FAvailableLanguages.ContainsKey(LanguageCode) then
      Result := FAvailableLanguages.Items[LanguageCode]
    else
      Result := cTransUnknownLanguageCode + ': ' + LanguageCode;
end;

procedure TTranslationManager.SetAvailableLanguages(const Value: TDictionary<string, string>);
begin
  FAvailableLanguages := Value;
end;

procedure TTranslationManager.SetDetectedLanguageCode(const Value: string);
begin
  FDetectedLanguageCode := Value;
end;

procedure TTranslationManager.SetSourceLanguageCode(const Value: string);
begin
  FSourceLanguageCode := Value;
end;

procedure TTranslationManager.SetTargetLanguageCode(const Value: string);
begin
  FTargetLanguageCode := Value;
end;

procedure TTranslationManager.SetTranslationSuccessful(const Value: Boolean);
begin
  FTranslationSuccessful := Value;
end;

function TTranslationManager.TranslateString(const OriginalText: string): string;
var
  LRequest: ITranslateTranslateTextRequest;
  LResponse: ITranslateTranslateTextResponse;
begin
  LRequest := TTranslateTranslateTextRequest.Create(FSourceLanguageCode, FTargetLanguageCode, OriginalText);
  LResponse := FClient.TranslateText(LRequest);
  FTranslationSuccessful := LResponse.IsSuccessful;
  if FTranslationSuccessful then
    begin
      if FSourceLanguageCode.Equals(cTransAuto) then
        FDetectedLanguageCode := LResponse.SourceLanguageCode;
      Result := LResponse.TranslatedText;
    end
  else // if it failed, set the result to be the original text
    Result := OriginalText;
end;

procedure TTranslationManager.UpdateAvailableLanguages;
var
  LResponse: ITranslateListLanguagesResponse;
  LLanguage: ITranslateLanguage;
begin
  FAvailableLanguages.Clear;
  LResponse := FClient.ListLanguages;
  if LResponse.IsSuccessful then
    for LLanguage in LResponse.Languages do
      FAvailableLanguages.Add(LLanguage.LanguageCode, LLanguage.LanguageName);
end;

{ TLanguageList }

class constructor TLanguageList.ClassCreate;
begin
  FLock := TCriticalSection.Create;
end;

class destructor TLanguageList.ClassDestroy;
begin
  FInstance.Free;
  FLock.Free;
end;

constructor TLanguageList.Create;
begin
  inherited;
  FItems := TObjectList<TLanguage>.Create(True);
end;

destructor TLanguageList.Destroy;
begin
  inherited;
end;

class function TLanguageList.GetInstance: TLanguageList;
begin
  if not Assigned(FInstance) then
  begin
    FLock.Acquire;
    try
      FInstance := TLanguageList.Create;
    finally
      FLock.Release;
    end;
  end;
  Result := FInstance;
end;

function TLanguageList.GetLanguages: TObjectList<TLanguage>;
begin
  Result := FItems;
end;

procedure TLanguageList.SetLanguages(ALanguageList: TDictionary<string, string>);
var
  LLanguage: TLanguage;
  LTmp:      TOrderedDictionary<string, string>;

  procedure AddLangPair(const PKey, PValue: string);
  begin
    LLanguage := TLanguage.Create;
    LLanguage.LanguageCode := PKey;
    LLanguage.LanguageName := PValue;
    FItems.Add(LLanguage);
  end;

begin
  // The list arrives as an unordered/unsorted list of languages - we'd like it in
  // alphabetical order - so we sort it by the "value" property which is equal
  // to the language name, for example "French"
  FItems.Clear;
  LTmp := TOrderedDictionary<string, string>.Create;
  try
    for var TheLanguages in ALanguageList do
      LTmp.Add(TheLanguages.Key, TheLanguages.Value);
    LTmp.SortByValues;

    // We want "auto" at the start of the list, so we put it in manually
    // and then skip it if it appears in the list passed to us...
    AddLangPair(cTransAuto, cTransAutoName);
    for var TheLanguages in LTmp do
    begin
      LLanguage := TLanguage.Create;
      if not SameText(TheLanguages.Key, cTransAuto) then
        AddLangPair(TheLanguages.Key, TheLanguages.Value);
    end;
  finally
    FreeAndNil(LTmp);
  end;
end;

end.
