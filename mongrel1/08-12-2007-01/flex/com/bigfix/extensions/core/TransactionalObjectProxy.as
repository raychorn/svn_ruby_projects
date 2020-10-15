package com.bigfix.extensions.core
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import mx.events.PropertyChangeEvent;
	import mx.utils.ObjectProxy;
	import com.bigfix.extensions.events.MultiplePropertyChangeEvent;

	/* This class adds transactions to the standard ObjectProxy class.
	You can call begin(), make chages to multiple properties, then call commit()
	which will send a MultiplePropertyChangeEvent event with type:
	'MultiplePropertyChangeEvent.CHANGE'
	If you make changes to properties outside of a transaction, the normal
	PropertyChangeEvent will be dispatched.
	This class utilizes the MultiplePropertyChangeEvent to represent multiple
	PropertyChangeEvents from a transaction
	*/
	[Event(name=MultiplePropertyChangeEvent.CHANGE)]
	public dynamic class TransactionalObjectProxy extends ObjectProxy {

		private var _inTransaction:Boolean = false;
		private var _queuedPropertyChangeEvents:Array = new Array();

		public function TransactionalObjectProxy(item:Object = null, uid:String = null, proxyDepth:int = -1) {
			super(item, uid, proxyDepth);
			addEventListener(PropertyChangeEvent.PROPERTY_CHANGE, handlePropertyChange, false, 99);
		}

		public function begin():void {
			if (_inTransaction) {
				throw new Error("TransactionalObjectProxy.begin(): You're already in a transaction");
			}
			_inTransaction = true;
			_queuedPropertyChangeEvents = new Array();
		}

		public function commit():void {
			if (!_inTransaction) {
				throw new Error("TransactionalObjectProxy.commit(): You haven't called begin()");
			}
			_inTransaction = false;
			dispatchEvent(new MultiplePropertyChangeEvent(_queuedPropertyChangeEvents));
			_queuedPropertyChangeEvents = new Array();
		}

		private function handlePropertyChange(event:PropertyChangeEvent):void {
			if (_inTransaction) {
				_queuedPropertyChangeEvents.push(event);
				event.stopImmediatePropagation();
			} else {
				dispatchEvent(new MultiplePropertyChangeEvent([event]));
			}
		}
	}
}
