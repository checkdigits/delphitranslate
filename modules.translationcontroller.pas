unit modules.translationcontroller;
interface

uses
  System.SysUtils,
  System.IOutils,
  Web.HTTPApp,
  Web.Stencils;

type

  TTranslationController = class
  private
    FWebStencilsProcessor: TWebStencilsProcessor;
    FWebStencilsEngine: TWebStencilsEngine;
    function RenderTemplate(ATemplate: string): string;
    procedure AddRouting;
  public
    procedure TranslateText(Sender: TObject; Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
    constructor Create(AWebStencilsEngine: TWebStencilsEngine);
    destructor Destroy; override;
  end;

implementation

function TTranslationController.RenderTemplate(ATemplate: string): string;
begin
  FWebStencilsProcessor.InputFileName := TPath.Combine(FWebStencilsEngine.rootDirectory, 'customers/' + ATemplate + '.html');
  Result := FWebStencilsProcessor.Content;
end;

procedure TTranslationController.AddRouting;
begin
//  AddRoutes([TRoute.Create(mtDelete, '/tasks', FTasksController.DeleteTask),
//    TRoute.Create(mtPost, '/tasks/add', FTasksController.CreateTask),
//    TRoute.Create(mtGet, '/tasks/edit', FTasksController.GetEditTask),
//    TRoute.Create(mtPut, '/tasks/toggleCompleted', FTasksController.TogglecompletedTask),
//    TRoute.Create(mtPut, '/tasks', FTasksController.EditTask),
//    // Customers routes
//    TRoute.Create(mtGet, '/bigtable', FCustomersController.GetAllCustomers),
//    TRoute.Create(mtGet, '/pagination', FCustomersController.GetCustomers)
//    ]);
end;

constructor TTranslationController.Create(AWebStencilsEngine: TWebStencilsEngine);
begin
  inherited Create;
  try
    FWebStencilsEngine           := AWebStencilsEngine;
    FWebStencilsProcessor        := TWebStencilsProcessor.Create(nil);
    FWebStencilsProcessor.Engine := FWebStencilsEngine;
  except
    on E: Exception do
      WriteLn('TTranslationController.Create: ' + E.Message);
  end;
end;

destructor TTranslationController.Destroy;
begin
  FWebStencilsProcessor.Free;
  inherited;
end;

procedure TTranslationController.TranslateText(Sender: TObject; Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
begin
  Response.Content := RenderTemplate('bigtable');
  Handled := True;
end;

end.

