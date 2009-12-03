package org.systemsbiology.echidna.events
{
	import flash.events.Event;

	public class GotNewGroupNameEvent extends Event
	{
		public static const GOT_NEW_GROUP_NAME_EVENT:String = "gotNewGroupNameEvent";
		
		public var groupName:String;
		
		public function GotNewGroupNameEvent(type:String)
		{
			super(type);
		}
		
	}
}