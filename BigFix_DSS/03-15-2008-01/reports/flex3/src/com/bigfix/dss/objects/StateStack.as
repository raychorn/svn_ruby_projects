package com.bigfix.dss.objects {
	import flash.utils.Timer;
	import flash.events.TimerEvent;
	import com.bigfix.dss.view.general.Alert.AlertPopUp;
	
	public class StateStack {
		private var _stateStack:Array;
		
		private var _guiElement:*;
		
		private var _stateHash:Object;
		
		public function StateStack(guiElement:*) {
			this._guiElement = guiElement;
			this._stateHash = new Object();
			this._stateStack = new Array();
		}
		
		public function set guiElement(guiElement:*):void {
			this._guiElement = guiElement;
		}
		
		public function get guiElement():* {
			return this._guiElement;
		}

		public function pushState(state:String):void {
			try {
				this._stateStack.push(this.guiElement.currentState);
				this.guiElement.currentState = state;
			} catch (err:Error) { }
		}
		
		public function pushStateOnce(state:String):void {
			if ( (state != null) && (state.length > 0) && (this.guiElement.currentState != state) ) {
				try {
					this._stateStack.push((this.guiElement.currentState == null) ? '' : this.guiElement.currentState);
					this.guiElement.currentState = state;
				} catch (err:Error) { }
			} else {
				var stateName:String = this._stateStack[this._stateStack.length - 1];
				var dt:DelayedTimer = this._stateHash[stateName];
				if ( (dt != null) && (dt.running) ) {
					dt.reset();
					dt.start();
				}
			}
		}
		
		public function popState():void {
			try { this.guiElement.currentState = this._stateStack.pop(); } catch (err:Error) { }
		}

		private function onTimerComplete(event:TimerEvent):void {
			var stateName:String = this._stateStack.pop();
			try { this.guiElement.currentState = stateName; } catch (err:Error) { }
			var dt:DelayedTimer = this._stateHash[stateName];
			if ( (dt != null) && (dt.running) ) {
				dt.stop();
			}
			this._stateHash[stateName] = null;
		}
		
		public function popStateDelayed():void {
			if (this._stateStack.length > 0) {
				var stateName:String;
				try { stateName = this._stateStack[this._stateStack.length - 1]; } catch (err:Error) { AlertPopUp.error(err.toString(), "Error in popStateDelayed() !"); }
				if ( (stateName != null) && (stateName.length >= 0) ) {
					if (this._stateHash[stateName] == null) {
						var dt:DelayedTimer = new DelayedTimer(1000, 2);
						dt.addEventListener(TimerEvent.TIMER_COMPLETE, onTimerComplete);
	//					dt.addEventListener(TimerEvent.TIMER, onTimerTick);
						dt.start();
						this._stateHash[stateName] = dt;
					}
				}
			}
		}
	}
}