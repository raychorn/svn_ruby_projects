package com.bigfix.extensions.controls.treeClasses {
	import flash.display.DisplayObject;
	import mx.controls.treeClasses.TreeItemRenderer;
	import mx.skins.ProgrammaticSkin;

	public class TreeItemRenderer extends mx.controls.treeClasses.TreeItemRenderer {
		private var legendMarker:ProgrammaticSkin;

		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void {
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			try {
				removeChild(legendMarker);
			} catch (e:Error) { }
			try {
				legendMarker = ProgrammaticSkin(addChild(data['legendMarker']));

				var startx:Number = data ? listData['indent'] : 0;
				if (disclosureIcon) {
					startx = disclosureIcon.x + disclosureIcon.width;
				}
				legendMarker.x = startx;
				startx = legendMarker.x + measuredHeight;
				legendMarker.setActualSize(measuredHeight, measuredHeight);
				label.x = startx;
				legendMarker.y = (unscaledHeight - measuredHeight) / 2;
			} catch (e:Error) { }

		}
	}
}