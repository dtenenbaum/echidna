package org.systemsbiology.echidna.events
{
	public class EchidnaSelectionChangedEvent extends DMVSelectionChangedEvent
	{
		public static const ECHIDNA_SELECTION_CHANGED_EVENT:String = "echidnaSelectionChangedEvent";
		
		public var url:String;
		public var url2:String;
		public var size:String;
		
		
		
		public function EchidnaSelectionChangedEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}


	}
}