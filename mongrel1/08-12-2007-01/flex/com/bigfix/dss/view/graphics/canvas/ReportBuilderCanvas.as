package com.bigfix.dss.view.graphics.canvas
{
	import flash.display.DisplayObject;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import mx.core.UIComponent;
	import com.bigfix.dss.view.graphics.sprites.GeometricSprite;
	import mx.events.FlexEvent;
	import mx.events.ResizeEvent;
	import com.bigfix.dss.view.graphics.sprites.TextSprite;
	import mx.controls.Label;
	import mx.managers.CursorManager;
	import com.bigfix.dss.view.graphics.RubberBand.RubberBandBox;
	import com.bigfix.dss.view.graphics.canvas.events.AddElementToReportEvent;
	import com.bigfix.dss.view.graphics.sprites.events.MouseOverSpriteEvent;
	import com.bigfix.dss.view.graphics.sprites.events.MouseOutSpriteEvent;
	import com.bigfix.dss.util.CursorUtils;
	import flash.display.DisplayObjectContainer;
	import com.bigfix.dss.view.graphics.sprites.WidgetSprite;
	import com.bigfix.dss.view.graphics.canvas.events.SelectedReportElementEvent;
	import com.bigfix.dss.view.general.Alert.AlertPopUp;
	import com.bigfix.dss.view.graphics.sprites.events.ResizeSpriteEvent;
	import com.bigfix.dss.view.graphics.sprites.events.ResizeSpriteCompleteEvent;
	import com.bigfix.dss.view.ReportManager.canvas.WidgetCanvas;
	import mx.managers.PopUpManager;
	import mx.events.CloseEvent;
	import mx.controls.Button;
	import com.bigfix.dss.view.editors.RichTextEditor;
	import com.bigfix.dss.view.editors.ImageEditor;
	import com.bigfix.dss.view.graphics.canvas.events.AddElementToReportCompletedEvent;
	import com.bigfix.dss.view.fileio.events.FileUploadCompletedEvent;
	import com.bigfix.dss.view.general.widgets.ImageWidget;
	import com.bigfix.dss.view.graphics.sprites.events.RequestElementEditorEvent;
	import com.bigfix.dss.view.graphics.canvas.events.InitializeReportBuilderButtonsEvent;
	import com.bigfix.dss.vo.ReportVO;
	import com.bigfix.dss.vo.ReportBuilderVO;

	public class ReportBuilderCanvas extends UIComponent {
		[Bindable]
		public var bounds:Rectangle;

		[Bindable]
		public var lineColor:Number = 0x000000;

		[Bindable]
		public var fillColor:Number = 0xFFFFFF;
		
        public static const const_UNDEFINED_ELEMENT:String = "undefinedReportElement";

        public static const const_SELECT_ELEMENTS:String = "selectReportElement";
        public static const const_TEXT_REPORT_ELEMENT:String = "textReportElement";
        public static const const_LIST_ELEMENTS:String = "listReportElement";
        public static const const_WIDGET_ELEMENTS:String = "widgetReportElement";
        public static const const_IMAGE_ELEMENTS:String = "imageReportElement";

        public static const const_CLICK_FORWARD_OPTION:String = "clickForward";
        public static const const_CLICK_NORMAL_OPTION:String = "clickNormal";

		[Event(name="addElementToReport", type="com.bigfix.dss.view.graphics.canvas.events.AddElementToReportEvent")]
		[Event(name="resizeSpriteComplete", type="com.bigfix.dss.view.graphics.sprites.events.ResizeSpriteCompleteEvent")]
		[Event(name="addElementToReportCompleted", type="com.bigfix.dss.view.graphics.canvas.events.AddElementToReportCompletedEvent")]
		[Event(name="initializeReportBuilderButtons", type="com.bigfix.dss.view.graphics.canvas.events.InitializeReportBuilderButtonsEvent")]

		[Embed(source="/assets/cursors/textModeTransparent.png")]
		public static var textModeCursorSymbol:Class;

		[Embed(source="/assets/cursors/noModeTransparent.gif")]
		public static var noModeCursorSymbol:Class;
		
		[Embed(source="/assets/cursors/listModeTransparent.png")]
		public static var listModeCursorSymbol:Class;
		
		[Embed(source="/assets/cursors/imageModeTransparent.png")]
		public static var imageModeCursorSymbol:Class;
		
		private static var _elementArray:Array = [];

		private var _currentCursorID:int;
		private var _currentCursorClass:Class;
		private var _isCursorLeaving:Boolean;

		private var _isResizingSprite:Boolean = false;
		private var _currentSprite:*;

		private var _currentEditor:*;
		
		private var _currentStatus:*;

		private var rbComp:RubberBandBox;

		private var _isMouseOverSprite:Boolean;
		
		private var _isMouseDown:Boolean = false;

		private var _children:Array = [];

		protected var initX:Number;
		protected var initY:Number;
		
		private var _selectOption:String;
		
		public static function get elementArray():Array {
			return _elementArray;
		}

		public function ReportBuilderCanvas() {
			super();

			this.addEventListener(FlexEvent.CREATION_COMPLETE, onCreationComplete);
			this.addEventListener(ResizeEvent.RESIZE, onResize);
			this.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			this.addEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
			this.addEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
			this.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			this.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			
			this.addEventListener(SelectedReportElementEvent.TYPE_SELECTED_REPORT_ELEMENT, onSelectedReportElement);
			
			this.addEventListener(RequestElementEditorEvent.TYPE_REQUEST_ELEMENT_EDITOR, onRequestElementEditor);

			this.addEventListener(ResizeSpriteEvent.TYPE_RESIZE_SPRITE, onResizeSprite);

			this._currentCursorClass = null;
			this._currentCursorID = CursorManager.NO_CURSOR;
			this._isCursorLeaving = false;

            this.addEventListener(AddElementToReportEvent.TYPE_ADD_ELEMENT_TO_REPORT, onAddElementToReport);
		}
		
		private function onRequestElementEditor(event:RequestElementEditorEvent):void {
			if (event.element is TextSprite) {
				var ts:TextSprite = TextSprite(event.element);
    			var win:RichTextEditor = this.popUpRichTextEditor();
    			win.sprite = ts;
			}
		}
		
		public function canSpriteResizeBasedOnTypeOf(aType:String):Boolean {
			return (aType != const_TEXT_REPORT_ELEMENT);
		}
		
		override public function addChild(aChild:DisplayObject):DisplayObject {
			this._children.push(aChild);
			return super.addChild(aChild);
		}
		
		private function onResizeSprite(event:ResizeSpriteEvent):void {
			this._isResizingSprite = true;
			this._currentSprite = event.target;
			try { this.deselectAllButThisChildById(""); } catch (err:Error) { }
		}
		
		private function isSelectOptionValid(selectOption:String):Boolean {
			return ( (selectOption == const_CLICK_FORWARD_OPTION) || (selectOption == const_CLICK_NORMAL_OPTION) );
		}
		
		public function set selectOption(selectOption:String):void {
			if (this.isSelectOptionValid(selectOption)) {
				this._selectOption = selectOption;
			}
		}
		
		public function get currentCursorClass():Class {
			return this._currentCursorClass;
		}
		
		public function get selectOption():String {
			return this._selectOption;
		}
		
		public function get isSelectOptionForward():Boolean {
			return (this._selectOption == const_CLICK_FORWARD_OPTION);
		}
		
		public function get currentCursorID():int {
			return this._currentCursorID;
		}
		
		public function get isCursorLeaving():Boolean {
			return this._isCursorLeaving;
		}
		
		public function get isMouseOverSprite():Boolean {
			return this._isMouseOverSprite;
		}
		
		public function get isCanvasEmpty():Boolean {
			return (_elementArray.length == 0);
		}
		
		private function deselectAllButThisChildById(id:String):void {
			var children:Array = this._children;
			var aChild:*;
			var i:int;
			if (id != null) {
				for (i = 0; i < children.length; i++) {
					aChild = children[i];
					if ( (aChild != null) && (aChild["id"] != id) ) {
						try { aChild.hideSelected(); } catch (err:Error) { 
							AlertPopUp.error(err.toString(), "deselectAllButThisChildById");
						}
					}
				}
			}
		}
		
		private function onSelectedReportElement(event:SelectedReportElementEvent):void {
			this._currentSprite = event.element;
			try { this.deselectAllButThisChildById(event.element.id); } catch (err:Error) { }
			if (this.isSelectOptionForward) {
				try { this.moveToFront(event.element); } catch (err:Error) { }
			}
		}
		
		public function init():void {
			var child:*;
			this._currentSprite = null;
			this._currentEditor = null;
			this._children = [];
			_elementArray = [];
			try {
				var i:int = 0;
				while ((child = this.getChildAt(i)) != null) {
					if (child is RubberBandBox) {
						i++;
					} else {
						this.removeChild(child);
					}
				}
			} catch (err:Error) { }
		}
		
		private function populateSpecificElement(bVO:ReportBuilderVO):void {
			this.dispatchEvent(new AddElementToReportEvent(AddElementToReportEvent.TYPE_ADD_ELEMENT_TO_REPORT, bVO.shapeType, bVO.x, bVO.y, bVO.width, bVO.height, bVO));
		}
		
		public function populateFrom(vo:ReportVO):void {
			var data:Array = vo.data;
			if (data != null) {
				var i:int;
				var bVO:ReportBuilderVO;
				for (i = 0; i < data.length; i++) {
					bVO = ReportBuilderVO(data[i]);
					this.populateSpecificElement(bVO);
				}
			}
		}
		
		public function deleteSelectedElement():void {
			this.removeChild(this._currentSprite);
			var i:int = _elementArray.indexOf(this._currentSprite);
			if (i > -1) {
				_elementArray.splice(i,1);
			}
		}

		private function hideRubberBandBox():void {
			rbComp.x = 0;
			rbComp.y = 0;
			rbComp.height = 0;
			rbComp.width = 0;
			rbComp.visible = false;
		}
		
		private function recalcBounds():void {
			this.bounds = new Rectangle(0, 0, this.width, this.height);
		}
		
		private function onResize(event:ResizeEvent):void {
			this.recalcBounds();
			this.drawBounds();
		}
		
		private function addRubberBandComp():void {
			this.rbComp = new RubberBandBox();
			this.rbComp.x = 0;
			this.rbComp.y = 0;
			this.rbComp.width = 0;
			this.rbComp.height = 0;
			this.rbComp.visible = false;
			super.addChild(this.rbComp);
		}
			
		private function onCreationComplete(event:FlexEvent):void {
			this.recalcBounds();
			this.addRubberBandComp();
		}
		
		public function initCanvas(fillColor:Number = 0xFFFFFF, lineColor:Number = 0x000000):void {
			this.lineColor = lineColor;
			this.fillColor = fillColor;
			drawBounds();
		}
		
		private function drawBounds():void {
			this.graphics.clear();
			
			this.graphics.lineStyle(1.0, this.lineColor, 1.0);
			this.graphics.beginFill(this.fillColor, 1.0);
			this.graphics.drawRect(bounds.left - 1, bounds.top = 1, bounds.width + 2, bounds.height + 2);
			this.graphics.endFill();
		}
		
		private function onMouseOverSprite(event:MouseOverSpriteEvent):void {
			this._isMouseOverSprite = true;
		}
		
		private function onMouseOutSprite(event:MouseOutSpriteEvent):void {
			this._isMouseOverSprite = false;
		}

	    public function addWidget(widget:DisplayObjectContainer):DisplayObjectContainer {
            this.addChild(widget);
            this._currentSprite = widget;
            pushElementToArrayUniquely(widget);
            this.dispatchEvent(new AddElementToReportCompletedEvent(AddElementToReportCompletedEvent.TYPE_ADD_ELEMENT_TO_REPORT_COMPLETED));
            return widget;
		}

	    public function addShape(shapeName:String, len:Number):GeometricSprite {
	        var newShape:GeometricSprite;
	        
	        switch (shapeName) {       
                case const_TEXT_REPORT_ELEMENT:
                    newShape = new TextSprite(len);
                    break;
                    
                case const_WIDGET_ELEMENTS:
                    newShape = new WidgetSprite(len);
                    break;
            }
            // makes the shapes slightly transparent, so you can see what's behind them
            newShape.alpha = 0.8;
            
            this.addChild(newShape);
            this.pushElementToArrayUniquely(newShape);
            newShape.addEventListener(MouseOverSpriteEvent.TYPE_MOUSE_OVER_SPRITE, onMouseOverSprite);
            newShape.addEventListener(MouseOutSpriteEvent.TYPE_MOUSE_OUT_SPRITE, onMouseOutSprite);
			this._currentSprite = newShape;
			if (this._currentEditor != null) {
				this._currentEditor.sprite = newShape;
			}
            return newShape;
	    }
	    
	    private function popUpRichTextEditor(width:Number = 500, height:Number = 400):RichTextEditor {
	    	var minWidth:Number = 500;
	    	var minHeight:Number = 400;
			var window:RichTextEditor = RichTextEditor(PopUpManager.createPopUp( this, RichTextEditor, true));
			window.x = 0;
			window.y = 0;
			window.width = ((width < minWidth) ? minWidth : width);
			window.height = ((height < minHeight) ? minHeight : height);
			window.title = "Rich Text Editor";
			window.addEventListener(CloseEvent.CLOSE, onCloseRichTextEditor);
			window.addEventListener(MouseEvent.CLICK, onClickButtonRichTextEditor);
			PopUpManager.centerPopUp(window);
			this._currentEditor = window;
			return window;
	    }
	    
		private function onFileUploadCompleted(event:FileUploadCompletedEvent):void {
			var widget:WidgetCanvas;
			var child:ImageWidget;
			var status:Object = event.data;
			if (status != null) {
				var success:Boolean = status.success;
				var serverFileName:String = status.serverFileName;
				this._currentStatus = status;
				if (this._currentSprite is WidgetCanvas) {
					widget = WidgetCanvas(this._currentSprite);
					child = ImageWidget(widget.getChildAt(0));
					try {
						child.image.source = serverFileName;
						child.image.width = status.image_width;
						child.image.height = status.image_height;
					} catch (err:Error) { }
	
					try {
						child.width = status.image_width + 2;
						child.height = status.image_height + 2;
					} catch (err:Error) { }
					
					try {
						widget.width = ((status.image_width < 32) ? 32 : child.width);
						widget.height = ((status.image_height < 32) ? 32 : child.height);
					} catch (err:Error) { }
					this.dispatchEvent(new AddElementToReportCompletedEvent(AddElementToReportCompletedEvent.TYPE_ADD_ELEMENT_TO_REPORT_COMPLETED));
				}
			} else { // remove the child when the user hits the dismiss button because there was no image to upload.
				if (this._currentSprite is WidgetCanvas) {
					widget = WidgetCanvas(this._currentSprite);
					child = ImageWidget(widget.getChildAt(0));
					widget.removeAllChildren();
					this.removeChild(widget);
				}
			}
		}
			
	    private function popUpImageEditor(width:Number = 500, height:Number = 150):ImageEditor {
	    	var minWidth:Number = 500;
	    	var minHeight:Number = 150;
			var window:ImageEditor = ImageEditor(PopUpManager.createPopUp( this, ImageEditor, true));
			window.x = 0;
			window.y = 0;
			window.width = minWidth;
			window.height = minHeight;
			window.title = "Image Uploader (Choose one file to upload)";
			window.addEventListener(CloseEvent.CLOSE, onCloseImageEditor);
			window.addEventListener(MouseEvent.CLICK, onClickButtonImageEditor);
			window.addEventListener(FileUploadCompletedEvent.TYPE_FILE_UPLOAD_COMPLETE, onFileUploadCompleted);
			PopUpManager.centerPopUp(window);
			this._currentEditor = window;
			return window;
	    }
	    
	    private function onClickButtonImageEditor(event:MouseEvent):void {
	    	if (event.target is Button) {
		    	var win:ImageEditor = ImageEditor(event.currentTarget);
	    		var btn:Button = Button(event.target);
	    		switch (btn.label) {
	    			case win.editor.btnUpload.label:
						PopUpManager.removePopUp(win);
	    			break;

	    			case win.editor.btn_dismiss.label:
						PopUpManager.removePopUp(win);
	    			break;
	    		}
	    	}
	    }
	    
	    private function pushElementToArrayUniquely(element:*):void {
	    	if (_elementArray.indexOf(element) == -1) {
	            _elementArray.push(element);
	    	}
	    }
	    
	    private function onClickButtonRichTextEditor(event:MouseEvent):void {
	    	var ts:TextSprite;
	    	if (event.target is Button) {
		    	var win:RichTextEditor = RichTextEditor(event.currentTarget);
	    		var btn:Button = Button(event.target);
	    		switch (btn.label) {
	    			case win.btn_save.label:
						ts = TextSprite(win.sprite);
						ts.htmlText = win.editor.htmlText;
						PopUpManager.removePopUp(win);
			            pushElementToArrayUniquely(ts);
						this.dispatchEvent(new AddElementToReportCompletedEvent(AddElementToReportCompletedEvent.TYPE_ADD_ELEMENT_TO_REPORT_COMPLETED));
	    			break;

	    			case win.btn_Dismiss.label:
						PopUpManager.removePopUp(win);
						ts = TextSprite(this._currentSprite);
						if (ts.htmlText.length == 0) {
							this.removeChild(this._currentSprite);
						}
	    			break;
	    		}
	    	}
	    }
	    
	    private function onCloseImageEditor(event:CloseEvent):void {
	    	var win:ImageEditor = ImageEditor(event.currentTarget);
			PopUpManager.removePopUp(win);
	    }
	    
	    private function onCloseRichTextEditor(event:CloseEvent):void {
	    	var win:RichTextEditor = RichTextEditor(event.currentTarget);
			PopUpManager.removePopUp(win);
			this.removeChild(this._currentSprite);
	    }
	    
	    private function onAddElementToReport(event:AddElementToReportEvent):void {
	    	this._clearMode();

			if (event.data == null) {
		    	switch (event.elementType) {
		    		case const_TEXT_REPORT_ELEMENT:
		    			var win:RichTextEditor = this.popUpRichTextEditor(event.width, event.height);
		    		break;
	
		    		case ReportBuilderCanvas.const_IMAGE_ELEMENTS:
		    			var win2:ImageEditor = this.popUpImageEditor(event.width, event.height);
		    		break;
		    	}
			}
	    }

	    public function setTextMode():void {
	    	this._currentCursorClass = textModeCursorSymbol;
	    	this._isCursorLeaving = true;
	    }
	    
	    public function setListMode():void {
	    	this._currentCursorClass = listModeCursorSymbol;
	    	this._isCursorLeaving = true;
	    }
	    
	    public function setImageMode():void {
	    	this._currentCursorClass = imageModeCursorSymbol;
	    	this._isCursorLeaving = true;
	    }

	    public function isCursorInRubberBandMode():Boolean {
	    	return ( (this._currentCursorClass == textModeCursorSymbol) || (this._currentCursorClass == listModeCursorSymbol) || (this._currentCursorClass == imageModeCursorSymbol) );
	    }
	    
	    public function get rbCompStats():String {
	    	return this.rbComp.visible + ", (" + this.rbComp.x + "," + this.rbComp.y + "), (" + this.rbComp.width + " x " + this.rbComp.height + ")";
	    }
	    
	    public function get cursorClassToElementType():String {
	    	var type:String = "";
	    	switch (this._currentCursorClass) {
	    		case textModeCursorSymbol:
	    			type = const_TEXT_REPORT_ELEMENT;
	    		break;

	    		case listModeCursorSymbol:
	    			type = const_LIST_ELEMENTS;
	    		break;

	    		case imageModeCursorSymbol:
	    			type = const_IMAGE_ELEMENTS;
	    		break;
	    	}
	    	return type;
	    }
	    
	    public function _clearMode():void {
			this._currentCursorClass = null;
			this._currentCursorID = CursorManager.NO_CURSOR;
			this.dispatchEvent(new InitializeReportBuilderButtonsEvent(InitializeReportBuilderButtonsEvent.TYPE_INITIALIZE_REPORT_BUILDER_BUTTONS));
	    }
	    
	    public function clearMode():void {
			if (this._currentCursorID != CursorManager.NO_CURSOR) {
		    	this._currentCursorClass = ReportBuilderCanvas.noModeCursorSymbol;
			}
	    }

		public function describeChildren():String {   
		    var desc:String = "";
		    var child:DisplayObject;
		    for (var i:int=0; i < this.numChildren; i++) {
		        child = this.getChildAt(i);
		        desc += i + ": " + child + '\n';
		    }
		    return desc;
		}

		public function moveToBack(shape:*):void {
		    var index:int = this.getChildIndex(shape);
		    if (index > 0) {
		        this.setChildIndex(shape, 0);
		    }
		}
		
		public function moveDown(shape:*):void {
		    var index:int = this.getChildIndex(shape);
		    if (index > 0) {
		        this.setChildIndex(shape, index - 1);
		    }
		}
		
		public function moveToFront(shape:*):void {
		    var index:int = this.getChildIndex(shape);
		    if (index != -1 && index < (this.numChildren - 1)) {
		        this.setChildIndex(shape, this.numChildren - 1);
		    }
		}

		public function moveUp(shape:*):void {
		    var index:int = this.getChildIndex(shape);
		    if (index != -1 && index < (this.numChildren - 1)) {
		        this.setChildIndex(shape, index + 1);
		    }
		}
		
		/**
		 * Traps all mouseUp events and sends them to the selected shape.
		 * Useful when you release the mouse while the selected shape is
		 * underneath another one (which prevents the selected shape from
		 * receiving the mouseUp event).
		 */
		private function onMouseUp(evt:MouseEvent):void {
		    var selectedSprite:GeometricSprite = GeometricSprite.selectedSprite;
		    if (selectedSprite != null && selectedSprite.isSelected()) {
			    selectedSprite.onMouseUp(evt);
			}
			if ( (this.isCursorInRubberBandMode()) && (this.rbComp.visible) ) {
				this.dispatchEvent(new AddElementToReportEvent(AddElementToReportEvent.TYPE_ADD_ELEMENT_TO_REPORT, this.cursorClassToElementType, this.rbComp.x, this.rbComp.y, this.rbComp.width, this.rbComp.height));
				this.hideRubberBandBox();
			}
			this._isMouseDown = false;
			if (this._isResizingSprite) {
				CursorManager.removeCursor(CursorManager.currentCursorID);
				this._currentSprite.dispatchEvent(new ResizeSpriteCompleteEvent(ResizeSpriteCompleteEvent.TYPE_RESIZE_SPRITE_COMPLETE));
				this._isResizingSprite = false;
			}
		}
		
		private function onMouseDown(event:MouseEvent):void {
			if ( (this.isCursorInRubberBandMode()) && (!this.rbComp.visible) && (!this._isMouseOverSprite) ) {
				this.rbComp.x = event.localX;
				this.rbComp.y = event.localY;
				initX = event.stageX;
				initY = event.stageY;						
				this.rbComp.visible = true;
			} else {
				initX = event.stageX;
				initY = event.stageY;						
			}
			this._isMouseDown = true;
		}
		
		private function onMouseMove(event:MouseEvent):void {
			if ( (this.isCursorInRubberBandMode()) && (this.rbComp.visible) ) {
				rbComp.height += (event.stageY - initY);
				rbComp.width += (event.stageX - initX);
				
				initX = event.stageX;
				initY = event.stageY;
			} else if ( (this._isResizingSprite) && (this._isMouseDown) ) {
				var shapeType:String = "";
				try { 
					var gs:GeometricSprite = GeometricSprite(this._currentSprite); 
					shapeType = gs.shapeType;
				} catch (err:Error) { }
				if (shapeType.length == 0) {
					try { 
						var wc:WidgetCanvas = WidgetCanvas(this._currentSprite); 
						shapeType = wc.shapeType;
					} catch (err:Error) { }
				}
				switch (shapeType) {
					case const_TEXT_REPORT_ELEMENT:
						var ts:TextSprite = TextSprite(this._currentSprite);
						try { ts.myWidth += (event.stageX - initX); } catch (err:Error) { }
						try { ts.myHeight += (event.stageY - initY); } catch (err:Error) { }
						ts.drawShape();
						ts.refreshResizeShape();
					break;

					case const_WIDGET_ELEMENTS:
						try { wc.width += (event.stageX - initX); } catch (err:Error) { }
						try { wc.height += (event.stageY - initY); } catch (err:Error) { }
					break;
				}
				
				initX = event.stageX;
				initY = event.stageY;
			}
		}

		private function onMouseOut(event:MouseEvent):void {
			if ( (this._currentCursorID != CursorManager.NO_CURSOR) && (this._currentCursorClass != null) && (this._isCursorLeaving == false) ) {
	//			CursorManager.removeCursor(this._currentCursorID);
				this._isCursorLeaving = true;
			}
		}
		
		private function onMouseOver(event:MouseEvent):void {
			if ( (this._currentCursorClass == null) || ( (this._currentCursorClass != null) && (this._isCursorLeaving == true) ) ) {
				if (this._currentCursorClass != null) {
	//				this._currentCursorID = CursorManager.setCursor(this._currentCursorClass, 2, -10, -10);
					this._isCursorLeaving = false;
				}
			}
		}
	}
}