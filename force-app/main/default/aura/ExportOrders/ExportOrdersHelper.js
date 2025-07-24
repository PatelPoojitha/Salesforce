({
    
    changeAll : function(component, event, helper) {
    	var checkBoxSet = component.get("v.selectAll");
    	var orders = component.get("v.displayOrders");
    	orders.forEach(function (order) {
    		order.selected = checkBoxSet;
    	});
    	component.set("v.displayOrders", orders);
    },
    
    changeOne : function(component, event, helper) {
    	component.set("v.selectAll", false);
    },
    
    changeTheExport : function(component, event, helper) {
    	if (component.get("v.selectedExport") == 'Pending Exports') {
    		var orders = [];
    		var pending = component.get("v.pendingOrders");
    		if (pending) {
    			pending.forEach(function (order) {
    				orders.push(order);
    			});
    		}
    		component.set("v.selectedAlready", null);
    		component.set("v.displayOrders", orders);
    	} else {
    		this.changeTheType(component, event, helper);
    	}
    },
    
    changeTheType : function(component, event, helper) {
    	var orders = [];
    	var source;
    	if (component.get("v.selectedAlready") == 'Last Week') {
    		source = component.get("v.alreadyLastWeekOrders");
    	} else if (component.get("v.selectedAlready") == 'Yesterday') {
    		source = component.get("v.alreadyYesterdayOrders");
    	} else if (component.get("v.selectedAlready") == 'This Week') {
    		source = component.get("v.alreadyThisWeekOrders");
    	} else {
    		source = component.get("v.alreadyTodayOrders");
    	}
    	if (source) {
    		source.forEach(function (order) {
    			orders.push(order);
    		});
    	}
    	component.set("v.displayOrders", orders);
    },
	
	hideSpinner : function(component, event, helper) {
    	component.set("v.spinner", false);
    },
    
    orderHelper : function(component, event, helper) {
		this.showSpinner(component, event, helper);
        var action = component.get("c.buildOrders");
        //Set the Object parameters
        action.setParams({
        }); 
        action.setCallback(this, function(response) {
        	this.hideSpinner(component, event, helper);
            var state = response.getState();
            if (state === 'SUCCESS') {
            	component.set("v.alreadyLastWeekOrders", response.getReturnValue().alreadyLastWeekOrders);
            	component.set("v.alreadyThisWeekOrders", response.getReturnValue().alreadyThisWeekOrders);
            	component.set("v.alreadyTodayOrders", response.getReturnValue().alreadyTodayOrders);
            	component.set("v.alreadyYesterdayOrders", response.getReturnValue().alreadyYesterdayOrders);
            	component.set("v.pendingOrders", response.getReturnValue().pendingOrders);
            	component.set("v.selectedAlready", 'Today');
            	this.changeTheExport(component, event, helper);
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
    
    saveOrders : function(component, event, helper) {
        var selOrderIds = '';
        var orders = component.get("v.displayOrders");
        orders.forEach(function (order) {
        	if (order.selected) {
        		selOrderIds += order.theOrder.Id + ',';
        	}
    	});
    	if (!selOrderIds || selOrderIds.length == 0) {
    		alert('There are no Orders selected to Export.');
    		return;
    	}
    	if (!confirm("Please Confirm Export.")) {
    		return;
    	}
    	var action = component.get("c.exportOrders");
    	this.showSpinner(component, event, helper);
        //Set the Object parameters
        action.setParams({
            selectedOrderIds : selOrderIds,
        }); 
        action.setCallback(this, function(response) {
        	this.hideSpinner(component, event, helper);
        	var state = response.getState();
            if (state === 'SUCCESS') {
            	alert('Export File Emailed.');
            	$A.get('e.force:refreshView').fire();
            	var url = component.get("v.url");
            	var navEvt = $A.get("e.force:navigateToURL").setParams({ "url": url }).fire();
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
    
    showSpinner: function(component, event, helper) {
        component.set("v.spinner", true); 
    }, 
	
})