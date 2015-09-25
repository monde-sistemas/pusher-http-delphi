unit PusherServer;

interface

uses
  ComObj;

type
  TOptions = set of (UseSSL);

  TPusherServer = class
  private
    PusherServerNative: OleVariant;
  public
    constructor Create(AppID, AppKey, AppSecret: string; CustomHost: string = '';
      Options: TOptions = [UseSSL]);
    procedure Trigger(Channel, EventName, Message: string);
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

end.
