({
	
	doInit: function(component, event, helper) {
    },
    
    selectProduct : function(component, event, helper) {
    if (component.get("v.singleRec.quantity") == 0) {
    		alert('You cannot set the Quantity to 0.  You may set the price to $0.00');
    	}
    	var product = component.get("v.singleRec");
    	product.selected = true;
        product.isSelectedRecord=true;
		component.set("v.singleRec", product);
		var compEvent = component.getEvent("deleteEvent");
		compEvent.fire(); 
    },
	
})