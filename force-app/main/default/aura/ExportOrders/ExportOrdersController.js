({
	
	doInit : function(component, event, helper) {
		helper.orderHelper(component, event, helper);
		var navService = component.find("navService");
        var pageReference = {
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Order',
                actionName: 'home'
            }
        };
        component.set("v.pageReference", pageReference);
        var defaultUrl = "#";
        navService.generateUrl(pageReference).then($A.getCallback(function(url) {
            component.set("v.url", url ? url : defaultUrl);
        	}), $A.getCallback(function(error) {
        		component.set("v.url", defaultUrl);
        }));
    },
    
    changeExport : function(component, event, helper) {
    	helper.changeTheExport(component, event, helper);
    },
    
    changeSelectAll : function(component, event, helper) {
    	helper.changeAll(component, event, helper);
    },
	
	changeSelectOne : function(component, event, helper) {
    	helper.changeOne(component, event, helper);
    },
    
    changeDates : function(component, event, helper) {
    	helper.changeTheType(component, event, helper);
    },
    
    save : function(component, event, helper) {
    	helper.saveOrders(component, event, helper);
    },
	
})