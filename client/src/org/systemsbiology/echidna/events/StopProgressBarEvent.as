package org.systemsbiology.echidna.events
{
	import flash.events.Event;

	public class StopProgressBarEvent extends Event
	{
		public static const STOP_PROGRESS_BAR_EVENT:String = "stopProgressBarEvent";
		
		public function StopProgressBarEvent(type:String, bubbles:Boolean=true, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
	}
}