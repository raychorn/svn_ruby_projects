package com.bigfix.dss.vo {
	import com.adobe.cairngorm.vo.IValueObject;
	import com.bigfix.dss.view.ReportManager.canvas.WidgetCanvas;
	import com.bigfix.dss.view.dashboard.WidgetInstance;
	import com.bigfix.dss.view.general.Alert.AlertPopUp;
	import mx.utils.ObjectUtil;
	import com.bigfix.dss.view.graphics.sprites.TextSprite;
	import com.bigfix.dss.view.general.widgets.ImageWidget;
	import mx.containers.HBox;

	[Bindable]
	[RemoteClass(alias="com.bigfix.dss.vo.ReportBuilder")]
	public class ReportBuilderVO extends AbstractVO implements IValueObject {
		public var shape_type:String;
		public var x:Number;
		public var y:Number;
		public var width:Number;
		public var height:Number;
		public var widget_name:String;
		public var widget_id:int;
		public var text:String;
		public var source:String;
		public var report_id:int;
		public var id:int;
		
		private var _scaleImage:Boolean = false;
		
		public function set scaleImage(scaleImage:Boolean):void {
			this._scaleImage = scaleImage;
		}
		
		public function get scaleImage():Boolean {
			return this._scaleImage;
		}
		
		private function getWidgetInstanceFrom(grandChildren:Array):WidgetInstance {
			for (var i:int = 0; i < grandChildren.length; i++) {
				if (grandChildren[i] is WidgetInstance) {
					return WidgetInstance(grandChildren[i]);
				} else if (grandChildren[i] is HBox) {
					return this.getWidgetInstanceFrom(HBox(grandChildren[i]).getChildren());
				}
			}
			return null;
		}
		
		public function fromWidgetCanvas(wc:WidgetCanvas, missingImage_source:String = ""):void {
			this.shape_type = wc.shapeType;
			this.x = wc.x;
			this.y = wc.y;
			this.width = wc.width;
			this.height = wc.height;

			var children:Array = wc.getChildren();
			var grandChildren:Array;
			var widget:WidgetInstance;
			for (var i:int = 0; i < children.length; i++) {
				if (children[i] is ImageWidget) {
					var iw:ImageWidget = ImageWidget(children[i]);
					var sMissingImage:String = ((missingImage_source != null) ? missingImage_source : "");
					this.source = ((iw.image.source != null) ? iw.image.source.toString() : sMissingImage);
					this.scaleImage = ( (this.source.length == 0) || (this.source == sMissingImage) );
					this.x = iw.parent.x;
					this.y = iw.parent.y;
					this.width = iw.parent.width;
					this.height = iw.parent.height;
					break;
				} else {
					grandChildren = children[i].getChildren();
					widget = this.getWidgetInstanceFrom(grandChildren);
					if (widget != null) {
						this.widget_name = widget.name;
						this.widget_id = widget.widgetData.id;
						this.x = widget.parent.parent.x;
						this.y = widget.parent.parent.y;
						this.width = widget.parent.parent.width;
						this.height = widget.parent.parent.height;
						break;
					}
				}
			}
		}
		
		public function fromTextSprite(ts:TextSprite):void {
			this.shape_type = ts.shapeType;
			this.x = ts.x;
			this.y = ts.y;
			this.width = ts.width;
			this.height = ts.height;
			this.text = ts.textField.htmlText;
		}

		public function get isImage():Boolean {
			return ( (this.source != null) && (this.source.length > 0) );
		}
		
		public function get isMissingImage():Boolean {
			return ( (this.source != null) && (this.source.length == 0) );
		}
		
		public function get isWidget():Boolean {
			return ( (this.widget_id > 0) && (this.widget_name != null) && (this.widget_name.length > 0) );
		}
		
		public function ReportBuilderVO(obj:* = null):void {
			super();
			if ( (obj != null) && (obj is WidgetCanvas) ) {
				var wc:WidgetCanvas = WidgetCanvas(obj);
				this.fromWidgetCanvas(wc, wc.missingImage_image);
			} else if ( (obj != null) && (obj is TextSprite) ) {
				this.fromTextSprite(TextSprite(obj));
			} else {
	//			AlertPopUp.error("Cannot convert the object whose class is " + ObjectUtil.getClassInfo(obj).name + " to a ReportBuilderVO." + "\n", "Programming Error");
			}
		}
	}
}
