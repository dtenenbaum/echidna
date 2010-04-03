package org.systemsbiology.echidna.events
{
	import flash.events.Event;
	
	import org.systemsbiology.echidna.dialog.PlotDialog;

	public class HidePlotEvent extends Event
	{
		public static const HIDE_PLOT_EVENT:String = "hidePlotEvent";
		
		public var plot:PlotDialog;
		
		public function HidePlotEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
	}
}