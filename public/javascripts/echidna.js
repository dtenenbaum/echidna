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


var dmvSelectionChangedCallback = function(event) {
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
    jQuery(".gaggle-species").html(event.getSpecies());
    jQuery("#namelist_size").html("" + event.getNumRowsSelected());
    jQuery("#namelist_namelist").html(event.getSelectedNames().join("\t"));
    
    jQuery("#matrix_size").html(event.getNumRowsSelected()  + "x" + event.getNumColumns());
    //todo - is it better to construct the string on the flex side and just send it over?
    var matrix = "";
    for (var i = 0; i < event.getMatrix().length; i++) {
        var row = event.getMatrix()[i];
        for (j = 0;j < row.length; j++) {
            matrix += row[j]
            if (j < (row.length-1)) {
                matrix += "\t"
            }
        }
        matrix += "\n"
    }
    //log("matrix = \n" + matrix);
    jQuery("#matrix_matrix").html(matrix);
}


var toggleGaggle = function() {
    gaggleActivated = !gaggleActivated;
    jQuery(".gaggle-data-not").toggleClass("gaggle-data");
}



jQuery(document).ready(function(){       
    log("hello from js");
    var moz = false;
    
    jQuery.each(jQuery.browser, function(i, val) {
      if(i=="mozilla" && val==true) {
          moz = true;
      }
    });
    if (moz) {
        // register the callback to load reference to the Flex app
        FABridge.addInitializationCallback( "flex", initCallback );
        
        log("setting up event listener for events from FG");
		document.addEventListener("webDmvHandleNamelistEvent",
			function(aEvent) {
			     gotNamelistFromGaggle();
		    }, false, true);
    } else {
        log("Not using Firefox, disabling Gaggle.");
    }
});

var gotNamelistFromGaggle = function() {
    log("received event from FG"); 
    //log("species: " + jQuery("#gaggle_namelist_species_from_firegoose").html())
    //log("namelist: \n" + jQuery("#gaggle_namelist_names_from_firegoose").html())
    var species = jQuery("#gaggle_namelist_species_from_firegoose").html();
    var namelist = jQuery("#gaggle_namelist_names_from_firegoose").text().split("\n");
    
    flexApp.receiveGaggleNamelist(species, namelist);
}


