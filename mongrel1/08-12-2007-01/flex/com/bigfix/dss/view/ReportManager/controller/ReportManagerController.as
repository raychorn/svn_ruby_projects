package com.bigfix.dss.view.ReportManager.controller {
	import com.bigfix.dss.view.general.DragAndDrop.events.ClosedReportElementEditorEvent;
	import com.bigfix.dss.view.ReportManager.events.ClosedReportElementEvent;
	import flash.display.DisplayObject;
	import flash.events.Event;
	import com.bigfix.dss.view.general.DragAndDrop.DragReportElement;
	import com.bigfix.dss.view.general.DragAndDrop.events.BringReportElementToFrontEvent;
	import com.bigfix.dss.view.general.DragAndDrop.events.ResizeReportElementEvent;
	import com.bigfix.dss.view.ReportManager.events.ResizedReportElementEvent;
	import com.bigfix.dss.view.ReportManager.events.ResizedReportElementEvent;
	import com.bigfix.dss.view.ReportManager.events.MinimumReportElementSizeEvent;
	import com.bigfix.dss.view.ReportManager.ReportManager;
	
	public class ReportManagerController {

		private var _layoutPolicy:Function;
		private var _proxyDisplayObj:*;
			
		private function onClosedChildWindow(event:ClosedReportElementEditorEvent):void {
			try { this._layoutPolicy(); } catch (err:Error) { };
			try { this._proxyDisplayObj.dispatchEvent(new ClosedReportElementEvent(ClosedReportElementEvent.TYPE_CLOSED_REPORT_ELEMENT, event.id)); } catch (err:Error) { };
		}
		
		private function onAddedToStage(event:Event):void {
			var child:DragReportElement = DragReportElement(event.currentTarget);
			if (child != null) {
				try { 
					child.x = (this._proxyDisplayObj.width / 2) - (child.width / 2); 
					child.y = (this._proxyDisplayObj.height / 2) - (child.height / 2);
					child.removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
					this._layoutPolicy();
				} catch (err:Error) { };
			}
		}
			
		private function onBringChildWindowToFront(event:BringReportElementToFrontEvent):void {
			try { 
				if (this._proxyDisplayObj.isViewModeWindows) {
					var aChild:DragReportElement = DragReportElement(event.child);
					var canvas:ReportManager;
					try { canvas = this._proxyDisplayObj.getCurrentCanvas(); } catch (err:Error) { canvas = null; }
					if (canvas != null) {
		                canvas.setChildIndex(event.child, canvas.numChildren - 1);
					} else {
		                this._proxyDisplayObj.setChildIndex(event.child, this._proxyDisplayObj.numChildren - 1);
					}
				}
			} catch (err:Error) { };
		}
			
		public function checkWindowSize(aChild:DragReportElement):void {
			if (aChild.width >= this._proxyDisplayObj.width) {
				aChild.width = this._proxyDisplayObj.width - 32;
			}
			if (aChild.height >= this._proxyDisplayObj.height) {
				aChild.height = this._proxyDisplayObj.height - 32;
			}
		}
			
		private function onResizedChildWindow(event:ResizeReportElementEvent):void {
			try { 
				var aChild:DragReportElement = DragReportElement(event.child);
				this.checkWindowSize(aChild);
				this._proxyDisplayObj.dispatchEvent(new ResizedReportElementEvent(ResizedReportElementEvent.TYPE_RESIZED_REPORT_ELEMENT, aChild.id, aChild.width, aChild.height));
			} catch (err:Error) { };
		}
			
		private function onMovedChildWindow(event:ResizedReportElementEvent):void {
			try { 
				this._proxyDisplayObj.dispatchEvent(new ResizedReportElementEvent(ResizedReportElementEvent.TYPE_RESIZED_REPORT_ELEMENT, event.id, event.width, event.height));
			} catch (err:Error) { };
		}
			
		private function onMinimumSizedChildWindow(event:MinimumReportElementSizeEvent):void {
			try { 
				var aChild:DragReportElement = DragReportElement(event.currentTarget);
				aChild.width = event.width - 0;
				aChild.height = event.height - 0;
				var children:Array = aChild.getChildren();
				var dObj:DisplayObject = DisplayObject(children[0]);
				dObj.width = event.width - 40;
				dObj.height = event.height - 50;
			} catch (err:Error) { };
		}
			
		public function applyTo(aChild:DisplayObject):void {
			if (aChild != null) {
				aChild.addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
				aChild.addEventListener(ClosedReportElementEditorEvent.TYPE_CLOSED_REPORT_ELEMENT, onClosedChildWindow);
				aChild.addEventListener(BringReportElementToFrontEvent.TYPE_BRING_REPORT_ELEMENT_TO_FRONT, onBringChildWindowToFront);
				aChild.addEventListener(ResizeReportElementEvent.TYPE_RESIZE_REPORT_ELEMENT_COMPLETE, onResizedChildWindow);
				aChild.addEventListener(ResizedReportElementEvent.TYPE_RESIZED_REPORT_ELEMENT, onMovedChildWindow);
				aChild.addEventListener(MinimumReportElementSizeEvent.TYPE_MINIMUM_REPORT_ELEMENT_SIZE, onMinimumSizedChildWindow);
			}
		}
		
		public function ReportManagerController(layoutPolicy:Function, displayObject:DisplayObject):void {
			this._layoutPolicy = layoutPolicy;
			this._proxyDisplayObj = displayObject;
		}
	}
}