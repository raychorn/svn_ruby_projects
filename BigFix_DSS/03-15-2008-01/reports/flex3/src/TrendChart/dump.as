public function dump(msg:Object):void {
	var dumpStr:String = '';
	switch (typeof(msg)) {
		case "object":
			var xml:XML = describeType(msg);
			dumpStr = dumpStr.concat("\tInstance: ",msg,"\n");
			dumpStr = dumpStr.concat("\tType: ",xml.@name);
			for each (var className:String in xml.extendsClass.@type) {
				dumpStr = dumpStr.concat(" -> ", className);
			}
			//debugMsg = debugMsg.concat("\n",xml,"\n\n");
			break;
		default:
			dumpStr += "\n"+String(msg);
	}
	trace(dumpStr);
}

