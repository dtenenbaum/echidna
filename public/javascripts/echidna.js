jQuery.noConflict();  


var fb_lite = false;
try {
	if (firebug) {
		fb_lite = true;  
		firebug.d.console.cmd.log("initializing firebug logging");
	}
} catch(e) {
	// do nothing
}

function FG_fireDataEvent() {
  // events are documented in the Flanagan Javascript book
  var ev = document.createEvent("Events");
  // initEvent(eventType, canBubble, cancelable)
  ev.initEvent("gaggleDataEvent", true, false); 
  document.dispatchEvent(ev);
} 


function log(message) {
	//if (typeof(window['console']) != 'undefined') {
	if (fb_lite) {  
		console.log(message);
		/*
		try {
			firebug.d.console.cmd.log(message);  
		} catch (e) {
			//alert("oops");
		} 
		*/
	} else {
		if (window.console) {
			console.log(message);
		} 
	}
}                          
 
String.prototype.trim = function() {
	return this.replace(/^\s+|\s+$/g,"");
}
String.prototype.ltrim = function() {
	return this.replace(/^\s+/,"");
}
String.prototype.rtrim = function() {
	return this.replace(/\s+$/,"");
}                                                       

function logAjaxEvent(element, event, request, settings, status) {
    if (status == "error") {
        jQuery(element).html("<font color='red'>Error receiving data from remote server.</font>");
        jQuery("#ajax_error").html("<font color='red'>Error receiving data from remote server.</font>");
    }
    log("ajax event information:");
    log("event: " + event);
    log("request: " + request);
    log("settings: " + settings);
    log("status: " + status);
}


// global variable, holds reference to the Flex application
var flexApp;  
var DMV_SELECTION_CHANGED_EVENT = "dmvSelectionChangedEvent";
  
var initCallback = function() {  
   log("Flex called us back!");
   flexApp = FABridge.flex.root();  
   
   flexApp.addEventListener(DMV_SELECTION_CHANGED_EVENT, dmvSelectionChangedCallback)
   
   return;  
}  
// register the callback to load reference to the Flex app
FABridge.addInitializationCallback( "flex", initCallback );

var dmvSelectionChangedCallback = function(event) {
    log("got a dmv selection event from flex");
    alert("Got a DMV selection event from Flex.");
}




jQuery(document).ready(function(){       
    log("hello from js");
});


