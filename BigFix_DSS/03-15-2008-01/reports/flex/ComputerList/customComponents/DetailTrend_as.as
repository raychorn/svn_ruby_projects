/*
 GENERAL NOTEs:
 the term 'node' here refers to the selected element in the GroupTree
*/
import mx.core.Application;
import mx.rpc.events.ResultEvent;
import mx.charts.HitData;
import mx.charts.series.AreaSeries;
import mx.charts.series.renderData.AreaSeriesRenderData;
import mx.charts.series.PlotSeries;

// exported vars: deltaTypes
[Bindable]
public var deltaTypes:Array = [];
private var _deltaTypes:Array = [];

// macroTrendNodeData. in case the detail graph shows only one series, just reuse the data loaded in the macrotrend chart
private var _macroTrendNodeData:XML = null;
[Bindable]
public function set macroTrendNodeData(value:XML):void {
	_macroTrendNodeData = value;
	fetchTrendData();
}
public function get macroTrendNodeData():XML {
	return _macroTrendNodeData;
}

private var _nodeInfo:XML; // private tracking of nodeInfo
// bindable setter for nodeInfo
[Bindable]
public function set nodeInfo(value:XML):void {
	_nodeInfo = value;
}
public function get nodeInfo():XML {
	return _nodeInfo;
}

private var _metricID:uint; // private tracking of metricID
// bindable setter for metricID
[Bindable]
public function set metricID(value:uint):void {
	_metricID = value;
	fetchTrendData();
}
public function get metricID():uint {
	return _metricID;
}

private var _dateRange:Object; // private tracking of dateRange
// bindable setter for metricID
[Bindable]
public function set dateRange(value:Object):void {
	_dateRange = value;
	for each (var dataSeries:AreaSeries in areaSet.series) {
		dataSeries.dataProvider.refresh();
	}
	for (var i:int = 1; i < this.series.length; i++) {
		this.series[i].dataProvider.refresh();
	}

}
public function get dateRange():Object {
	return _dateRange;
}

private var _hiddenDeltaTypeIDs:Array; // private tracking of hiddenDeltaTypeIDs
// bindable setter for hiddenDeltaTypeIDs
[Bindable]
public function set hiddenDeltaTypeIDs(value:Array):void {
	_hiddenDeltaTypeIDs = value;
	hideDeltaTypes();
}
public function get hiddenDeltaTypeIDs():Array {
	return _hiddenDeltaTypeIDs;
}

/* CHART METHODS */
private function fetchTrendData():void {
	if (_nodeInfo.@id != undefined && _metricID != 0 && _macroTrendNodeData != null) { // make sure we know what we're asking for and that all dependencies are loaded!
		// clear all series, leaving the areaSet intact
		areaSet.series = [];
		this.series = [areaSet];
		areaSet.visible = false;
		if (_nodeInfo.node.length()) {
			dataServiceTrend.url = dataSourceURLTrend + '/' + _nodeInfo.@id + '/' + _metricID;
			dataServiceTrend.send();
		} else {
			var dataSeries:AreaSeries = new AreaSeries();
			dataSeries.name = _nodeInfo.@id; // dataSeries.name will be the computer group ID!
			dataSeries.displayName = _nodeInfo.@name;
			dataSeries.xField = "@xValue";
			dataSeries.yField = "@yValue";
			dataSeries.dataProvider = _macroTrendNodeData.trends.trend[0].dataPoint;
			areaSet.series.push(dataSeries);
			forceRedraw();
			fetchDeltaEvents();
		}
	}
}

private function loadTrendData(event:ResultEvent):void {
	var xmlData:XML = event.result as XML;
	var dataSeries:AreaSeries;
	for each (var trend:XML in xmlData.trends.trend) {
		dataSeries = new AreaSeries();
		dataSeries.name = trend.@computer_group_id; // dataSeries.name will be the computer group ID!
		dataSeries.displayName = _nodeInfo.node.(@id == trend.@computer_group_id).@name;
		dataSeries.xField = "@xValue";
		dataSeries.yField = "@yValue";
		dataSeries.dataProvider = trend.dataPoint;
		areaSet.series.push(dataSeries);
	}
	forceRedraw();
	fetchDeltaEvents();
}

private function fetchDeltaEvents():void {
	dataServiceDeltaEvents.url = dataSourceURLDeltaEvents + '/' + _nodeInfo.@id + '/' + _metricID;
	dataServiceDeltaEvents.send();
}

