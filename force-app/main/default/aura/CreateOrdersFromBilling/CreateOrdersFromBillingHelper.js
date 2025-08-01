({
	
	createTheInvoices : function(component, event, helper) {
		this.showSpinner(component, event, helper);
		var action = component.get("c.buildOrderFromBilling");
        var theId = component.get("v.recordId");
     //   var fromOrders = component.get("v.fromCreateOrders");
        action.setParams({
            recordId : theId,
      //      fromCreateOrders : fromOrders
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
   
    showSpinner: function(component, event, helper) {
        component.set("v.spinner", true); 
    },
	
})