package com.bigfix.dss.view.graphics.sprites {
	import com.bigfix.dss.view.graphics.geometricshapes.IGeometricShape;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.geom.Point;
	import com.bigfix.dss.view.graphics.sprites.events.MouseOverSpriteEvent;
	import com.bigfix.dss.view.graphics.sprites.events.MouseOutSpriteEvent;
	import com.bigfix.dss.view.graphics.canvas.events.SelectedReportElementEvent;
	import com.bigfix.dss.util.CursorUtils;
	import com.bigfix.dss.view.graphics.canvas.ReportBuilderCanvas;
	import mx.events.IndexChangedEvent;
	import flash.text.TextField;
	import com.bigfix.dss.view.graphics.sprites.events.ResizeSpriteEvent;
	import mx.managers.CursorManager;
	import mx.managers.CursorManagerPriority;
	import com.bigfix.dss.view.graphics.sprites.events.RequestElementEditorEvent;
	import com.bigfix.dss.vo.ReportBuilderVO;
	import com.bigfix.dss.view.ReportManager.events.MovedReportElementEvent;
    
	public class GeometricSprite extends Sprite {
	    public var size:Number;
		public var lineColor:Number = 0x000000;
		public var fillColor:Number = 0xDDDDEE;
		public var headerColor:Number = 0xC0C0C0;
		
		public var id:String;
		
		private var _resizeShape:Shape;
		private var _hasResizeCorner:Boolean = false;
		
		private const dragThreshold:int = 5 * 4;
		
		private var _currentCursorID:int;

		private var _canResizeNow:Boolean = false;

		private var _debugTextField1:TextField;

		private var isMouseOver:Boolean = false;
		private var isMouseDown:Boolean = false;

		private var isEditable:Boolean = false;
		
		private var _vo:ReportBuilderVO;
		
		public var shapeType:String = "GeometricSprite";
		
		[Event(name="mouseOverSprite", type="com.bigfix.dss.view.graphics.sprites.events.MouseOverSpriteEvent")]
		[Event(name="mouseOutSprite", type="com.bigfix.dss.view.graphics.sprites.events.MouseOutSpriteEvent")]
		[Event(name="selectedReportElement", type="com.bigfix.dss.view.graphics.canvas.events.SelectedReportElementEvent")]
		[Event(name="resizeSprite", type="com.bigfix.dss.view.graphics.sprites.events.ResizeSpriteEvent")]
		[Event(name="requestElementEditor", type="com.bigfix.dss.view.graphics.sprites.events.RequestElementEditorEvent")]
		[Event(name="movedReportElement", type="com.bigfix.dss.view.ReportManager.events.MovedReportElementEvent")]

		[Embed(source="/assets/cursors/sizeNWSE.gif")]
		public static var sizeNWSECursorSymbol:Class;
								
		/**
		 * An instance of a purely geometric shape, that is, one that defines
		 * a shape mathematically but not visually.
		 */
		public var geometricShape:IGeometricShape;
		
		/**
		 * Keeps track of the currently selected shape.
		 * This is a static property, so there can only be one GeometricSprite
		 * selected at any given time.
		 */
		public static var selectedSprite:GeometricSprite;
		
		/**
		 * Holds a border rectangle that is shown when this GeometricSprite instance is selected.
		 */
		public var selectionIndicator:Shape;
		
		protected var initX:Number;
		protected var initY:Number;
		
		[Bindable]
		private var _myWidth:Number;
		
		[Bindable]
		private var _myHeight:Number;

		private static var _count:Number = 0;
			
		public static function get count():Number {
			_count++;
			return (_count - 1);
		}
		
		public function set vo(vo:ReportBuilderVO):void {
			this._vo = vo;
		}
		
		public function get vo():ReportBuilderVO {
			return this._vo;
		}
		
		public function GeometricSprite(size:Number = 100, lColor:Number = 0x000000, fColor:Number = 0xDDDDEE) {
		    this.size = size;
			this.lineColor = lColor;
			this.fillColor = fColor;
			this.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			this.addEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
			this.addEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
			this.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			this.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);

	//		this.addResizeShape();
		}
		
		public function get _height():Number {
			var height:Number = 0;
			try { height = this._myHeight; } catch (err:Error) { }
			return height;
		}
		
		public function get _width():Number {
			var width:Number = 0;
			try { width = this._myWidth; } catch (err:Error) { }
			return width;
		}
		
		public function set myWidth(width:Number):void {
			this._myWidth = width;
		}
		
		public function get myWidth():Number {
			return this._myWidth;
		}
		
		public function set myHeight(height:Number):void {
			this._myHeight = height;
		}
		
		public function get myHeight():Number {
			return this._myHeight;
		}
		
		public function refreshResizeShape():void {
			if (this._hasResizeCorner == true) {
				this._resizeShape.x = this.width;
				this._resizeShape.y = this.height;
			}
		}
		
		private function resetCursorToParentSetting():void {
			if (this._canResizeNow == true) {
				var dc:ReportBuilderCanvas = ReportBuilderCanvas(this.parent);
	//			CursorManager.removeAllCursors();
				this._canResizeNow = false;
			}
		}
		
		private function onMouseMove(event:MouseEvent):void {
			var ptM:Point = new Point(this.mouseX, this.mouseY);
			var ptR:Point = new Point(this._width, this._height);
			var dist:Number = Point.distance(ptM, ptR);
			if ( (dist < this.dragThreshold) && (this.isMouseOver) ) {
				var dc:ReportBuilderCanvas = ReportBuilderCanvas(this.parent);
				if (dc.canSpriteResizeBasedOnTypeOf(this.shapeType) == true) {
	//				CursorManager.setCursor(sizeNWSECursorSymbol, CursorManagerPriority.MEDIUM);
				}
				if (this._canResizeNow == false) {
					initX = event.stageX;
					initY = event.stageY;						
				}
				this._canResizeNow = true;
			} else {
				this.resetCursorToParentSetting();
			}
			if ( (this._canResizeNow) && (this.isMouseDown) ) {
				var y:Number = (event.stageY - initY);
				var x:Number = (event.stageX - initX);
				
				initX = event.stageX;
				initY = event.stageY;
				
				this.dispatchEvent(new ResizeSpriteEvent(ResizeSpriteEvent.TYPE_RESIZE_SPRITE, x, y));
			}
			this.isEditable = false;
		}

		private function addDebuggingChildren():void {
			var tf:TextField = new TextField();
			tf.x = 0;
			tf.y = 0;
			tf.text = "+++";
			tf.width = 350;
			tf.selectable = false;
			this.addChild(tf);
		}
		
		private function addResizeShape():void {
			this._resizeShape = new Shape();
			this._resizeShape.graphics.lineStyle(2);
			this._resizeShape.graphics.moveTo(this.width - 6, this.height - 1);
			this._resizeShape.graphics.curveTo(this.width - 3, this.height - 3, this.width - 1, this.height - 6);
			this._resizeShape.graphics.moveTo(this.width - 6, this.height - 4);
			this._resizeShape.graphics.curveTo(this.width - 5, this.height - 5, this.width - 4, this.height - 6);
			this._hasResizeCorner = true;
		}
		
		public function drawShape():void {
			this.refreshResizeShape();
		}
		
		private function onMouseOver(event:MouseEvent):void {
			if (this.isMouseOver == false) {
				this.dispatchEvent(new MouseOverSpriteEvent(MouseOverSpriteEvent.TYPE_MOUSE_OVER_SPRITE));
			}
			this.isMouseOver = true;
		}
		
		private function onMouseOut(event:MouseEvent):void {
			this.resetCursorToParentSetting();
			if (this.isMouseOver == true) {
				this.dispatchEvent(new MouseOutSpriteEvent(MouseOutSpriteEvent.TYPE_MOUSE_OUT_SPRITE));
			}
			this.isMouseOver = false;
		}

		private function onMouseDown(evt:MouseEvent):void {
			if (this._canResizeNow == false) {
				this.showSelected();
				
				// limits dragging to the area inside the canvas
				var boundsRect:Rectangle = this.parent.getRect(this.parent);
				boundsRect.width -= this.size;
				boundsRect.height -= this.size;
				this.startDrag(false, boundsRect);
			}
			this.isMouseDown = true;
			this.isEditable = true;
		}
		
		public function onMouseUp(evt:MouseEvent):void {
			if (this._canResizeNow == false) {
				this.stopDrag();
				this.dispatchEvent(new MovedReportElementEvent(MovedReportElementEvent.TYPE_MOVED_REPORT_ELEMENT, this.id, this.x, this.y));
			}
			this.isMouseDown = false;
			if (this.isEditable) {
				this.dispatchEvent(new RequestElementEditorEvent(RequestElementEditorEvent.TYPE_REQUEST_ELEMENT_EDITOR, this));
				this.isEditable = false;
			}
		}
		
		public function realSize():Point {
			var size:Point = new Point();
			size.y = this._height;
			if (size.y <= 0) {
				size.y = this.size;
			}
			size.x = this._width;
			if (size.x <= 0) {
				size.x = this.size;
			}
			return size;
		}
		
		public function showSelected():void {
		    if (this.selectionIndicator == null) {
		        this.selectionIndicator = new Shape();
		        this.selectionIndicator.graphics.lineStyle(1.0, 0xFF0000, 1.0);
				var size:Point = this.realSize();
			    this.selectionIndicator.graphics.drawRect(-1, -1, size.x + 1, size.y + 1);
			    this.addChild(this.selectionIndicator);
			    this.dispatchEvent(new SelectedReportElementEvent(SelectedReportElementEvent.TYPE_SELECTED_REPORT_ELEMENT, this));
		    } else {
		        this.selectionIndicator.visible = true;
		    }
		    
		    if (GeometricSprite.selectedSprite != this) {
    		    if (GeometricSprite.selectedSprite != null) {
    		        GeometricSprite.selectedSprite.hideSelected();
    		    }
		        GeometricSprite.selectedSprite = this;
		    }
		}
		
		public function hideSelected():void {
		    if (this.selectionIndicator != null) {		    
		        this.selectionIndicator.visible = false;
		        this.selectionIndicator = null;
		    }
		}
		
		/**
		 * Returns true if this shape's selection rectangle is currently showing.
		 */
		public function isSelected():Boolean {
		    return !(this.selectionIndicator == null || this.selectionIndicator.visible == false);
		}
		
		public override function toString():String {
			var size:Point = this.realSize();
		    return this.shapeType + " of size (" + size.toString() + ") at " + this.x + ", " + this.y;
		}
	}
}