package flex.utils.ui
{
	//stolen from http://imtiyaz-dev.blogspot.com/2008/06/test-post.html and modified a bit
	import adobe.utils.CustomActions;
	
	import com.adobe.serialization.json.JSON;
	
	import flash.events.ContextMenuEvent;
	import flash.events.Event;
	import flash.system.System;
	import flash.ui.ContextMenu;
	import flash.ui.ContextMenuItem;
	
	import mx.collections.ArrayCollection;
	import mx.controls.DataGrid;
	import mx.controls.dataGridClasses.DataGridColumn;
	import mx.core.EventPriority;
	import mx.events.CloseEvent;
	import mx.events.ListEvent;
	
	import org.systemsbiology.echidna.common.Util;

	public class IBDataGrid extends DataGrid
	{
		[Bindable] public var enableCopy : Boolean = true;
		// for creating conext menu item for copying functionality				
		private var copyContextItem:ContextMenuItem;		
		private var selectAllContextItem:ContextMenuItem;
		// for storing the header text at only once.
		//private var headerString : String = '';
		
		//private var dataToCopy:String = '';
		public function IBDataGrid()
		{
			super();
		}
			
		// I am creating a copy context item and its handler in creation complete of DATAGRID if and only if enableCopy is true.
	    override protected function createChildren():void{
			super.createChildren();
				//if(enableCopy){
								contextMenu = new ContextMenu();
								createContextMenu();
							    addEventListener(ListEvent.ITEM_CLICK,
				                         										itemClickHandler,
				                         										false, EventPriority.DEFAULT_HANDLER);
   					//}			
		}
	    
		private function createContextMenu():void{
		      copyContextItem = new ContextMenuItem("copy selected rows"); // you can't call the item "Copy" for some reason, it won't show up
		      // similarly, it can't start with the letters "Copy", though starting with a lower-case C appears to be OK. WTF?
		      copyContextItem.enabled = true;
			  copyContextItem.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT,copyDataHandler);		
			  contextMenu.customItems.push(copyContextItem);
			  
			  selectAllContextItem = new ContextMenuItem("select all rows");
			  selectAllContextItem.enabled = true;
			  selectAllContextItem.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, selectAllHandler);
			  contextMenu.customItems.push(selectAllContextItem);
			  
			  // comment the following line if you want default items in context menu.
			  contextMenu.hideBuiltInItems();
		}
		
		
		private function doTheActualCopy():void {
			invalidateList();
			var dataToCopy:String = '';
			if(selectedItems != null){
				 dataToCopy = getSelectedRowsData();
				 //dataToCopy = ((headerString == '') ? getHeaderData() : headerString)+"\n" + dataToCopy;
				 dataToCopy = getHeaderData() + "\n" + dataToCopy;				
				 copyContextItem.enabled = true;
				 System.setClipboard(dataToCopy);
				 
			}  			
			
		}
		
		private function copyDataHandler(event:Event):void{
			if (selectedItems == null || selectedItems.length == 0) {
				//trace("bailing");
				return;
			}
			//IBDataGrid(this).callLater(doTheActualCopy); // argh, you can't do that because of this: http://forums.adobe.com/message/2801353
			doTheActualCopy();
		}
		
		private function selectAllHandler(event:Event):void {
			var dataSource:ArrayCollection = this.dataProvider as ArrayCollection;

			var indices:Array = new Array();
			trace("num rows = " + dataSource.length);
			for(var i:int = 0; i < dataSource.length; i++) {
				indices[i] = i;
				//trace("i = " + i);
			}
			selectedIndices = indices;
			invalidateList();
		}
		
		private function handleAlertClose(event:CloseEvent):void{
			trace("handling .. the event");
			if(event.detail == 1)
			{		
			  	 
			}
			 
		}
		private function getHeaderData():String{	
			   var headerString:String = '';	 
			   //headerString = '';		
					for(var j:int = 0; j< columnCount; j++){
						//if((columns[j] as DataGridColumn).visible)
						
						headerString += (columns[j] as DataGridColumn).headerText;// +"\t";
						if (j < (columnCount -1)) {
							headerString += "\t";
						}
					}
		 		return headerString;	 	
		}	
		
		private function getSelectedRowsFromGroupTable():String {
			var dataSource:ArrayCollection = this.dataProvider as ArrayCollection;
			
			

			var outStr:String = "";
			for (var i:int = 0; i < selectedItems.length; i++) {
				//trace("row = " + JSON.encode(dataSource.getItemAt(i)));
				outStr += selectedItems[i]['name'] + "\t" + selectedItems[i]['num_results'] + "\n";
			}
			return outStr;
		}
		
		private function getSelectedRowsData():String{
			/*
			for (var i:int = 0; i < columns.length; i++) {
				trace("column " + JSON.encode(columns[i]));
			}
			*/
			if (columns[0]['headerText'] != 'Gene') {
				return getSelectedRowsFromGroupTable();
			}
			
			var dataSource:ArrayCollection = this.dataProvider as ArrayCollection;
			var correctSelectedItems:Array = Util.getSelectedItemsInCorrectOrder(this, dataSource, "gene");
			
			
			var rowsData : String = '';
			for(var i:int =0;i<correctSelectedItems.length;i++) {
				for(var j:int = 0; j< columns.length; j++){
					//if((columns[j] as DataGridColumn).visible)
					rowsData += correctSelectedItems[i][(columns[j] as DataGridColumn).dataField];// +"\t";
					if (j < (columns.length -1)) {
						rowsData += "\t";
					}
				}
				rowsData+= "\n";							 
			}
			return rowsData;
		}
	    
	    private function itemClickHandler(event:ListEvent):void
	    {
	    	copyContextItem.enabled = true;
	    }		
	}
}