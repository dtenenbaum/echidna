package org.systemsbiology.echidna.events
{
	import flash.events.Event;

	public class CreatedRelationshipEvent extends Event
	{
		public static const CREATED_RELATIONSHIP_EVENT:String = "createdRelationshipEvent";
		
		// todo add relationship state members
		
		public function CreatedRelationshipEvent(type:String)
		{
			super(type);
		}
		
	}
}