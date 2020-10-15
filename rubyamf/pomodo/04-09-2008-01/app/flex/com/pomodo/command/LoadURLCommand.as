package com.pomodo.command {
    import com.adobe.cairngorm.commands.ICommand;
    import com.adobe.cairngorm.control.CairngormEvent;
    import flash.net.navigateToURL;
    import flash.net.URLRequest;
    
    public class LoadURLCommand implements ICommand {
        public function LoadURLCommand() {
        }

        public function execute(event:CairngormEvent):void {
            var request:URLRequest = new URLRequest(event.data);
            try {
                navigateToURL(request, "_top");
            }
            catch (e:Error) {
                // handle error here
            }
        }
    }
}
