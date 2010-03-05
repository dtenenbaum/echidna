package org.systemsbiology.echidna.events
{
	import flash.events.Event;

	public class StartProgressBarEvent extends Event
	{
		public static const START_PROGRESS_BAR_EVENT:String = "startProgressBarEvent";
		
		public function StartProgressBarEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
	}
}