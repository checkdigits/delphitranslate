unit modules.envclass;
interface
uses
  System.Classes;

type
  { TEnvironmentSettings: Class to hold environment/application settings for WebStencils }
  TEnvironmentSettings = class(TPersistent)
  private
    FAppVersion: string;
    FAppName: string;
    FAppEdition: string;
    FCompanyName: string;
    FResource: string;
    FDebugMode: Boolean;
    FIsRadServer: Boolean;
  public
    constructor Create;
  published
    property AppVersion: string read FAppVersion;
    property AppName: string read FAppName;
    property AppEdition: string read FAppEdition;
    property CompanyName: string read FCompanyName;
    property Resource: string read FResource; // Required for RAD Server compatibility
    property DebugMode: Boolean read FDebugMode;
    property IsRadServer: Boolean read FIsRadServer;
  end;

implementation
{ TEnvironmentSettings }

constructor TEnvironmentSettings.Create;
begin
  inherited Create;
  // Initialize properties
  FAppVersion := '2025.6.16.1';
  FAppName := 'Delphi Translate';
  FCompanyName := 'Embarcadero Technologies Inc.';
  // This RESOURCE env is required to make the WebStencils templates reusable for RAD Server
  FResource := '';
{$IFDEF DEBUG}
  FDebugMode := True;
{$ELSE}
  FDebugMode := False;
{$ENDIF}
  FIsRadServer := False;
end;

end.