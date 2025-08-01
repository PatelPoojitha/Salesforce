({
	
	doInit: function(component, event, helper) {
    },
    
    change : function(component, event, helper) {
    	if (component.get("v.singleRec.quantity") == 0) {
    		alert('You cannot set the Quantity to 0.  You may set the price to $0.00');
    	} else {
    		var compEvent = component.getEvent("changeEvent");
    		compEvent.fire(); 
    	}
    },
    
    deleteProduct : function(component, event, helper) {
    	var product = component.get("v.singleRec");    
    	product.deleted = true;
    	component.set("v.singleRec", product);
    	var compEvent = component.getEvent("deleteEvent"); 
    	compEvent.fire(); 
    },
	
})