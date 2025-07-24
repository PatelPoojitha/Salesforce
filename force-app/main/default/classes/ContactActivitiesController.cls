/*
    Developer:  Jim Hyland <jon@shippconsulting.com>
    
    Description:
       Controller for the ContactActivities Page
       Test code in ContactActivitiesTest class.
       
       This code is the property of Shipp Consulting LLC and is for the use of the authorized client only.  
       Any reuse or copy of this code without permission from ShippConsulting LLC is the violation of the service contract with Shipp Consulitng LLC.
*/

public class ContactActivitiesController {
    
    /* Variables */
    
    public List<Task> activities { get; private set; }
    
    /* Constructor */
    
    public ContactActivitiesController(ApexPages.StandardController controller) {
        Id leadId = [select Contact__c from CallRevu_Lead__c where Id = :controller.getId()].Contact__c;
        activities = buildActivities(leadId);
    }
    
    /* Static Methods */
    
    @AuraEnabled
    public static List<Task> buildActivities(Id leadId) {
        List<Task> openActivities = new List<Task>();
        List<Task> completedActivities = new List<Task>();
        
        // additional fields from field set: N.B. ALL FIELDS MUST BE LOWER CASE
        Set<String> queryFields = new Set<String> { 'status' };
        if (!Test.isRunningTest()) {
            for (Schema.FieldSetMember f : SObjectType.Task.FieldSets.CallRevu_Leads.getFields()) {
                queryFields.add(f.getFieldPath().toLowerCase());
            }
        }
        String query = 'select id';
        for (String fld : queryFields) {
            query += ',' + fld;
        }
        query += ' from Task where WhoID = :leadId order by ActivityDate desc';
        for (Task task : database.query(query)) {
            if (task.status == 'Completed') {
                completedActivities.add(task);
            } else {
                openActivities.add(task);
            }
        }
        List<Task> activities = new List<Task>();
        activities.addAll(openActivities);
        activities.addAll(completedActivities);
        return activities;
    }
    
    @AuraEnabled
    public static DataTableResponse getActivityRecords(String strObjectName, String strFieldSetName, Id leadId, String status){  
        
        // Get contactId
        Id contactId = [select Contact__c from CallRevu_Lead__c where Id = :leadId].Contact__c;
        
        //Get the fields from FieldSet
        Schema.SObjectType SObjectTypeObj = Schema.getGlobalDescribe().get(strObjectName);
        Schema.DescribeSObjectResult DescribeSObjectResultObj = SObjectTypeObj.getDescribe();            
        Schema.FieldSet fieldSetObj = DescribeSObjectResultObj.FieldSets.getMap().get(strFieldSetName);
        
        //To hold the table headers 
        List<DataTableColumns> lstDataColumns = new List<DataTableColumns>();
        
        //Field to be queried - fetched from fieldset
        List<String> lstFieldsToQuery = new List<String>();
       
        //The final wrapper response to return to component
        DataTableResponse response = new DataTableResponse();
        
        for( Schema.FieldSetMember eachFieldSetMember : fieldSetObj.getFields() ){
            if (String.valueOf(eachFieldSetMember.getLabel()).toLowerCase() == 'subject') {
                continue;
            }
            String dataType = String.valueOf(eachFieldSetMember.getType()).toLowerCase();
            //This way we can set the type of a column
            //We do not get the exact type from schema object which matches to lightning:datatable component structure
            if(dataType == 'datetime' || dataType == 'date'){
                dataType = 'date-local';
            }
            //Create a wrapper instance and store label, fieldname and type.
            DataTableColumns datacolumns = new DataTableColumns( String.valueOf(eachFieldSetMember.getLabel()) , 
                                                                String.valueOf(eachFieldSetMember.getFieldPath()), 
                                                                dataType );
            lstDataColumns.add(datacolumns);
            lstFieldsToQuery.add(String.valueOf(eachFieldSetMember.getFieldPath()));
        }
        List<String> lstFinalFieldsToQuery = new List<String> { 'subject__c' };
        lstFinalFieldsToQuery.addAll(lstFieldsToQuery);
        DataTableColumns datacolumn = new DataTableColumns('Subject', 'Subject__c', 'url');
        List<DataTableColumns> lstFinalDataColumns = new List<DataTableColumns> { datacolumn };
        lstFinalDataColumns.addAll(lstDataColumns);
        
        //Form an SOQL to fetch the data - Set the wrapper instance and return as response
        if(!lstDataColumns.isEmpty()){            
            response.lstDataTableColumns = lstFinalDataColumns;
            String query = 'select Id, ' + String.join(lstFinalFieldsToQuery, ',') 
                + ', subject from ' + strObjectName + ' where WhoID = :contactId';
            if (strObjectName == 'Task' && status == 'Open') {
                query += ' and status = :status order by ActivityDate asc';
            } else if (strObjectName == 'Task') {
                query += ' and status = :status order by ActivityDate desc';
            } else {
                query += ' order by StartDateTime desc';
            }
            List<sObject> objects = Database.query(query);
            response.lstDataTableData = objects;
            response.lstDataTableDataSmall = new List<sObject>();
            if (!response.lstDataTableData.isEmpty()) {
                response.lstDataTableDataSmall.add(response.lstDataTableData[0]);
                if (response.lstDataTableData.size() > 1) {
                    response.lstDataTableDataSmall.add(response.lstDataTableData[1]);
                }
            }
        }
        return response;
    }
    
    //Wrapper class to hold Columns with headers
    public class DataTableColumns {
        @AuraEnabled
        public String label {get;set;}
        @AuraEnabled       
        public String fieldName {get;set;}
        @AuraEnabled
        public String type {get;set;}
        @AuraEnabled
        public String typeAttributes {get;set;}
        
        //Create and set three variables label, fieldname and type as required by the lightning:datatable
        public DataTableColumns(String label, String fieldName, String type){
            this.label = label;
            this.fieldName = fieldName;
            this.type = type;
        }
    }
    
    //Wrapper calss to hold response - This response is used in the lightning:datatable component
    public class DataTableResponse {
        @AuraEnabled
        public List<DataTableColumns> lstDataTableColumns {get;set;}
        @AuraEnabled
        public List<sObject> lstDataTableData {get;set;} 
        @AuraEnabled
        public List<sObject> lstDataTableDataSmall {get;set;}                
        
        public DataTableResponse(){
            lstDataTableColumns = new List<DataTableColumns>();
            lstDataTableData = new List<sObject>();
        }
    }
}