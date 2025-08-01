({
	doInit : function(component, event, helper) {		                
    	helper.getDataHelper(component, event);
    },
    
    toggleMore1 : function(component, event, helper) {
    	var buttonLabel = component.get("v.button1");
    	if (buttonLabel == 'More') {
    		component.set("v.button1", 'Less');
    	} else {
    		component.set("v.button1", 'More');
    	}
    },
    
    toggleMore2 : function(component, event, helper) {
    	var buttonLabel = component.get("v.button2");
    	if (buttonLabel == 'More') {
    		component.set("v.button2", 'Less');
    	} else {
    		component.set("v.button2", 'More');
    	}
    },
    
    toggleMore3 : function(component, event, helper) {
    	var buttonLabel = component.get("v.button3");
    	if (buttonLabel == 'More') {
    		component.set("v.button3", 'Less');
    	} else {
    		component.set("v.button3", 'More');
    	}
    },
})