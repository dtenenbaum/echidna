package org.systemsbiology.echidna.common
{
	import mx.effects.easing.Elastic;
	
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
		
		public function briefName():String {
			var s:String = "";
			if (envPert != null && knockout != null) {
				s = knockout + "/" + envPert;
			} else if (envPert == null && knockout != null) {
				s = knockout;
			} else if (envPert != null && knockout == null) {
				s = envPert;
			} else {
				s = "(blank)";
			}
			
			return s;
		}

	}
}