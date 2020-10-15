// JavaScript Document
function _int(val) {
	return parseInt(val.toString().split('.')[0]);
}
	
function daysInMonth(iMonth, iYear) {
	return 32 - new Date(iYear, iMonth, 32).getDate();
}

var monthname = ["January","February","March","April","May","June","July","August","September","October","November","December"];

var endings = [];
endings[0] = '';
endings[1] = 'st';
endings[2] = 'nd';
endings[3] = 'rd';
endings[4] = 'th';
endings[5] = 'th';
endings[6] = 'th';
endings[7] = 'th';
endings[8] = 'th';
endings[9] = 'th';
	
