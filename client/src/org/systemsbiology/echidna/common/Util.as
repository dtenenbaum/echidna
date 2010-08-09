package org.systemsbiology.echidna.common
{
	import com.adobe.serialization.json.JSON;
	import com.hillelcoren.components.AutoComplete;
	
	import flash.display.DisplayObject;
	
	import mx.collections.ArrayCollection;
	import mx.controls.DataGrid;
	import mx.managers.IBrowserManager;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.http.HTTPService;
	import mx.utils.StringUtil;
	import mx.utils.URLUtil;
	
	public class Util
	{

		private var dispObj:DisplayObject;


		public function Util(dispObj:DisplayObject)
		{
			this.dispObj = dispObj;
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
		
		public static function getQueryStringItem(bm:IBrowserManager, key:String):String {
			trace("bm.base = " + bm.base);
			trace("bm.url = " + bm.url);
			var segs:Array = bm.base.split("?");
			if (segs.length < 2) {
				return null;
			}
			var temp:String = segs[1];
			segs  = temp.split("#");
			var queryString:String = segs[0];
			trace("query string = " + queryString);
			var params:Object = URLUtil.stringToObject(queryString, "&");
			return(params[key]);
		}
		
		
		public static function getAutoCompleteContentsArray(ac:AutoComplete):Array {
				var tmp:Array = new Array();
				for(var i:int = 0; i < ac.selectedItems.length; i++) {
					trace("item = " + ac.selectedItems[i]);
					if (ac.selectedItems[i].hasOwnProperty('name')) {
						tmp.push(ac.selectedItems[i]['name']);
					} else {
						var items:String = StringUtil.trim(ac.selectedItems[i]);
						if (items.indexOf(" ") > -1) {
							var segz:Array = items.split(" ");
							for (var x:int = 0; x < segz.length; x++) {
								tmp.push(segz[x]);
							}
						} else {
							tmp.push(items);
						}
						
					}
				}
				
				if (tmp.length == 0) {
					if (ac.searchText.indexOf(" ") > -1) {
						var segs:Array = StringUtil.trim(ac.searchText).split(" ");
						for (var j:int = 0; j < segs.length; j++) {
							tmp.push(segs[j]);
						}
					} else {
						tmp.push(ac.searchText);
					}
				}
				return tmp;			

			}

		public static function getAutoCompleteContents(ac:AutoComplete):String {
			var tmp:Array = getAutoCompleteContentsArray(ac);
			var ret:String = JSON.encode(tmp);
			trace("getAutoCompleteContents returning: " + ret);
			return ret;
		}	
		
		
		public static function getSelectedItemsInCorrectOrder(grid:DataGrid, dataSource:ArrayCollection, nameProperty:String="name"):Array {
			var selHash:Object = new Object();
			var results:Array = new Array();
			//todo use id instead of name as hash key?
			for (var x:int = 0; x < grid.selectedItems.length; x++) {
				var item:Object = grid.selectedItems[x];
				selHash[item[nameProperty]] = 1;
			}
			for (var i:int = 0; i < dataSource.length; i++) {
				if (selHash[dataSource[i][nameProperty]] == 1) {
					trace("found a match: " + dataSource[i][nameProperty]);
					results.push(dataSource[i]);
				}	
			}
			trace("'correct' selected items length: " + results.length);
			return results;
		}



	}
	
}