unit PusherServer;

interface

uses
  ComObj,
  System.Generics.Collections,
  System.Threading,
  System.Classes,
  SysUtils,
  System.SyncObjs;

type
  TOptions = set of (UseSSL);

  TPusherServer = class
  private
    PusherServerNative: OleVariant;
  public
    constructor Create(AppID, AppKey, AppSecret: string; CustomHost: string = '';
      Options: TOptions = [UseSSL]); virtual;
    procedure Trigger(Channel, EventName, Message: string); virtual;
  end;

  TOnErrorEvent = reference to procedure(Error: Exception);
  TAsyncPusherServer = class
  private
    FAppID: string;
    FAppKey: string;
    FAppSecret: string;
    FCustomHost: string;
    FOptions: TOptions;
    FOnError: TOnErrorEvent;
    procedure NotifyError(Error: Exception);
    procedure HandleError(Error: Exception);
    function WithErrorHandling(Proc: TProc): TProc;
    procedure ExecTrigger(Channel, EventName, Message: string);
  public
    property OnError: TOnErrorEvent  read FOnError write FOnError;
    constructor Create(AppID, AppKey, AppSecret: string; CustomHost: string = '';
      Options: TOptions = [UseSSL]);
    destructor Destroy; override;
    procedure Trigger(Channel, EventName, Message: string);
  end;

implementation

uses
  Winapi.ActiveX;

{ TPusherServer }

constructor TPusherServer.Create(AppID, AppKey, AppSecret, CustomHost: string; Options: TOptions);
begin
  CoInitialize(nil);
  PusherServerNative := CreateOleObject('PusherServerNative.Pusher');
  PusherServerNative.InitializePusherServer(AppID, AppKey, AppSecret, CustomHost, UseSSL in Options);
end;

procedure TPusherServer.Trigger(Channel, EventName, Message: string);
begin
  PusherServerNative.Trigger(Channel, EventName, Message);
end;

{ TAsyncPusherServer }

constructor TAsyncPusherServer.Create(AppID, AppKey, AppSecret,
  CustomHost: string; Options: TOptions);
begin
  FAppID := AppID;
  FAppKey := AppKey;
  FAppSecret := AppSecret;
  FCustomHost :=  CustomHost;
  FOptions := Options;
end;

destructor TAsyncPusherServer.Destroy;
begin
  FOnError := nil;
  CoUninitialize;
  inherited;
end;

procedure TAsyncPusherServer.ExecTrigger(Channel, EventName, Message: string);
var
  PusherServer: TPusherServer;
begin
  PusherServer := TPusherServer.Create(FAppID, FAppKey, FAppSecret, FCustomHost, FOptions);
  try
    PusherServer.Trigger(Channel, EventName, Message);
  finally
    PusherServer.Free;
  end;
end;

procedure TAsyncPusherServer.HandleError(Error: Exception);
begin
  TThread.Synchronize(nil, procedure
    begin
      try NotifyError(Error); except end;
    end);
end;

procedure TAsyncPusherServer.NotifyError(Error: Exception);
begin
  if Assigned(FOnError) then
    FOnError(Error);
end;

procedure TAsyncPusherServer.Trigger(Channel, EventName, Message: string);
begin
  TTask.Run(WithErrorHandling(procedure
    begin
      ExecTrigger(Channel, EventName, Message);
    end));
end;

function TAsyncPusherServer.WithErrorHandling(Proc: TProc): TProc;
begin
  Result := procedure
  begin
    try
      Proc();
    except
      on E:Exception do
        HandleError(E);
    end;
  end;
end;

end.
