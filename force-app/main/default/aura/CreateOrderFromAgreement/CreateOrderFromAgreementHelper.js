({
	
	createTheInvoices : function(component, event, helper) {
		this.showSpinner(component, event, helper);
		var action = component.get("c.buildOrder");
        var theId = component.get("v.recordId");
     /*   var theMonth = component.get("v.selectedMonth");
        var theYear = component.get("v.selectedYear"); */
        var fromOrders = component.get("v.fromCreateOrders");
        action.setParams({
            recordId : theId,
        /*    month : theMonth,
            year : theYear, */
            fromCreateOrders : fromOrders
        }); 
        action.setCallback(this, function(response){
        	this.hideSpinner(component, event, helper);
            var state = response.getState();
            if (state === 'SUCCESS') {
            	component.set("v.pageMessage", response.getReturnValue().message);
            	$A.get('e.force:refreshView').fire();
            	if (response.getReturnValue().message == null) {
            		var dismissActionPanel = $A.get("e.force:closeQuickAction");
            		dismissActionPanel.fire();
            		alert('The orders have been created.');
            	}
            } else if (state === 'ERROR') {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            } else {
                console.log('Something went wrong, Please check with your admin.');
            }
        });
        $A.enqueueAction(action);
        
    }, 
    
    hideSpinner : function(component, event, helper) {
    	component.set("v.spinner", false);
    },
    
  /*  setup : function(component, event, helper) {
		this.showSpinner(component, event, helper);
		var action = component.get("c.setupComponent");
        action.setCallback(this, function(response){
        	this.hideSpinner(component, event, helper);
            var state = response.getState();
            if (state === 'SUCCESS') {
            	component.set("v.monthOptions", response.getReturnValue().months);
            	component.set("v.yearOptions", response.getReturnValue().years);
            	component.set("v.selectedMonth", '--None--');
            	component.set("v.selectedYear", '--None--');
            } else if (state === 'ERROR') {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            } else {
                console.log('Something went wrong, Please check with your admin.');
            }
        });
        $A.enqueueAction(action);
        
    }, */
    
    showSpinner: function(component, event, helper) {
        component.set("v.spinner", true); 
    },
	
})