package com.bigfix.extensions.renderers {
	import mx.controls.treeClasses.TreeItemRenderer;
	import mx.controls.Tree;
	import mx.core.mx_internal;
	import mx.core.UITextField;


	public class DisabledTreeItemRenderer extends TreeItemRenderer {
		public function DisabledTreeItemRenderer() {
			super();
			setStyle('disabledColor', 0x666666);
		}

		override public function set data(value:Object):void {
			super.data = value;
		}

		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void {
			if (data[this.owner['selectableField']] == 'false') {
				enabled = false;
				trace("Fdasfdsa");
				var textField:UITextField = this.mx_internal::getLabel();
				trace(textField);
				trace(textField.text);
				label.setStyle('fontSize',40);
			}
			super.updateDisplayList(unscaledWidth, unscaledHeight);
		}
	}
}