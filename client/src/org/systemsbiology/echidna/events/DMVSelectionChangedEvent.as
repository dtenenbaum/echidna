package org.systemsbiology.echidna.events
{
	import flash.events.Event;

	public class DMVSelectionChangedEvent extends Event
	{
		public static const DMV_SELECTION_CHANGED_EVENT:String = "dmvSelectionChangedEvent";
		public var message:String;
		
		public function DMVSelectionChangedEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
	}
}