/*
 GENERAL NOTEs:
 the term 'node' here refers to the selected element in the GroupTree
*/
import mx.core.Application;
import mx.controls.Alert;
import mx.rpc.events.ResultEvent;
import mx.events.FlexEvent;
import mx.charts.HitData;
import mx.charts.series.AreaSeries;
import mx.charts.series.LineSeries;
import mx.charts.series.renderData.AreaSeriesRenderData;
import mx.charts.series.renderData.LineSeriesRenderData;
import mx.charts.series.PlotSeries;
import mx.graphics.Stroke;
import customComponents.objects.TrendChartOptions;
import customComponents.events.MultiplePropertyChangeEvent;

// public vars
[Bindable]
public var trendChartOptions:TrendChartOptions;

// exported vars: deltaTypes
[Bindable]
public var deltaTypes:Array = [];

// color wheel for line series
private var colorWheel:Array = [0x8f56a2, 0x5970A4, 0xb18467, 0xb0b631, 0xe4b61b];

private function init():void {
	trendChartOptions.addEventListener(MultiplePropertyChangeEvent.CHANGE, handleOptionsChange);
	remoteService.getDetailTrend.send();
}

public function set unselectedDeltaTypeIDs(value:Array):void {
	for (var i:int = 0; i < series.length; i++) {
		if (series[i] is PlotSeries) {
			if (value.indexOf(series[i].name) != -1) {
				series[i].visible = false;
			} else {
				series[i].visible = true;
			}
		}
	}
}

// this is fired when trendChartOptions change
private function handleOptionsChange(event:MultiplePropertyChangeEvent):void {
	// only refresh if the properties of: computer_group_id or metric_id changed
	if (event.containsProperties(['computer_group_id', 'metric_id', 'filters'])) {
		remoteService.getDetailTrend.send();
	}
	if (event.containsProperties(['startEpoch', 'endEpoch'])) {
		refreshDataProviders();
	}
}

// This gets called after we create series or the startEpoch/endEpoch of the trendChartOptions changes
private function refreshDataProviders():void {
	for each (var dataSeries:LineSeries in areaSet.series) {
		dataSeries.dataProvider.refresh();
	}
	for (var i:int = 1; i < this.series.length; i++) {
		this.series[i].dataProvider.refresh();
	}
}

