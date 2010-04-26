package org.systemsbiology.echidna.events
{
	import flash.events.Event;

	public class TagNamedEvent extends Event
	{
		public static const TAG_NAMED_EVENT:String = "tagNamedEvent";
		public var tagName:String;
		
		public function TagNamedEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
	}
}