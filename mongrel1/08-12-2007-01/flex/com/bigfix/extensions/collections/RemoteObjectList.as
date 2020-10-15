/* This class is used by RemoteObjectCollection. You shouldn't ever need to instantiate this class yourself */
package com.bigfix.extensions.collections {
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.utils.Dictionary;
	import mx.collections.IList;
	import mx.events.CollectionEvent;
	import mx.events.CollectionEventKind;
	import mx.rpc.remoting.mxml.Operation;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.events.FaultEvent;
	import mx.collections.errors.ItemPendingError;
	import mx.rpc.IResponder;

	[Event(name="customReset")]

	public class RemoteObjectList extends Object implements IList {
		/**
		 *  @private
		 *  Internal event dispatcher.
		 */
		private var eventDispatcher:EventDispatcher;

		/**
		 * @private
		 * What we believe the length of the list to be (or -1 if not known).
		 */
		private var _length:int;
		/* Getter */
		public function get length():int { return _length; }

		/**
		 * @private
		 * Our cache of list values.
		 */
		private var cache:Array;

		/**
		 * @private
		 * Array mapping pending pages to the ItemPendingError that was issued.
		 */
		private var pagesPending:Array;

		/**
		 * @private
		 * Array of pages held in memory.
		 */
		private var pages:Array;

		/**
		 * @private
		 * Dictionary mapping async tokens to the page that was requested.
		 */
		private var pageTokens:Dictionary;

		private var ready:Boolean = false;

		/* public vars */
		/**
		 * How many records to prefetch. Defaults to 100
		 */
		public var pageSize:int = 30;

		/**
		 * vars for the remote object
		 */
		public var remoteMethodArgs:*;
		public var listMethod:Operation;
		public var countMethod:Operation;

		public var sortArgs:Array;

		/* Constructor */
		public function RemoteObjectList() {
			super();
			eventDispatcher = new EventDispatcher(this);
		}

		public function refresh():void {
			if (!(remoteMethodArgs && listMethod && countMethod)) {
				//throw new Error("RemoteObjectList isn't ready yet!");
				trace("RemoteObjectList isn't ready yet!");
				return;
			}
			attachEvents();
			pages = new Array();
			pageTokens = new Dictionary();
			cache = new Array();
			pagesPending = new Array();
			_length = -1;
			fetchLength();
		}

		/* custom methods specific to this class */
		private function attachEvents():void {
			if (!listMethod.hasEventListener(ResultEvent.RESULT)) {
				listMethod.addEventListener(ResultEvent.RESULT, gotRows);
			}
			if (!listMethod.hasEventListener(FaultEvent.FAULT)) {
				listMethod.addEventListener(FaultEvent.FAULT, failedToGetRows);
			}
			if (!countMethod.hasEventListener(ResultEvent.RESULT)) {
				countMethod.addEventListener(ResultEvent.RESULT, gotLength);
			}
			if (!countMethod.hasEventListener(FaultEvent.FAULT)) {
				countMethod.addEventListener(FaultEvent.FAULT, failedToGetLength);
			}
		}

		private function fetchLength():void {
			trace("RemoteObjectList.fetchLength()");
			countMethod.send(remoteMethodArgs);
		}
		private function gotLength(e:ResultEvent):void {
			this._length = int(e.result);
			//trace("RemoteObjectList.gotLength() of ", this._length);
			fetchPage(0);
		}

		private function fetchPage(page:int):void {
			trace("RemoteObjectList.fetchPage(", page, ")");
			pageTokens[listMethod.send(remoteMethodArgs, pageSize, page * pageSize, sortArgs)] = page;
			pagesPending[page] = new ItemPendingError("Loading...");
		}

		private function gotRows(e:ResultEvent):void {
			var page:int = pageTokens[e.token];
			//trace("RemoteObjectList.gotRows() ", "for page: ", page, " num rows = ",e.result.length);

			// Dispatch a reset event if this is the first bit of data we've loaded.
			var needReset:Boolean = pages.length == 0;

			pages[page] = e.result;

			try {
				var responders:Array = pagesPending[page].responders;
				responders.forEach(function(item:IResponder, index:int, arr:Array):void { item.result(null); });
			} catch (e:Error) { }


			pagesPending[page] = null;
			pageTokens[e.token] = null;

			if (needReset)
				notifyReset();
		}

		private function cacheMissAt(index:int):void {
			var page:int = Math.floor(index / pageSize);
			if (pagesPending[page] == null)
				fetchPage(page)
			throw pagesPending[page];
		}


		private function notifyReset():void {
			dispatchEvent(new Event("customReset"));
		}

		private function failedToGetLength(e:FaultEvent):void {
			trace("RemoteObjectList.failedToGetLength()");
			trace(e);
		}

		private function failedToGetRows(e:FaultEvent):void {
			trace("RemoteObjectList.failedToGetRows()");

			var page:int = pageTokens[e.token];
			try {
				var responders:Array = pagesPending[page].responders;
				responders.forEach(function(item:IResponder, index:int, arr:Array):void { item.fault(e.fault) });
			} catch (e:Error) { }

			pagesPending[page] = null;
			pageTokens[e.token] = null;
		}

		/* methods enforced by IEventDispatcher, simple passthroughs to the eventDispatcher property */
		public function addEventListener(type:String, listener:Function, useCapture:Boolean=false, priority:int=0.0, useWeakReference:Boolean=false):void {
			eventDispatcher.addEventListener(type, listener, useCapture, priority, useWeakReference);
		}
		public function dispatchEvent(event:Event):Boolean {
			return eventDispatcher.dispatchEvent(event);
		}
		public function hasEventListener(type:String):Boolean {
			return eventDispatcher.hasEventListener(type);
		}
		public function removeEventListener(type:String, listener:Function, useCapture:Boolean=false):void {
			eventDispatcher.removeEventListener(type, listener, useCapture);
		}
		public function willTrigger(type:String):Boolean {
			return eventDispatcher.willTrigger(type);
		}

		/* methods enforced by IList */
		public function getItemAt(index:int, prefetch:int = 0):Object {
			var page:int = Math.floor(index / pageSize);

			if (index < 0 || index > _length) {
				throw new RangeError("List index out of range.");
			}
			if (this.pages[page] == null) {
				cacheMissAt(index);
				return null;
			} else {
				return this.pages[page][index % pageSize];
			}
		}

		/* methods enforced by IList but not implemented */
		public function addItem(item:Object):void {
			throw new Error("Not implemented");
		}
		public function addItemAt(item:Object, index:int):void {
			throw new Error("Not implemented");
		}
		public function getItemIndex(item:Object):int {
			throw new Error("Not implemented");
			return 0;
		}
		public function itemUpdated(item:Object, property:Object=null, oldValue:Object=null, newValue:Object=null):void {
			throw new Error("Not implemented");
		}
		public function removeAll():void {
			throw new Error("Not implemented");
		}
		public function removeItemAt(index:int):Object {
			throw new Error("Not implemented");
			return null;
		}
		public function setItemAt(item:Object, index:int):Object {
			throw new Error("Not implemented");
			return null;
		}
		public function toArray():Array {
			throw new Error("Not implemented");
			return null;
		}
	}
}

