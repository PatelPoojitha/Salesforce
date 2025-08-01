({
	getDataHelper : function(component, event) {
        var action = component.get("c.getActivityRecords");
        var theId = component.get("v.recordId");
        //Set the Object parameters and Field Set name
        action.setParams({
            strObjectName : 'Task',
            strFieldSetName : 'CallRevu_Leads',
            leadId : theId,
            status : 'Open'
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === 'SUCCESS'){
            	var rtnValue = response.getReturnValue();
            	rtnValue.lstDataTableColumns.forEach(function (column) {
            		switch (column.fieldName) {
            			case 'Subject__c':
            				column['typeAttributes'] = { label: { fieldName: 'Subject' } };
            				break;
            			
            			default:
            				break;
            		}
            	});
                component.set("v.openTasksColumns", response.getReturnValue().lstDataTableColumns);
                component.set("v.openTasksData", response.getReturnValue().lstDataTableData);
                component.set("v.openTasksDataSmall", response.getReturnValue().lstDataTableDataSmall);   
            }else if (state === 'ERROR'){
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }else{
                console.log('Something went wrong, Please check with your admin');
            }
        });
        $A.enqueueAction(action);
        
        var action = component.get("c.getActivityRecords");
        //Set the Object parameters and Field Set name
        action.setParams({
            strObjectName : 'Task',
            strFieldSetName : 'CallRevu_Leads',
            leadId : theId,
            status : 'Completed'
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === 'SUCCESS'){
            	var rtnValue = response.getReturnValue();
            	rtnValue.lstDataTableColumns.forEach(function (column) {
            		switch (column.fieldName) {
            			case 'Subject__c':
            				column['typeAttributes'] = { label: { fieldName: 'Subject' } };
            				break;
            			
            			default:
            				break;
            		}
            	});
                component.set("v.openTasksColumns", response.getReturnValue().lstDataTableColumns);
                component.set("v.completedTasksData", response.getReturnValue().lstDataTableData); 
                component.set("v.completedTasksDataSmall", response.getReturnValue().lstDataTableDataSmall);   
            }else if (state === 'ERROR'){
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }else{
                console.log('Something went wrong, Please check with your admin');
            }
        });
        $A.enqueueAction(action);
        
        var action = component.get("c.getActivityRecords");
        //Set the Object parameters and Field Set name
        action.setParams({
            strObjectName : 'Event',
            strFieldSetName : 'CallRevu_Leads',
            leadId : theId
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === 'SUCCESS'){
            	var rtnValue = response.getReturnValue();
            	rtnValue.lstDataTableColumns.forEach(function (column) {
            		switch (column.fieldName) {
            			case 'Subject__c':
            				column['typeAttributes'] = { label: { fieldName: 'Subject' } };
            				break;
            			
            			default:
            				break;
            		}
            	});
                component.set("v.eventColumns", response.getReturnValue().lstDataTableColumns);
                component.set("v.eventData", response.getReturnValue().lstDataTableData);  
                component.set("v.eventDataSmall", response.getReturnValue().lstDataTableDataSmall); 
            }else if (state === 'ERROR'){
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }else{
                console.log('Something went wrong, Please check with your admin');
            }
        });
        $A.enqueueAction(action);
    },
})