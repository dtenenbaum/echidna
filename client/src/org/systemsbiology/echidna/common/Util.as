package org.systemsbiology.echidna.common
{
	import mx.collections.ArrayCollection;
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
		
		
		public static function ajax(url:String, params:Object, result:Function, fault:Function, method:String = "GET"): void {
			var service:HTTPService = new HTTPService();
			service.url = url;
			service.method = method;
			service.resultFormat = "text";
			service.addEventListener(ResultEvent.RESULT, result);
			service.addEventListener(FaultEvent.FAULT, fault);
			service.send(params);
		}
		
		
		public static function objectToArrayCollection(obj:Object, type:String):ArrayCollection {
			var ac:ArrayCollection = new ArrayCollection();
			for (var i:Object in obj) {
				var item:Object = obj[i][type];
				ac.addItem(item);
			}
			return ac;
		}


	}
}