private function loadDeltaEvents(event:ResultEvent):void {
	_deltaTypes = [];
	// first build a cache of render data for each computer group
	var areaSetRenderData:Object = {};
	for (var i:int = 0; i < areaSet.series.length; i++) {
		areaSetRenderData[areaSet.series[i].name] = areaSet.series[i].getRenderDataForTransition('foo');
		//trace("computer group ID: " + this.series[0].series[i].name + " has cache of " + areaSeriesRenderData[this.series[0].series[i].name].cache);
	}
	var xmlData:XML = event.result as XML;

	// clean up our datasource by adding the attribute 'yValue' to each <dataPoint> element.
	for each (var deltaType:XML in xmlData.deltaType) {
		if (deltaType.deltaEvent[0].@computer_group_id == '') {
			for (var g:int = 0; g < deltaType.deltaEvent.length(); g++) {
				deltaType.deltaEvent[g].@yValue = 0;
			}
		} else {
			for (var e:int = 0; e < deltaType.deltaEvent.length(); e++) {
				var deltaEvent:XML = deltaType.deltaEvent[e];
				var renderData:AreaSeriesRenderData = areaSetRenderData[deltaEvent.@computer_group_id];

				// binary search for this xValue
				var low:int = 0;
				var high:int = renderData.cache.length - 1;
				var mid:int;
				var yNumber:int = -1;

				// make sure we're not out of bounds for this given X point for this computer group trend
				if (deltaEvent.@xValue < renderData.cache[low].xValue || deltaEvent.@xValue > renderData.cache[high].xValue) {
					delete deltaType.deltaEvent[e];
					e--;
					continue;
				}

				while (low <= high) {
					mid = (low + high) >>> 1;

					if (renderData.cache[mid].xNumber < deltaEvent.@xValue) {
						low = mid + 1;
					} else if (renderData.cache[mid].xNumber > deltaEvent.@xValue) {
						high = mid - 1;
					} else {
						yNumber = renderData.cache[mid].yNumber;
						break;
					}
				}
				if (yNumber == -1) {
					yNumber = (renderData.cache[low].yNumber + renderData.cache[high].yNumber)/2;
					//trace("didn't find an exact match for xValue of " + deltaEvent.@xValue + " ! setting yNumber to " + yNumber);
				}
				deltaEvent.@yValue = yNumber;
			}
		}
		addPlotSeries(deltaType);
	}
	this.series = this.series;
	this.validateNow();
	setDataFilters();
	deltaTypes = _deltaTypes;
}

private function addPlotSeries(deltaType:XML):void {
	var plotSeries:PlotSeries;
	plotSeries = new PlotSeries();
	plotSeries.name = deltaType.@id;
	plotSeries.xField = "@xValue";
	plotSeries.yField = "@yValue";
	plotSeries.displayName = deltaType.@name;
	plotSeries.dataProvider = deltaType.deltaEvent;
	plotSeries.dataProvider.filterFunction = limitToDateRange;
	plotSeries.dataProvider.refresh();
	this.series.push(plotSeries);
	_deltaTypes.push({id: deltaType.@id, name: deltaType.@name});
}

private function hideDeltaTypes():void {
	for each (var plotSeries:* in this.series) {
		if (plotSeries is PlotSeries) {
			plotSeries.visible = !(_hiddenDeltaTypeIDs.indexOf(plotSeries.name) !== -1);
		}
	}
}

/* GRAPH HELPER METHODS */
private function epochToDate(epoch:Number):Date {
	return new Date(epoch);
}
private function dataTipFormatter(hitData:HitData):String {
	var date:Date = new Date(hitData.item.@xValue);
	return '<b>' + hitData.element['displayName'] + '</b><br/>Date: ' + date.toUTCString() + '<br/>Some Metric: ' + hitData.item.@yValue;
}

private function limitToDateRange(item:Object):Boolean {
	return (item.@xValue >= _dateRange.startEpoch && item.@xValue <= _dateRange.endEpoch);
}
private function setDataFilters():void {
	for (var i:int = 0; i < areaSet.series.length; i++) {
		areaSet.series[i].dataProvider.filterFunction = limitToDateRange;
		areaSet.series[i].dataProvider.refresh();
	}
	areaSet.visible = true;
}
private function forceRedraw():void {
	areaSet.type = 'stacked';
	areaSet.series = areaSet.series;
	areaSet.stack();
	this.series = this.series;
	this.validateNow();
}

