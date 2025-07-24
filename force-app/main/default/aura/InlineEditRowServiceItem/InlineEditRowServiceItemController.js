({
	
	doInit: function(component, event, helper) {
    },
    
    selectProduct : function(component, event, helper) {
    	var product = component.get("v.singleRec");       
    	product.selected = true;
    	product.quantity = -1;
		component.set("v.singleRec", product);
		var compEvent = component.getEvent("deleteEvent");
		compEvent.fire(); 
    },
	
})