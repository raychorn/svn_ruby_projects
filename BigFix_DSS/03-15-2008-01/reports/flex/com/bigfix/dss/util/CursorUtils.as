package com.bigfix.dss.util {
	import mx.managers.CursorManager;
	import mx.managers.CursorManagerPriority;

	public class CursorUtils {
		private static var currentType:Class = null;
        
		/**
		 * Remove the current cursor and set an image.
		 * @param type The image class
		 * @param xOffset The xOffset of the cursorimage
		 * @param yOffset The yOffset of the cursor image
		 */
		public static function changeCursor(type:Class, xOffset:Number = 0, yOffset:Number = 0):int {
			if (currentType != type) {
				currentType = type;
				CursorManager.removeCursor(CursorManager.currentCursorID);
				if (type != null) {
					return CursorManager.setCursor(type, CursorManagerPriority.MEDIUM, xOffset, yOffset);
				}
			}
			return -1;
		}
 	}
}
