package org.systemsbiology.echidna.common
{
	public class CurrentlyActiveSearch
	{
		
		public var isStructured:Boolean;
		
		public var freeTextSearch:Array = new Array();
		
		
		public var subSearches:Array = new Array();
		
		public function CurrentlyActiveSearch()
		{
		}
		
		public function toString():String {
			var s:String = "isStructured: " + isStructured + "\n";
			if (isStructured) {
				s += "sub searches:\n";
				for (var x:int = 0; x < subSearches.length; x++) {
					var subSearch:SubSearch = subSearches[x] as SubSearch;
					if (subSearch != null) {
						s += subSearch.toString();
					}
				}
			} else {
				s += "free text terms:\n";
				for (var i:int = 0; i < freeTextSearch.length; i++) {
					s += "\t" + freeTextSearch[i] + "\n";
				}
			}
			return s;
		}
		

	}
}