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
	if (window.dump) {
	    dump(message + "\n");
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

// i don't think this is called. TODO - verify and delete
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
var ECHIDNA_SELECTION_CHANGED_EVENT = "echidnaSelectionChangedEvent";

var gaggleActivated = false;
var echidnaGaggleActivated = false;
var selectors = ["#indirect_matrix_wrapper_ratios", "#indirect_matrix_wrapper_lambdas"];
var outerSelectors = ["#gaggle_indirect_matrix_outer_ratios", "#gaggle_indirect_matrix_outer_lambdas"];
var innerSelectors = ["#indirect_matrix_ratios", "#indirect_matrix_lambdas"];
  
// flex calls this function when it has everything ready on its side
var initCallback = function() {  
   log("Flex called us back!");
   flexApp = FABridge.flex.root();  
   
   flexApp.addEventListener(DMV_SELECTION_CHANGED_EVENT, dmvSelectionChangedCallback);
   flexApp.addEventListener(ECHIDNA_SELECTION_CHANGED_EVENT, echidnaSelectionChangedCallback)
   
//   document.getElementById("echidna").focus();
   
   return;  
}  

// todo, check here to make sure we are running firegoose before creating the callback
// find out how to know if we are running FG or not.
// currently we just check to see if we are running firefox.

var dmvSelectionChangedCallback = function(event) {
    log("in dmvSelectionChangedCallback, is gaggle activated? " + gaggleActivated + ", num rows: " + event.getNumRowsSelected());
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

var echidnaSelectionChangedCallback = function(event) {
    log("in echidnaSelectionChangedCallback!!!!");
    if (!echidnaGaggleActivated) {
        activateEchidnaGaggle();
    }
    
    log("url = " + event.getUrl());
    
    
    //var quote = /"[^"]*"/;
    
    for (i = 0; i < selectors.length; i++) {
        var selector = selectors[i];
        var innerSelector = innerSelectors[i];
        var str = jQuery(selector).html();
        var url = (i == 0) ? event.getUrl() : event.getUrl2();
        jQuery(selector).html(str.replace(/url="[^"]*"/, "url=\"" + url + "\""));
        str = jQuery(selector).html();
        str = str.replace(/species="[^"]*"/, "species=\"" + event.getSpecies() + "\"");
        str = str.replace(/size="[^"]*"/, "size=\"" + event.getSize() + "\"");
        jQuery(selector).html(str);
        //log(selector + ": now html is:\n" + jQuery(selector).html());
    }
    
    //jQuery(".datamatrix").attr("url", "foo");
    
    
    
    FG_fireDataEvent();
}

var activateEchidnaGaggle = function() {
    log("in activateEchidnaGaggle")
    echidnaGaggleActivated = true;
    for (i = 0; i < outerSelectors.length; i++) {
        var outerSelector = outerSelectors[i];
        var str = jQuery(outerSelector).html();
        jQuery(outerSelector).html(str.replace("gaggledatanot","gaggleData"));
    }
} 

var updateGaggleDivs = function(event) {
    jQuery(".gaggle-species").html(event.getSpecies());
    jQuery("#namelist_size").html("" + event.getNumRowsSelected());
    jQuery("#namelist_namelist").html(event.getSelectedNames().join("\t"));
    
    jQuery("#matrix_size").html(event.getNumRowsSelected()  + "x" + event.getNumColumns());
    
    
    if (event.getMatrixType() != null) {
        jQuery("#matrix_name").html("WebDMV Matrix Selection ("+ event.getMatrixType() +")");
        jQuery("#namelist_name").html("WebDMV Namelist Selection ("+ event.getMatrixType() +")");
    } else {
        jQuery("#matrix_name").html("WebDMV Matrix Selection");
        jQuery("#namelist_name").html("WebDMV Namelist Selection");
    }
    
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
    
    //document.getElementById("echidna").focus();
    
    jQuery.each(jQuery.browser, function(i, val) {
      if(i=="mozilla" && val==true) {
          moz = true;
      }
    });
    if (moz) {
        log("this seems to be firefox.");

        // register the callback to load reference to the Flex app
        try {
            FABridge.addInitializationCallback( "flex", initCallback );
            log("FABridge callback registered.");
        } catch (err) {
            log("FABridge init failed, err = " + err.description);
        }

        
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
    var species = jQuery("#gaggle_namelist_species_from_firegoose").html();
    var namelist = jQuery("#gaggle_namelist_names_from_firegoose").text().split("\n");
    log ("flexapp = " + flexApp);
    flexApp.receiveGaggleNamelist(species, namelist);
}


