({
	
	doInit : function(component, event, helper) {
	/*	helper.setup(component, event, helper); */
    },
    
    cancel : function(component, event, helper) {
    	if (component.get("v.fromCreateOrders")) {
    		var workspaceAPI = component.find("workspace");
    		workspaceAPI.getFocusedTabInfo().then(function(response) {
    			var focusedTabId = response.tabId;
    			workspaceAPI.closeTab({tabId: focusedTabId});
    		})
    		.catch(function(error) {
    			console.log(error);
    		});
    	} else {
    		var dismissActionPanel = $A.get("e.force:closeQuickAction");
    		dismissActionPanel.fire();
    	}
    },
    
    createInvoices : function(component, event, helper) {
    /*	if (component.get("v.selectedYear") == '--None--' || component.get("v.selectedMonth") == '--None--') {
    		alert('You must select a month and year.');
    		return;
    	}*/
    	if (component.get("v.confirmButton") == 'Create Invoices') {
    		component.set("v.confirmButton", 'Please Confirm');
    		return;
    	}
    	helper.createTheInvoices(component, event, helper);
    },
    
})