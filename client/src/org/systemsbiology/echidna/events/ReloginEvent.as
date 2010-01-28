package org.systemsbiology.echidna.events
{
	import flash.events.Event;

	public class ReloginEvent extends Event
	{
		public static const RELOGIN_EVENT:String = "reloginEvent";
		
		public function ReloginEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
	}
}