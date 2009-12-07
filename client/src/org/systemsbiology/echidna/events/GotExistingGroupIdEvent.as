package org.systemsbiology.echidna.events
{
	import flash.events.Event;

	public class GotExistingGroupIdEvent extends Event
	{
		
		public static const  GOT_EXISTING_GROUP_ID_EVENT:String = "gotExistingGroupIdEvent";
		
		public var groupId:int;
		
		public function GotExistingGroupIdEvent(type:String)
		{
			super(type);
		}
		
	}
}