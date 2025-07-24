/*
    Developer:  Jim Hyland <jon@shippconsulting.com>
    
    Description:
       Controller for the ExportOrders Component
       Test code in ExportOrdersTest class.
*/

public class ExportOrdersController {
    
    /* Constructor */
    
    public ExportOrdersController() {
    }
    
    /* Static Methods */
    
    @AuraEnabled
    public static TheOrders buildOrders() {
        return new TheOrders();
    }
    
    private static List<OrderItem> buildOrderItems(Set<String> orderIds) {
        
        // NB: always add fields in lower case for easier comparison against those included in the field set
        Set<String> queryFields = new Set<String>();
        if (!Test.isRunningTest()) {
            for (Schema.FieldSetMember f : SObjectType.OrderItem.FieldSets.Order_Item_Export.getFields()) {
                queryFields.add(f.getFieldPath().toLowerCase());
            }
        }
        queryFields.add('orderid');
        String query = 'select id';
        for (String queryField : queryFields) {
            if (queryField != 'id') {
                query += ', ' + queryField;
            }
        }
        query += ' from OrderItem where orderId in :orderIds';
        List<OrderItem> exportOrderItems = new List<OrderItem>();
        for (OrderItem item : database.query(query)) {
            exportOrderItems.add(item);
        }
        return exportOrderItems;
    }
    
    @AuraEnabled
    public static void exportOrders(String selectedOrderIds) {
        List<String> theIds = selectedOrderIds.split(',');
        Set<String> theOrderIds = new Set<String>();
        theOrderIds.addAll(theIds);
        List<OrderItem> orderItems = buildOrderItems(theOrderIds);
        List<String> orderItemFields = new List<String>();
        Map<String, String> itemLabelByAPIName = new Map<String, String>();
        if (!Test.isRunningTest()) {
            for (Schema.FieldSetMember f : SObjectType.OrderItem.FieldSets.Order_Item_Export.getFields()) {
                orderItemFields.add(f.getFieldPath().toLowerCase());
                itemLabelByAPIName.put(f.getFieldPath().toLowerCase(), f.getLabel());
            }
        } else {
            orderItemFields.add('id');
        }
        String generatedCSVFile = '';
        String fileRow = '';
        for (String fld : orderItemFields) {
            fileRow += ',' + itemLabelByAPIName.get(fld);
        }
        fileRow = fileRow.replaceFirst(',', '');
        generatedCSVFile += fileRow + '\n';
        String temp;
        for (OrderItem item : orderItems) {
            fileRow = '';
            for (String fld : orderItemFields) {
                if (recursiveGet((sObject)item, fld) != null) {
                        fileRow += ',\"' + recursiveGet((sObject)item, fld) + '\"';
                } else {
                    fileRow += ',';
                }
            }
            fileRow = fileRow.replaceFirst(',', '');
            generatedCSVFile += fileRow + '\n';
        }
        generatedCSVFile = generatedCSVFile.replaceAll('\"null\",', ',').replaceAll(',\"null\"', ',');
        Blob csvBlob = Blob.valueOf(generatedCSVFile);
        String theDate = system.today().year() + '-' + system.today().month() + '-' + system.today().day() + ' ' + system.now().hour() + ':'
            + system.now().minute();
        Messaging.EmailFileAttachment attach = new Messaging.EmailFileAttachment();
        attach.setContentType('application/pdf');
        attach.setFileName('OrderExport' + theDate + '.csv');
        attach.Body = csvBlob;
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String userEmail = [select email from User where Id = :UserInfo.getUserId()].email;
        mail.setToAddresses(new String[] { userEmail });
        mail.setSubject('Exported Orders ' + theDate);
        mail.setHtmlBody('Please see attached csv file for Exported Orders.');
        mail.setFileAttachments(new Messaging.EmailFileAttachment[] { attach }); 
        try {
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        } catch (Exception e) {
            // do nothing: mass email not enabled
        }
        List<Order> orders = new List<Order>();
        for (String id : theOrderIds) {
            orders.add(new Order(Id  = id, Date_Exported__c = system.today()));
        }
        update orders; 
    } 
    
    private static Object recursiveGet(sObject record, String field) {
        if (field.contains('.')) {
            Integer firstPeriod = field.indexOf('.');
            String nextObjectName = field.subString(0, firstPeriod);
            String remainingfieldName = field.subString(firstPeriod + 1, field.length());
            sObject nextObject = record.getSObject(nextObjectName);
            if (nextObject == null) {
                return null;
            } else {
                return recursiveGet(nextObject, remainingfieldName);
            }
        } else {
            return '' + record.get(field);
        }
    }
    
    /* Inner Classes */
    
    public class TheOrder {
        
        @AuraEnabled
        public Order theOrder { get; private set; }
        @AuraEnabled
        public Boolean selected { get; private set; }
        
        public TheOrder(Order ord) {
            theOrder = ord;
            selected = false;
        }
    }
    
    public class TheOrders {
        
        @AuraEnabled
        public List<TheOrder> alreadyLastWeekOrders { get; private set; }
        @AuraEnabled
        public List<TheOrder> alreadyThisWeekOrders { get; private set; }
        @AuraEnabled
        public List<TheOrder> alreadyTodayOrders { get; private set; }
        @AuraEnabled
        public List<TheOrder> alreadyYesterdayOrders { get; private set; }
        @AuraEnabled
        public List<TheOrder> pendingOrders { get; private set; }
        
        public TheOrders() {
            alreadyLastWeekOrders = buildTheOrders('LAST_WEEK', 'Date_Exported__c != null');
            alreadyThisWeekOrders = buildTheOrders('THIS_WEEK', 'Date_Exported__c != null');
            alreadyTodayOrders = buildTheOrders('TODAY', 'Date_Exported__c != null');
            alreadyYesterdayOrders = buildTheOrders('YESTERDAY', 'Date_Exported__c != null');
            pendingOrders = buildTheOrders(null, 'Date_Exported__c = null');
        }
        
        private List<TheOrder> buildTheOrders(String dateClause, String exportedDateClause) {
            List<TheOrder> orders = new List<TheOrder>();
            String query = 'select Order.Name, CreatedDate, Service_Agreement__r.Bill_To_Account__r.Name,'
                + 'Service_Agreement__r.Service_Location__r.Name, TotalAmount, Status from Order where ' + exportedDateClause;
            if (dateClause != null) {
                query += ' and Date_Exported__c = ' + dateClause;
            }
            query += ' order by Date_Exported__c asc, name asc';
            for (Order theOrder : database.query(query)) {
                orders.add(new TheOrder(theOrder));
            }
            return orders;
        }
    }
}