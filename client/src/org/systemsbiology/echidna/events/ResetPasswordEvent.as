package org.systemsbiology.echidna.events
{
	import flash.events.Event;

	public class ResetPasswordEvent extends Event
	{
		public static const RESET_PASSWORD_EVENT:String = "resetPasswordEvent";
		
		public var email:String;
		
		public function ResetPasswordEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
	}
}