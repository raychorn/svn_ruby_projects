package com.bigfix.dss.view.graphics.sprites {
    import com.bigfix.dss.view.graphics.geometricshapes.Square;
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
    
	public class WidgetSprite extends GeometricSprite {
		public function WidgetSprite(size:Number = 100, lColor:Number = 0x000000, fColor:Number = 0xCCEECC) {
			super(size, lColor, fColor);
			this.shapeType = ReportBuilderCanvas.const_UNDEFINED_ELEMENT;
			this.geometricShape = new Square(size);
			
			drawShape();
		}
		
		public override function drawShape():void {
			this.graphics.clear();
			
			this.graphics.lineStyle(1.0, this.lineColor, 1.0);
			this.graphics.beginFill(this.fillColor, 1.0);
			
			if (this.size > 0) {
				this.myWidth = this.size;
				this.myHeight = this.size / 2;
			}
			try {
				this.graphics.drawRect(0, 0, this.myWidth, this.myHeight);
			} catch (err:Error) { }
		}
	}
}