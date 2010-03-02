package org.systemsbiology.echidna.ui
{
	import flash.display.DisplayObject;
	
	import mx.controls.Alert;
	import mx.rpc.events.FaultEvent;
	
	import org.systemsbiology.echidna.events.StopProgressBarEvent;
	
	public class EchidnaAjaxFault
	{
		
		private var dispObj:DisplayObject;
		
		public function EchidnaAjaxFault(dispObj:DisplayObject)
		{
			this.dispObj = dispObj;	
		}


		public function ajaxFault(event:FaultEvent):void {
			trace("ajax fault!");
			trace(event.message);
			var spbe:StopProgressBarEvent = new StopProgressBarEvent(StopProgressBarEvent.STOP_PROGRESS_BAR_EVENT);
			if (dispObj != null) {
				dispObj.dispatchEvent(spbe);
			}
			Alert.show("Server error!");
		}



	}
}