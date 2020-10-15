
import com.bigfix.dss.util.WatcherManager;
import mx.binding.utils.BindingUtils;
import com.bigfix.dss.vo.WidgetVO;

private function filterWidgets(text:String, model:DSSModelLocator) :void{
	model.widgets.filterFunction = function(item:WidgetVO):Boolean{
		return item.name.match(text) != null;
	}
	model.widgets.refresh();
}


private function createWidget(model:DSSModelLocator):void {
	model.previousDashboardViewState = model.dashboardViewState;
	model.dashboardViewState = 'CreateWidget';
}