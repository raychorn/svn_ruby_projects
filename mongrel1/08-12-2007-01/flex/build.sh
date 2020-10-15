#!/bin/sh
export PATH=$PATH:"/Applications/Adobe Flex Builder 2/Flex SDK 2/bin"
mxmlc -compiler.services ../config/WEB-INF/flex/services-config.xml -compiler.context-root ../config/WEB-INF/flex -compiler.library-path+=libs -output ../public/swfs/dss.swf dss.mxml
