# Pusher Delphi Server Library

This is a Delphi library for interacting with the Pusher HTTP API.

Register at http://pusher.com and use the application credentials within your app as shown below.

More general documentation can be found at http://pusher.com/docs/.

This library is based on [Pusher .NET HTTP library](https://github.com/pusher/pusher-http-dotnet) and uses the .NET lib as a DLL (see dotnet folder), so, this lib depends on .NET 4.5.

Looking for a client library? Take a look at [pusher-websocket-delphi](https://github.com/monde-sistemas/pusher-websocket-delphi)

## Limitations

So far this lib only supports trigger messages to public channels. The .net library has support to privates and presence channels, webhooks, etc, so, we only need to write the wrappers.

## Dependencies

* RestSharp.dll
* PusherServer.dll
* PusherServerNative.dll

All of them are shipped with this lib releases.

## Usage

Download the [last release](https://github.com/monde-sistemas/pusher-http-delphi/releases/) zip package and add it to your project. Make sure all the dependencies are on the same folder that your exe.

Add `PusherServer` to your unit uses clause.

```
PusherServer := TPusherServer.Create('app_id', 'app_key', 'secret');
PusherServer.Trigger('my-channel', 'my-event', 'my-message');
```

### Custom Host Address

It is possible to use a custom host address:
```
TPusherServer.Create('app_id', 'app_key', 'secret', 'you_host.pusher.com');
```
The default value is `api.pusherapp.com` which is the pusher.com http endpoint, but you can also use it with a [poxa](https://github.com/edgurgel/poxa) server hosted in your own server.

### Secure Connections / SSL

SSL is enabled by default. You can disable it by passing a empty option list `[]` to the constructor:
```
TPusherServer.Create('app_id', 'app_key', 'secret', '', []);
```

## Contributing

This lib is a work in progress and any help is greatly appreciated.

Found a bug? Send us a Pull Request or create an issue, we will do our best to help.
