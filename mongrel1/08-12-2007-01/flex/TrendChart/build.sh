#!/bin/sh
mxmlc -compiler.services /usr/local/www/reports/config/WEB-INF/flex/services-config.xml -compiler.context-root /usr/local/www/reports/config/WEB-INF/flex -output ../../public/swfs/TrendChart.swf TrendChart.mxml
