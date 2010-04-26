package org.systemsbiology.echidna.events
{
	import flash.events.Event;

	public class ImportStatusEvent extends Event
	{
		public static const IMPORT_STATUS_EVENT:String = "importStatusEvent";
		public var alreadyImported:Boolean;
		
		public function ImportStatusEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
	}
}