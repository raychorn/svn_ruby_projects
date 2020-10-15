package customComponents.events {
	import flash.events.Event;
	import mx.events.PropertyChangeEvent;

	/* this class is intended for use with the TransactionalObjectProxy class
	This event represents multiple PropertyChangeEvents as a result of
	multiple properties, of a TransactionalObjectProxy instance, being changed
	within a transaction.
	There are two helper methods where which allow you to ask if one or many
	property names had PropertyChangeEvents within this MultiplePropertyChangeEvent
	*/
	public class MultiplePropertyChangeEvent extends Event {
		public var propertyEvents:Array;
		public static const CHANGE:String = "multiplePropertiesChanged";

		public function MultiplePropertyChangeEvent(propertyEventArray:Array = null) {
			super(CHANGE);
			propertyEvents = propertyEventArray;
		}

		public function containsProperties(propertyNames:Array):Boolean {
			for each (var propertyEvent:PropertyChangeEvent in propertyEvents) {
				if (propertyNames.indexOf(propertyEvent.property) !== -1) {
					return true;
				}
			}
			return false;
		}

		public function containsProperty(propertyName:String):Boolean {
			return containsProperties([propertyName]);
		}

		override public function clone():Event {
			return new MultiplePropertyChangeEvent(propertyEvents);
		}

	}
}
