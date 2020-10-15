package com.bigfix.extensions.renderers {
	import mx.controls.listClasses.ListItemRenderer;

	public class DisabledListItemRenderer extends ListItemRenderer {
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void {
			if (data.id == null) {
				enabled = false;
				setStyle('disabledColor', '0x888888');
			}
			super.updateDisplayList(unscaledWidth, unscaledHeight);
		}
	}
}