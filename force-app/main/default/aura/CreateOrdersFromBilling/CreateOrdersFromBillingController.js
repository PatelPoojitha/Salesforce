({
	
	doInit : function(component, event, helper) {
    },
    
    cancel : function(component, event, helper) {
    	var dismissActionPanel = $A.get("e.force:closeQuickAction");
    	dismissActionPanel.fire();
    },
    
    createInvoices : function(component, event, helper) {
    	if (component.get("v.confirmButton") == 'Create Invoices') {
    		component.set("v.confirmButton", 'Please Confirm');
    		return;
    	}
    	helper.createTheInvoices(component, event, helper);
    },
    
})