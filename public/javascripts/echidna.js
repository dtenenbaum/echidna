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

var gaggleActivated = false;
  
var initCallback = function() {  
   log("Flex called us back!");
   flexApp = FABridge.flex.root();  
   
   flexApp.addEventListener(DMV_SELECTION_CHANGED_EVENT, dmvSelectionChangedCallback)
   
   return;  
}  

// todo, check here to make sure we are running firegoose before creating the callback
// find out how to know if we are running FG or not.

// register the callback to load reference to the Flex app
FABridge.addInitializationCallback( "flex", initCallback );

var dmvSelectionChangedCallback = function(event) {
    log("got a dmv selection message: " + event.getMessage());
    if (gaggleActivated && event.getNumRowsSelected() == 0) {
        toggleGaggle();
        FG_fireDataEvent();
        return;
    } else if (!gaggleActivated && event.getNumRowsSelected() > 0) {
        toggleGaggle();
    }
    updateGaggleDivs(event);
    FG_fireDataEvent();
}

var updateGaggleDivs = function(event) {
    log("in updateGaggleDivs, gaggleActivated = " + gaggleActivated);
    log("num rows: " + event.getNumRowsSelected());
    jQuery(".gaggle-species").html(event.getSpecies());
    document.getElementById("namelist_size").innerHTML = event.getNumRowsSelected();
    //jQuery("#namelist_size").html("" + event.getNumRowsSelected());
    log ("namelist size = " + jQuery("#namelist_size").html())
    log("setting namelist to " + event.getSelectedNames().join("\t"))
    jQuery("#namelist_namelist").html(event.getSelectedNames().join("\t"));
    log("namelist is: " + jQuery("#namelist_namelist").html());
    
//    jQuery("#matrix_size").html(event.getNumRowsSelected()  + "x" + event.getNumColumns());
}


var toggleGaggle = function() {
    gaggleActivated = !gaggleActivated;
    jQuery(".gaggle-data-not").toggleClass("gaggle-data");
}



jQuery(document).ready(function(){       
    log("hello from js");
});


