package org.systemsbiology.echidna.events
{
	import flash.events.Event;
	
	public class RenameTagEvent extends Event
	{
		
		public static const RENAME_TAG_EVENT:String = "renameTagEvent";
		
		public var newName:String;
		
		public function RenameTagEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}