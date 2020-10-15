package com.bigfix.dss.view.fileio {
    import flash.events.*;
    import flash.net.FileReference;
    import flash.net.URLRequest;
    
    import mx.controls.Button;
    import mx.controls.ProgressBar;
    import mx.core.UIComponent;
    import com.bigfix.dss.event.FileDownloadCompleteEvent;
    import com.bigfix.dss.view.fileio.events.FileDownloadDialogClosedEvent;

    public class FileDownload extends UIComponent {
        // Hard-code the URL of file to download to user's computer.
        private const DOWNLOAD_URL:String = "http://www.yourdomain.com/file_to_download.zip";
        private var fr:FileReference;
        // Define reference to the download ProgressBar component.
        private var pb:ProgressBar;
        // Define reference to the "Cancel" button which will immediately stop the download in progress.
        private var btn:Button;

        private var _request:URLRequest;

		[Event(name="fileDownloadComplete", type="com.bigfix.dss.event.FileDownloadCompleteEvent")]
		[Event(name="fileDownloadDialogClosed", type="com.bigfix.dss.event.FileDownloadDialogClosedEvent")]

        public function FileDownload() {
        }

        /**
         * Set references to the components, and add listeners for the OPEN, 
         * PROGRESS, and COMPLETE events.
         */
        public function init(pb:ProgressBar, btn:Button):void {
            // Set up the references to the progress bar and cancel button, which are passed from the calling script.
            this.pb = pb;
            this.btn = btn;

            fr = new FileReference();
            fr.addEventListener(Event.OPEN, openHandler);
            fr.addEventListener(ProgressEvent.PROGRESS, progressHandler);
            fr.addEventListener(Event.COMPLETE, completeHandler);
            fr.addEventListener(Event.CANCEL, cancelHandler);
        }

		public function get fileReference():FileReference {
			return this.fr;
		}
		
		public function get request():URLRequest {
			return this._request;
		}

        /**
         * Immediately cancel the download in progress and disable the cancel button.
         */
        public function cancelDownload():void {
            fr.cancel();
            pb.label = "DOWNLOAD CANCELLED";
            btn.enabled = false;
        }

        /**
         * Begin downloading the file specified in the DOWNLOAD_URL constant.
         */
        public function startDownload(fURL:String = ""):void {
            this._request = new URLRequest();
            this._request.url = ((fURL.length > 0) ? fURL : DOWNLOAD_URL);
            fr.download(this._request);
        }

        /**
         * When the OPEN event has dispatched, change the progress bar's label 
         * and enable the "Cancel" button, which allows the user to abort the 
         * download operation.
         */
        private function openHandler(event:Event):void {
            pb.label = "DOWNLOADING %3%%";
            btn.enabled = true;
        }
        
        /**
         * While the file is downloading, update the progress bar's status and label.
         */
        private function progressHandler(event:ProgressEvent):void {
            pb.setProgress(event.bytesLoaded, event.bytesTotal);
        }

		private function cancelHandler(event:Event):void {
			this.dispatchEvent(new FileDownloadDialogClosedEvent(FileDownloadDialogClosedEvent.type_FILE_DOWNLOAD_DIALOG_CLOSED));
		}
		
        /**
         * Once the download has completed, change the progress bar's label and 
         * disable the "Cancel" button since the download is already completed.
         */
        private function completeHandler(event:Event):void {
            pb.label = "DOWNLOAD COMPLETE";
            pb.setProgress(0, 100);
            btn.enabled = false;
            this.dispatchEvent(new FileDownloadCompleteEvent(FileDownloadCompleteEvent.FILE_DOWNLOAD_COMPLETE, this._request.url));
        }
    }
}