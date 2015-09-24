using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using PusherServer;
using System.Runtime.InteropServices;

namespace PusherServerNative
{
    [ClassInterface(ClassInterfaceType.None)]
    [ComVisible(true), GuidAttribute("E1426309-4938-4A69-A5B9-0C5EF0577F64")]
    public class Pusher
    {
        static PusherServer.Pusher pusherServer = null;

        public void InitializePusherServer(string appId, string appKey, string appSecret, string customHost, bool useSSL = false)
        {
            var options = new PusherOptions();
            options.Encrypted = useSSL;
            if ((customHost != null) && (customHost != ""))
                options.HostName = customHost;

            pusherServer = new PusherServer.Pusher(appId, appKey, appSecret, options);
        }

        public void Trigger(string channel, string eventName, string message)
        {
            pusherServer.Trigger(channel, eventName, message);
        }
    }
}
