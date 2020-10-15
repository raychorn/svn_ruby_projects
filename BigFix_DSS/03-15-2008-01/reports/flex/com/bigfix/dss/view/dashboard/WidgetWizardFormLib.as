import com.bigfix.dss.model.DSSModelLocator;
import mx.core.Application;
import mx.events.ValidationResultEvent;
import mx.events.FlexEvent;
import mx.core.UIComponent;
import mx.core.ScrollPolicy;
import mx.containers.Canvas;
import com.bigfix.dss.util.Utils;
import com.bigfix.dss.util.WatcherManager;
import mx.containers.TitleWindow;
import com.bigfix.dss.view.general.Alert.AlertPopUp;

[Bindable]
private var model:DSSModelLocator = DSSModelLocator.getInstance();
private var parentCanvas:*;
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
		beginFill(0x7c94b7);
		lineTo(baseX + triangleSize, baseY - triangleSize/2);
		lineTo(baseX + triangleSize, baseY + triangleSize/2);
		lineTo(baseX, baseY);
	}
	// the object we need to work with has been passed to us... why would there ever be a need to go searching for the object when that object was known to the caller of this function ?!?  Doh !
	if (!parentCanvas) {
		parentCanvas = Canvas(Utils.findAncestorOfType(this, Canvas));
	}
	if (parentCanvas != null) {
		form = Panel(parentCanvas.addChild(this.removeChild(form)));
	
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
	} else {
		AlertPopUp.error("showForm() :: Programming Error - Unable to resolve the parent to a known object, are you sure you used the correct parameters when calling this function ?");
	}
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
