package customComponents.renderers {
	import mx.controls.listClasses.ListItemRenderer;
	import mx.controls.listClasses.ListBase;
	import mx.core.Application;
	import flash.events.MouseEvent;

	public class MetricListItemRenderer extends ListItemRenderer {
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void {
			if (data.id == null) {
				enabled = false;
				setStyle('disabledColor', '0x888888');
			}
			super.updateDisplayList(unscaledWidth, unscaledHeight);
		}
	}
}