// this is attached as the result event handler of the remoteService.getDetailTrend() call
private function createSeries(event:ResultEvent):void {
	// blank stuff out
	areaSet.series = [];
	series = [areaSet];

	/*******************************
	 first create the AreaSeries
	*******************************/
	//var trendSeries:AreaSeries; (currently not stacked)
	var trendSeries:LineSeries;
	var colorCounter:int = 0;
	for each (var trend:Object in event.result.trend_data) {
		trendSeries = new LineSeries();
		trendSeries.name = trend.id; // dataSeries.name will be the computer group ID!
		trendSeries.displayName = trend.name;
		trendSeries.xField = "xValue";
		trendSeries.yField = "yValue";
		trendSeries.dataProvider = trend.data;
		trendSeries.dataProvider.filterFunction = limitTrendToDateRange;
		trendSeries.setStyle('lineStroke',new Stroke(colorWheel[colorCounter % colorWheel.length], 1));
		areaSet.series.push(trendSeries);
		colorCounter++;
	}
	// these next couple lines ensure stackiness (currently not stacked)
	//areaSet.type = 'stacked';
	areaSet.series = areaSet.series;
	//areaSet.stack();
	this.series = this.series;
	this.validateNow();

	/*******************************
	 now create the PlotSeries
	*******************************/
	// first build a cache of render data for each computer group
	var areaSetRenderData:Object = {};
	for (var i:int = 0; i < areaSet.series.length; i++) {
		areaSetRenderData[areaSet.series[i].name] = areaSet.series[i].getRenderDataForTransition('foo');
		//trace("computer group ID: " + this.series[0].series[i].name + " has cache of " + areaSeriesRenderData[this.series[0].series[i].name].cache);
	}

	// clean up our datasource by adding the attribute 'yValue' to each <dataPoint> element.
	var deltaEventSeries:PlotSeries;
	var tmpDeltaTypes:Array = [];
	for each (var deltaType:Object in event.result.delta_data) {
		for each (var deltaEvent:Object in deltaType.events) {
			// set a default value for the property 'yValue'
			deltaEvent.yValue = -1;
			if (deltaEvent.computer_group_id == null) {
				deltaEvent.yValue = 0;
				continue;
			}
			deltaEvent.xValue = parseInt(deltaEvent.xValue);
			/*
			trace("fdsa fdsa");
			deltaEvent.foo = 'fdsafdsa';
			for (var propz:String in deltaEvent) {
				trace(propz, " = ", deltaEvent[propz]);
			}

			break;
			*/

			// binary search for this xValue in the corresponding trend series data
			var renderData:LineSeriesRenderData = areaSetRenderData[deltaEvent.computer_group_id];
			var low:int = 0;
			var high:int = renderData.cache.length - 1;
			var mid:int;
			var yNumber:int = -1;

			// make sure we're not out of bounds for this given X point for this computer group trend
			if (deltaEvent.xValue < renderData.cache[low].xValue || deltaEvent.xValue > renderData.cache[high].xValue) {
				//trace("deltaEvent.xValue (",deltaEvent.xValue,") is outside of the range:",renderData.cache[low].xValue," - ",renderData.cache[high].xValue);
				//delete event;
				continue;
			}

			while (low <= high) {
				mid = (low + high) >>> 1;

				if (renderData.cache[mid].xNumber < deltaEvent.xValue) {
					low = mid + 1;
				} else if (renderData.cache[mid].xNumber > deltaEvent.xValue) {
					high = mid - 1;
				} else {
					yNumber = renderData.cache[mid].yNumber;
					break;
				}
			}
			// if we didn't find an exact match, yNumber will be -1. We'll find the mid point between the last searched point and the next to call it good
			if (yNumber == -1) {
				yNumber = (renderData.cache[low].yNumber + renderData.cache[high].yNumber)/2;
				//trace("didn't find an exact match for xValue of " + deltaEvent.xValue + " ! setting yNumber to " + yNumber);
			}
			deltaEvent.yValue = yNumber;
		}

		// now we can represent this delta type as a plot series
		//addPlotSeries(deltaType);
		//trace("creating a plotseries for delta type ",deltaType.name, " with ", deltaType.events.length ," events");
		var plotSeries:PlotSeries = new PlotSeries();
		plotSeries.name = deltaType.id;
		plotSeries.xField = "xValue";
		plotSeries.yField = "yValue";
		plotSeries.displayName = deltaType.name;
		plotSeries.dataProvider = deltaType.events;
		plotSeries.dataProvider.filterFunction = limitDeltaEventsToDateRange;
		series.push(plotSeries);
		tmpDeltaTypes.push({id: deltaType.id, name: deltaType.name});
	}
	series = series;
	//this.validateNow();

	refreshDataProviders();

	// finally export the deltaTypes array so DeltaTypeLegend can pick it up
	trace("setting deltaTypes to ",tmpDeltaTypes);
	deltaTypes = tmpDeltaTypes;
}

/* GRAPH HELPER METHODS */
private function epochToDate(epoch:Number):Date {
	return new Date(epoch);
}

private function dataTipFormatter(hitData:HitData):String {
	var date:Date = epochToDate(hitData.item.xValue);
	return '<b>' + hitData.element['displayName'] + '</b><br/>Date: ' + date.toUTCString() + '<br/>Some Metric: ' + hitData.item.yValue;
}

// filter function to limit trend AreaSeries to the selected dateRange
private function limitTrendToDateRange(item:Object):Boolean {
	return (parseInt(item.xValue) >= trendChartOptions.startEpoch && parseInt(item.xValue) <= trendChartOptions.endEpoch);
}

// filter function to limit deltaEvent PlotSeries to the selected dateRange
private function limitDeltaEventsToDateRange(item:Object):Boolean {
	// special hack here for deltaPoints with a yValue of -1
	if (item.yValue == -1) return false;
	return (item.xValue >= trendChartOptions.startEpoch && item.xValue <= trendChartOptions.endEpoch);
}

