package org.systemsbiology.echidna.ui
{
	
	// TODO - move this out of ui package
	import flash.events.EventDispatcher;
	
	import mx.controls.Alert;
	import mx.rpc.events.FaultEvent;
	
	import org.systemsbiology.echidna.events.StopProgressBarEvent;
	
	public class EchidnaAjaxFault extends EventDispatcher
	{
		
		
		public function EchidnaAjaxFault()
		{
		}

	
		public function ajaxFault(event:FaultEvent):void {
			trace("ajax fault!");
			trace(event.message);
			//todo - send a more generic event
			var spbe:StopProgressBarEvent = new StopProgressBarEvent(StopProgressBarEvent.STOP_PROGRESS_BAR_EVENT);
			dispatchEvent(spbe);
			Alert.show("Server error!");
		}



	}
}