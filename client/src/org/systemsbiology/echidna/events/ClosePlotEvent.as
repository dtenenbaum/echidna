package org.systemsbiology.echidna.events
{
	import flash.events.Event;
	
	import org.systemsbiology.echidna.dialog.PlotDialog;

	public class ClosePlotEvent extends Event
	{
		public static const CLOSE_PLOT_EVENT:String = "closePlotEvent";
		public var plot:PlotDialog;
		
		public function ClosePlotEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
	}
}