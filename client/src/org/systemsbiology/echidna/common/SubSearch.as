package org.systemsbiology.echidna.common
{
	public class SubSearch
	{
		
		public var envPert:String;
		public var knockout:String;
		
		public var refine:Boolean = false;
		public var includeRelated:Boolean;
		
		public var lastResultsOptionSelected:String = null;
		
		
		public function SubSearch()
		{
		}
		
		
		public function toString():String {
			var s:String = "\tenv pert: " + envPert + "\n";
			s += "\tknockout: " + knockout + "\n";
			s += "\trefine: " + refine + "\n";
			s += "\tinclude related: " + includeRelated + "\n";
			s += "\tlast results option selected: " + lastResultsOptionSelected + "\n";
			
			return s;
		}

	}
}