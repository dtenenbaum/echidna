package org.systemsbiology.echidna.events
{
	import flash.events.Event;

	public class GotLoginInfoEvent extends Event
	{
		public static const GOT_LOGIN_INFO_EVENT : String = "gotLoginInfoEvent";
		
		public var email:String;	
		
		public function GotLoginInfoEvent(type:String)
		{
			super(type);
		}
		
	}
}