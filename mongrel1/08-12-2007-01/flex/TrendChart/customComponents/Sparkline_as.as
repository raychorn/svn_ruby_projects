// public vars
public var trendData:Array;
public var yField:String;

private const HPADDING:int = 0;
private const VPADDING:int = 4;

private var minYValue:Number;
private var maxYValue:Number;
private var horizontalScale:Number;
private var verticalScale:Number;

private function init(event:Event):void {
	findMinMax();

	horizontalScale = (width - (HPADDING * 2))/trendData.length;
	verticalScale = (height - (VPADDING * 2))/(maxYValue - minYValue);

	with (graphics) {
		lineStyle(0, 0x4f4f47, .7, true);
		moveTo(HPADDING, height - VPADDING - ((trendData[0][yField] - minYValue) * verticalScale));
		var lastXPoint:Number;
		var lastYPoint:Number;
		for (var i:int = 1; i < trendData.length; i++) {
			lastXPoint = HPADDING + (i * horizontalScale);
			lastYPoint = height - VPADDING - ((trendData[i][yField] - minYValue) * verticalScale);
			lineTo(lastXPoint, lastYPoint);
		}
		moveTo(lastXPoint, lastYPoint);
		lineStyle(0, 0x000000, 1, true);
		beginFill(0x000000, .5);
		drawCircle(lastXPoint, lastYPoint, 1);
	}
}

private function findMinMax():void {
	minYValue = maxYValue = trendData[0][yField];
	for (var i:int = 0; i < trendData.length; i++) {
		if (minYValue > trendData[i][yField]) {
			minYValue = trendData[i][yField];
		}
		if (maxYValue < trendData[i][yField]) {
			maxYValue = trendData[i][yField];
		}
	}
}