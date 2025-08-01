({
    
    hideSpinner : function(component, event, helper) {
    	component.set("v.spinner", false);
    },
    
    showSpinner: function(component, event, helper) {
        component.set("v.spinner", true); 
    },
	
})