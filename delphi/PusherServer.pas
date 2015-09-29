unit PusherServer;

interface

uses
  ComObj,
  System.Generics.Collections,
  System.Threading,
  System.Classes,
  SysUtils;

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
  TAsyncPusherServer = class(TPusherServer)
  private
    FOnError: TOnErrorEvent;
    FLock: TObject;
    function WithLock(Proc: TProc): TProc;
    procedure WithErrorHandling(Proc: TProc);
  public
    property OnError: TOnErrorEvent  read FOnError write FOnError;
    constructor Create(AppID, AppKey, AppSecret: string; CustomHost: string = '';
      Options: TOptions = [UseSSL]); override;
    destructor Destroy; override;
    procedure Trigger(Channel, EventName, Message: string); override;
  end;

implementation

{ TPusherServer }

constructor TPusherServer.Create(AppID, AppKey, AppSecret, CustomHost: string; Options: TOptions);
begin
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
  inherited;
  FLock := TObject.Create;
end;

destructor TAsyncPusherServer.Destroy;
begin
  TMonitor.Wait(FLock, INFINITE);
  FLock.Free;
  inherited;
end;

procedure TAsyncPusherServer.Trigger(Channel, EventName, Message: string);
begin
  TTask.Run(WithLock(procedure
    begin
      inherited;
    end));
end;

function TAsyncPusherServer.WithLock(Proc: TProc): TProc;
begin
  Result := procedure
    begin
      try
        TMonitor.Enter(FLock);
        WithErrorHandling(Proc);
      finally
        TMonitor.Exit(FLock);
      end;
    end;
end;

procedure TAsyncPusherServer.WithErrorHandling(Proc: TProc);
begin
  try
    Proc;
  except
    on E:Exception do
    begin
      if Assigned(FOnError) then
        FOnError(E);
    end;
  end;
end;

end.
