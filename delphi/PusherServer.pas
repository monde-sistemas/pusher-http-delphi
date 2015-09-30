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
  TAsyncPusherServer = class(TPusherServer)
  private
    FTaskList: TArray<ITask>;
    FOnError: TOnErrorEvent;
    FLock: TCriticalSection;
    function WithLock(Proc: TProc): TProc;
    procedure WithErrorHandling(Proc: TProc);
    procedure AddToTaskList(Task: ITask);
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

procedure TAsyncPusherServer.AddToTaskList(Task: ITask);
begin
  SetLength(FTaskList, Length(FTaskList) +1);
  FTaskList[High(FTaskList)] := Task;
end;

constructor TAsyncPusherServer.Create(AppID, AppKey, AppSecret,
  CustomHost: string; Options: TOptions);
begin
  inherited;
  FLock := TCriticalSection.Create;
end;

destructor TAsyncPusherServer.Destroy;
begin
  TTask.WaitForAll(FTaskList);
  FLock.Free;
  inherited;
end;

procedure TAsyncPusherServer.Trigger(Channel, EventName, Message: string);
begin
  AddToTaskList(TTask.Run(WithLock(procedure
    begin
      inherited;
    end)));
end;

function TAsyncPusherServer.WithLock(Proc: TProc): TProc;
begin
  Result := procedure
    begin
      FLock.Acquire;
      try
        WithErrorHandling(Proc);
      finally
        FLock.Release;
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
