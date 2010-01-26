package org.systemsbiology.echidna.events
{
	import flash.events.Event;

	public class RegistrationEvent extends Event
	{
		public static const REGISTRATION_EVENT:String = "registrationEvent";
		
		public function RegistrationEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
	}
}