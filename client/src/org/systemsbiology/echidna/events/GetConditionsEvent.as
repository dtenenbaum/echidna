package org.systemsbiology.echidna.events
{
	import flash.events.Event;

	public class GetConditionsEvent extends Event
	{
		public static const GET_CONDITIONS_EVENT:String = "getConditionsEvent";
		
		public function GetConditionsEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
	}
}