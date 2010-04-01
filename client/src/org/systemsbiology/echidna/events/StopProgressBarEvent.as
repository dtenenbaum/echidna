package org.systemsbiology.echidna.events
{
	import flash.events.Event;
	
	//todo - rename this. the name breaks MVC as this event is just supposed to tell you that an ajax call failed. it's up to
	// the caller to decide what to do (for example, stop a progress bar).
	public class StopProgressBarEvent extends Event
	{
		public static const STOP_PROGRESS_BAR_EVENT:String = "stopProgressBarEvent";
		
		public function StopProgressBarEvent(type:String, bubbles:Boolean=true, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
	}
}