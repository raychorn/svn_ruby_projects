#!/bin/sh
export PATH=$PATH:"/Applications/Adobe Flex Builder 3/sdks/moxie/bin"
mxmlc -compiler.services ../config/WEB-INF/flex/services-config.xml -compiler.context-root ../config/WEB-INF/flex -compiler.library-path+=libs -output ../public/swfs/dss.swf dss.mxml
