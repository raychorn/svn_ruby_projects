package com.bigfix.dss.util {
	import mx.core.UIComponent;

	public class Utils {
		public static function findAncestorOfType(source:UIComponent, targetType:Class):UIComponent {
			try {
				if (source.parent is targetType) return UIComponent(source.parent);
				if (source.parent) {
					return findAncestorOfType(UIComponent(source.parent), targetType);
				} else {
					return null;
				}
			} catch (err:Error) { return null; }
			return null;
		}
	}
}