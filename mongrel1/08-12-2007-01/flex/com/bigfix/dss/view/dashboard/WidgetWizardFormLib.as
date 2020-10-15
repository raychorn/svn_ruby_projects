import com.bigfix.dss.model.DSSModelLocator;
import mx.core.Application;
import mx.events.ValidationResultEvent;
import mx.events.FlexEvent;
import mx.core.UIComponent;
import mx.core.ScrollPolicy;
import mx.containers.Canvas;
import com.bigfix.dss.util.Utils;
import com.bigfix.dss.util.WatcherManager;

[Bindable]
private var model:DSSModelLocator = DSSModelLocator.getInstance();
private var parentCanvas:Canvas;
private var watcherManager:WatcherManager = new WatcherManager();

private function WidgetWizardFormLib_init():void {
	this.addEventListener(FlexEvent.REMOVE, WidgetWizardFormLib_destruct, false, 0, true);
}

private function WidgetWizardFormLib_destruct(event:FlexEvent):void {
	trace("WidgetWizardFormLib_destruct()");
	watcherManager.removeAll();
	this.model = null;
	this.parentCanvas = null;
	this.removeEventListener(FlexEvent.REMOVE, WidgetWizardFormLib_destruct);
}

public function showForm(... rest):void {
	// hide other open forms
	try {
		parentDocument['hideAllForms']();
	} catch (e:Error) {
		trace("WidgetWizardForm*: unable to call parentDocument.hideAllForms()");
	}
	// draw a border around the label for this input and the arrow which leads to the form panel
	labelBox.styleName = 'wizardFormLabelActive';
	labelBox.validateNow();
	var baseX:int = labelBox.measuredWidth;
	var baseY:int = labelBox.measuredHeight/2;
	var triangleSize:int = 10;
	with (labelBox.graphics) {
		moveTo(baseX, baseY);
		//lineStyle(0, 0xe4b61, 1, true);
		beginFill(0x7c94b7);
		lineTo(baseX + triangleSize, baseY - triangleSize/2);
		lineTo(baseX + triangleSize, baseY + triangleSize/2);
		lineTo(baseX, baseY);
	}
	// find the ancestor canvas which we'll move and position the form into
	if (!parentCanvas) {
		parentCanvas = Canvas(Utils.findAncestorOfType(this, Canvas));
	}
	form = Panel(parentCanvas.addChild(this.removeChild(form)));

	// form.focusManager = labelBox.focusManager; // we get all sorts of weird focusing issues if we don't do this part...

	// position. use global space as common denominator
	var labelBoxGlobalPoint:Point = this.localToGlobal(new Point(baseX + triangleSize, labelBox.y));
	form.x = parentCanvas.globalToLocal(labelBoxGlobalPoint).x;
	// move the panel down if the bottom of the panel is above the label
	if (parentCanvas.localToGlobal(new Point(0, 0)).y + form.height < labelBoxGlobalPoint.y + labelBox.height) {
		form.y = parentCanvas.globalToLocal(labelBoxGlobalPoint).y - 5;
	} else {
		form.y = 0;
	}

	form.visible = true;
}

public function hideForm():void {
	labelBox.graphics.clear();
	labelBox.styleName = 'wizardFormLabelInactive';
	if (form.visible) {
		form.visible = false;
		form = Panel(this.addChild(parentCanvas.removeChild(form)));
	}
}

public function coalesce(value:String, label:Label):void {
	if (value == null || value == '') {
		label.setStyle('fontStyle', 'italic');
		label.setStyle('color', 0xbdbcb9);
		label.text = "(unset)";
	} else {
		label.clearStyle('fontStyle');
		label.clearStyle('color');
		label.text = value;
	}
}
