package org.systemsbiology.echidna.common
{
	import mx.collections.ArrayCollection;
	
	public class SearchTerms
	{
		
		public var knockouts:ArrayCollection = new ArrayCollection();
		public var envPerts:ArrayCollection = new ArrayCollection();
		public var searchTerms:ArrayCollection = new ArrayCollection();
		public var lastUpdated:int = -1;
		
		
		
		public function SearchTerms()
		{
		}

	}
}