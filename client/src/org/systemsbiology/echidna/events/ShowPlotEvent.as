package org.systemsbiology.echidna.events
{
	import flash.events.Event;
	
	import org.systemsbiology.echidna.dialog.PlotDialog;

	public class ShowPlotEvent extends Event
	{
		public static const SHOW_PLOT_EVENT:String = "showPlotEvent";
		public var plot:PlotDialog;
		
		public function ShowPlotEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
	}
}