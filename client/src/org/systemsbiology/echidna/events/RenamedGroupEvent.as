package org.systemsbiology.echidna.events
{
	import flash.events.Event;

	public class RenamedGroupEvent extends Event
	{
		
		public static const RENAMED_GROUP_EVENT:String = "renamedGroupEvent";
		
		public function RenamedGroupEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
	}
}