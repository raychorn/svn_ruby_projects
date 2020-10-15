package customComponents.icons {
	import mx.core.UIComponent;
	import flash.filters.DropShadowFilter;
	import flash.filters.BevelFilter;
	public class PlusSign extends UIComponent {
		public function PlusSign(size:int = 12) {
			super();
			trace("creating a plussign of size " + size);
			var dropShadowFilter:DropShadowFilter = new DropShadowFilter(2, 45, 0, .5);
			var bevelFilter:BevelFilter = new BevelFilter(2);
			graphics.lineStyle(2, 0x000000, 1, true);
			graphics.moveTo(0, size/2);
			graphics.lineTo(size, size/2);
			graphics.moveTo(size/2, 0);
			graphics.lineTo(size/2, size);
			var newFilters:Array = filters;
			newFilters.push(bevelFilter);
			newFilters.push(dropShadowFilter);
			filters = newFilters;
		}
	}
}
