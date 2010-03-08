package org.systemsbiology.echidna.events
{
	import flash.events.Event;

	public class SearchResultsReturnedEvent extends Event
	{
		public static const SEARCH_RESULTS_RETURNED_EVENT:String = "searchResultsReturnedEvent";
		
		public var searchTerms:Array;
		
		public function SearchResultsReturnedEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
	}
}