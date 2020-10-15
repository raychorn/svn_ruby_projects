package com.bigfix.dss.vo {
	import com.adobe.cairngorm.vo.IValueObject;
	import com.bigfix.dss.view.ReportManager.canvas.WidgetCanvas;
	import com.bigfix.dss.view.dashboard.WidgetInstance;
	import com.bigfix.dss.view.general.Alert.AlertPopUp;
	import mx.utils.ObjectUtil;
	import com.bigfix.dss.view.graphics.sprites.TextSprite;
	import com.bigfix.dss.view.general.widgets.ImageWidget;

	[Bindable]
	[RemoteClass(alias="com.bigfix.dss.vo.ReportBuilder")]
	public class ReportBuilderVO extends AbstractVO implements IValueObject {
		public var shapeType:String;
		public var x:Number;
		public var y:Number;
		public var width:Number;
		public var height:Number;
		public var widgetName:String;
		public var widgetID:int;
		public var text:String;
		public var source:String;
		
		public function fromWidgetCanvas(wc:WidgetCanvas):void {
			this.shapeType = wc.shapeType;
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
					this.source = iw.image.source.toString();
				} else {
					grandChildren = children[i].getChildren();
					for (var j:int = 0; j < grandChildren.length; j++) {
						widget = WidgetInstance(grandChildren[j]);
						this.widgetName = widget.name;
						this.widgetID = widget.widgetData.id;
					}
				}
			}
		}
		
		public function fromTextSprite(ts:TextSprite):void {
			this.shapeType = ts.shapeType;
			this.x = ts.x;
			this.y = ts.y;
			this.width = ts.width;
			this.height = ts.height;
			this.text = ts.textField.htmlText;
		}

		public function ReportBuilderVO(obj:* = null):void {
			super();
			if ( (obj != null) && (obj is WidgetCanvas) ) {
				this.fromWidgetCanvas(WidgetCanvas(obj));
			} else if ( (obj != null) && (obj is TextSprite) ) {
				this.fromTextSprite(TextSprite(obj));
			} else {
	//			AlertPopUp.error("Cannot convert the object whose class is " + ObjectUtil.getClassInfo(obj).name + " to a ReportBuilderVO." + "\n", "Programming Error");
			}
		}
	}
}
