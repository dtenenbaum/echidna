package org.systemsbiology.echidna.common
{
	import mx.controls.Alert;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.http.HTTPService;
	
	public class Util
	{
		public function Util()
		{
		}
		
		public static function foo():void {
			
		}
		
		
		public static function ajaxFault(event:FaultEvent):void {
			trace("ajax fault!");
			trace(event.message);
			Alert.show("Server error!");
		}
		
		
		public static function ajax(url:String, params:Object, result:Function, fault:Function): void {
			var service:HTTPService = new HTTPService();
			service.url = url;
			service.resultFormat = "text";
			service.addEventListener(ResultEvent.RESULT, result);
			service.addEventListener(FaultEvent.FAULT, fault);
			service.send(params);
		}
		

	}
}