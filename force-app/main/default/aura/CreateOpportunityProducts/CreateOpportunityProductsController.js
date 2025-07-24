({
	
	doInit : function(component, event, helper) {
		component.set("v.inInit", true);
		helper.getDataHelper(component, event, helper);
		component.set("v.inInit", false);
    },
    
    changeCategory : function(component, event, helper) {
    	if (component.get("v.change") && !component.get("v.confirm")) {
			component.set("v.confirm", true);
			component.set("v.showCancel", true);
    		alert('There are unsaved changes.  To save changes, hit Save.  To change product category without saving, hit Cancel.');
    		return;
    	}
    	component.set("v.showCancel", false);
    	helper.displayItems(component, event, helper);
    },
    
    handleChange : function(component, event, helper) {
		component.set("v.change", true);
		component.set("v.confirm", false);
		component.set("v.showCancel", false);
    },
    
    handleSelectDelete : function(component, event, helper) {
		helper.selectDeleteHelper(component, event, helper);
		component.set("v.change", true);
    },
    
    returnToOpportunity : function(component, event, helper) {
    	if (component.get("v.change") && !component.get("v.confirm")) {
    		component.set("v.confirm", true);
    		alert('There are unsaved changes.  To save changes, hit Save.  To exit without saving, hit Return to Opportunity again.');
    		return;
    	}
    	var navEvt = $A.get("e.force:navigateToSObject");
    	navEvt.setParams({ "recordId": component.get("v.opportunityId"), "slideDevName": "detail" }); 
    	navEvt.fire();
    },
    
    save : function(component, event, helper) {
    	helper.saveData(component, event, helper);
    },
	
})