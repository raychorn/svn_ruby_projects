
import com.bigfix.dss.util.WatcherManager;
import mx.binding.utils.BindingUtils;
import com.bigfix.dss.vo.WidgetVO;

private function filterWidgets(event:Event=null) :void{
	model.widgets.filterFunction=function(item:WidgetVO):Boolean{
		return item.name.match(searchText.text) != null;
	}
	model.widgets.refresh();
}


private function createWidget():void {
	model.previousDashboardViewState = model.dashboardViewState;
	model.dashboardViewState = 'CreateWidget';
}