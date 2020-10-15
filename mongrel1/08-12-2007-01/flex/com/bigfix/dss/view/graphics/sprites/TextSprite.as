package com.bigfix.dss.view.graphics.sprites {
    import flash.events.MouseEvent;
    import com.bigfix.dss.view.graphics.canvas.ReportBuilderCanvas;
    import mx.controls.Label;
    import flash.text.TextField;
    import flash.text.TextLineMetrics;
    import mx.core.UITextFormat;
    import mx.managers.SystemManager;
    import com.bigfix.dss.util.Misc;
    import flash.text.AntiAliasType;
    import flash.text.GridFitType;
    import com.bigfix.dss.view.graphics.sprites.events.ResizeSpriteCompleteEvent;
    import mx.events.FlexEvent;
    import com.bigfix.dss.view.graphics.geometricshapes.Square;
    
	public class TextSprite extends GeometricSprite {
		[Bindable]
		public var options:uint = 0x0000;
		
		public static const const_showHeader_option:uint = 0x0001;
		
		private var _textField:TextField;
		
		private var _textMetrics:TextLineMetrics;

		public function get textField():TextField {
			return this._textField;
		}
		
		private function computeTextMetricsFor(textField:TextField):TextLineMetrics {
			var ut:UITextFormat = new UITextFormat(Misc.systemManager, textField.text);
			ut.antiAliasType = AntiAliasType.NORMAL;
			ut.gridFitType = GridFitType.PIXEL;
			var lineMetrics:TextLineMetrics = ut.measureHTMLText(textField.htmlText);
			return lineMetrics;
		}
		
		private function adjustTextFieldBasedOnMetrics():void {
			var yOffset:Number = 20;
			if (this._textMetrics != null) {
				yOffset = this._textMetrics.height;
			}
			
			this.myWidth = this._textMetrics.width + 10;
			this.myHeight = this._textMetrics.height + 5;

			this._textField.y = ((this.myHeight > 0) ? this.myHeight - yOffset : -yOffset);
			this._textField.x = ((this.myWidth > 0) ? 0 : this.myWidth);
			this._textField.width = this.myWidth;
			this._textField.height = this.myHeight;

			this.drawShape();
			super.showSelected();
		}
		
		public function set htmlText(htmlText:String):void {
			this._textField.htmlText = htmlText;
			this._textMetrics = this.computeTextMetricsFor(this._textField);
			this.adjustTextFieldBasedOnMetrics();
		}
		
		public function get htmlText():String {
			return this._textField.htmlText;
		}
		
		public function TextSprite(size:Number = 100, lColor:Number = 0x000000, fColor:Number = 0xCCEECC) {
			super(size, lColor, fColor);
			this.shapeType = ReportBuilderCanvas.const_TEXT_REPORT_ELEMENT;
			this.geometricShape = new Square(size);
			
			drawShape();
			
			this.addEventListener(ResizeSpriteCompleteEvent.TYPE_RESIZE_SPRITE_COMPLETE, onResizeSpriteComplete);

			var aTextField:TextField;

            aTextField = new TextField();
            aTextField.y = this.myHeight - 20;
			aTextField.width = this.myWidth;
			aTextField.selectable = false;
            aTextField.htmlText = '';
            this.addChild(aTextField);
            this._textField = aTextField;
            
            this.fillColor = 0xffffff;
		}
		
		private function onResizeSpriteComplete(event:ResizeSpriteCompleteEvent):void {
		}
		
		public override function drawShape():void {
			this.graphics.clear();
			
	//		this.graphics.lineStyle(1.0, this.lineColor, 1.0);
	//		this.graphics.beginFill(this.fillColor, 1.0);
			
			if (this.size > 0) {
				this.myWidth = this.size;
				this.myHeight = this.size / 2;
			}
			try {
	//			this.graphics.drawRect(0, 0, this.myWidth, this.myHeight);
				
	//			this.adjustTextFieldBasedOnMetrics();
			} catch (err:Error) { }
			super.drawShape();
		}
	}
}