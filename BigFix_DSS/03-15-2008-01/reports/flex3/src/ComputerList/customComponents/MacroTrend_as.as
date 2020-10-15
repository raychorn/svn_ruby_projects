/*
 GENERAL NOTEs:
 the term 'node' here refers to the selected element in the GroupTree
 'rangeOverlay' is the layer the user interacts with to select an area of the graph
*/
import mx.core.Application;
import mx.rpc.events.ResultEvent;
import mx.charts.HitData;
import mx.containers.dividedBoxClasses.BoxDivider;
import mx.events.DividerEvent;
import flash.events.MouseEvent;

private const MAX_ZOOM_DAYS:int = 10;
private const DEFAULT_ZOOM_DAYS:int = 30;
private var maxZoomPixelWidth:Number;

// yay! magic numbers!
private const MAGIC_NUMBER_DIVIDER_LEFT_PADDING:Number = 2;
private const MAGIC_NUMBER_GUTTER_LEFT_PADDING:Number = 1.5;

// publicly exported vars
[Bindable]
public var nodeData:XML; // exports the line series data. In the case where the DetailTrend shows the same data as the MacroTrend...
[Bindable]
public var dateRange:Object = {startEpoch: 0, endEpoch: 0}; // exports the currently selected date range set by rangeOverlay

private var _nodeInfo:XML; // private tracking of nodeInfo

// bindable setter for nodeInfo
[Bindable]
public function set nodeInfo(value:XML):void {
	_nodeInfo = value;
	fetchData();
}
public function get nodeInfo():XML {
	return _nodeInfo;
}

private var _metricID:uint; // private tracking of metricID
// bindable setter for metricID
[Bindable]
public function set metricID(value:uint):void {
	_metricID = value;
	fetchData();
}
public function get metricID():uint {
	return _metricID;
}

/* CHART METHODS */
public function fetchData():void {
	if (_nodeInfo.@id != undefined && _metricID != 0) { // make sure we know what we're asking for!
		dataService.url = dataSourceURL + '/' + _nodeInfo.@id + '/' + _metricID;
		dataService.send();
	}
}

private function loadData(event:ResultEvent):void {
	nodeData = event.result as XML;
	this.dataProvider = nodeData.trends.trend[0].dataPoint;
	this.validateNow();
	// figure out the maxZoomPixelWidth
	maxZoomPixelWidth = this.dataToLocal(86400 * 1000 * MAX_ZOOM_DAYS,0).x - this.dataToLocal(0,0).x;
	// move the left divider to 'DEFAULT_ZOOM_DAYS'
	var defaultZoomPixelWidth:Number = this.dataToLocal(86400 * 1000 * DEFAULT_ZOOM_DAYS,0).x - this.dataToLocal(0,0).x;
	rangeOverlay.moveDivider(0,-defaultZoomPixelWidth + (rightDivider.x + rightDivider.width) - (leftDivider.x - MAGIC_NUMBER_DIVIDER_LEFT_PADDING));
	convertRangeOverlayToDateRange();
}

/* GRAPH HELPER METHODS */
private function epochToDate(epoch:Number):Date {
	return new Date(epoch);
}
private function dataTipFormatter(hitData:HitData):String {
	var date:Date = new Date(hitData.item.@xValue);
	return '<b>' + hitData.element['displayName'] + '</b><br/>Date: ' + date.toUTCString() + '<br/>Some Metric: ' + hitData.item.@yValue;
}

/* RANGE OVERLAY METHODS */
private var clickedMouseXPos:Number;
private var leftDivider:BoxDivider;
private var rightDivider:BoxDivider;

private function initRangeOverlay(event:Event):void {
	leftDivider = rangeOverlay.getDividerAt(0);
	rightDivider = rangeOverlay.getDividerAt(1);
}

private function rangeOverlayStartDrag(event:MouseEvent):void {
	clickedMouseXPos = event.stageX;
	rangeOverlay.addEventListener(MouseEvent.MOUSE_MOVE, rangeOverlayMove);
	rangeOverlay.addEventListener(MouseEvent.MOUSE_UP, rangeOverlayStopDrag);
	rangeOverlay.addEventListener(MouseEvent.ROLL_OUT, rangeOverlayStopDrag);
}

private function rangeOverlayStopDrag(event:MouseEvent):void {
	rangeOverlay.removeEventListener(MouseEvent.MOUSE_MOVE, rangeOverlayMove);
	rangeOverlay.removeEventListener(MouseEvent.MOUSE_UP, rangeOverlayStopDrag);
	rangeOverlay.removeEventListener(MouseEvent.ROLL_OUT, rangeOverlayStopDrag);
}

private function rangeOverlayMove(event:MouseEvent):void {
	event.updateAfterEvent();
	var diff:Number = event.stageX - clickedMouseXPos;
	clickedMouseXPos = event.stageX;

	// check if our dividers have hit an edge
	// yeah... 3 is a magic number...
	if ((leftDivider.x <= MAGIC_NUMBER_DIVIDER_LEFT_PADDING && diff < 0) || (rightDivider.x + rightDivider.width >= rangeOverlay.width - 3 && diff > 0)) return;

	rangeOverlay.moveDivider(0, diff);
	rangeOverlay.validateDisplayList(); // this has to be called before moving the other divider
	rangeOverlay.moveDivider(1, diff);
	convertRangeOverlayToDateRange();
}

private function rangeOverlayDividerDrag(event:DividerEvent):void {
	convertRangeOverlayToDateRange();
	if (
		(rightDivider.x + rightDivider.width) - (leftDivider.x - MAGIC_NUMBER_DIVIDER_LEFT_PADDING) < maxZoomPixelWidth &&
		(
			(event.dividerIndex == 0 && event.delta > 0) ||
			(event.dividerIndex == 1 && event.delta < 0)
		)
	) {
		var divider:BoxDivider = event.target.getDividerAt(event.dividerIndex);
		divider.dispatchEvent(new MouseEvent(MouseEvent.MOUSE_UP));
	}
}

private function convertRangeOverlayToDateRange():void {
	var startEpoch:Number = this.localToData(new Point(leftDivider.x - MAGIC_NUMBER_DIVIDER_LEFT_PADDING + this.computedGutters.x + MAGIC_NUMBER_GUTTER_LEFT_PADDING, 0))[0];
	var endEpoch:Number = this.localToData(new Point(rightDivider.x + rightDivider.width + this.computedGutters.x + MAGIC_NUMBER_GUTTER_LEFT_PADDING, 0))[0];
	//trace("based on the left divider.x = " + rangeOverlay.getDividerAt(0).x + " makes date: " + (new Date(startEpoch)).toUTCString());
	//trace("based on the right divider, makes date: " + (new Date(endEpoch)).toUTCString());
	dateRange = {startEpoch: startEpoch, endEpoch: endEpoch};
}
