/*
 * Developer: Jim Hyland <jon@shippconsulting.com>
 *  
 * Description: Batch to create orders from service agreements.
 *
 * Test code in CreateOrderFromAgreementTest class.
 */
global class CreateOrderFromAgreement_Batch implements Database.Batchable<sObject>, Database.Stateful {

    /* Variables */
    
    global Id agreementId;
    global Id billingId;
    global Boolean fromCreateOrders;
  /*  global String month; */
  /*  global static Map<String, Integer> monthMap = new Map<String, Integer>
        { 'January' => 1, 'February' => 2, 'March' => 3, 'April' => 4, 'May' => 5, 'June' => 6, 'July' => 7, 'August' => 8,
          'September' => 9, 'October' => 10, 'November' => 10, 'December' => 12 }; */
    public static Set<Id> testBillingIds = new Set<Id>(); 
    global Id userId;
  /*  global String year; */

    /* Constructor */
  
    public CreateOrderFromAgreement_Batch(/*String mo, String yr,*/ Id agreeId, Boolean fromOrders, Id usrId) {
        agreementId = agreeId;
       /* month = mo;
        year = yr; */
        fromCreateOrders = fromOrders;
        userId = usrId;
    }
    
    public CreateOrderFromAgreement_Batch(Id billId, Id usrId) {
        billingId = billId;
        fromCreateOrders = false;
        userId = usrId;
    }

    /* Batch Methods */
  
    global Database.QueryLocator start(Database.BatchableContext BC) {
      /*  Integer theMonth = monthMap.get(month);
        Integer theYear = Integer.valueOf(year); */
      /*  Date nextDate = Date.newInstance(theYear, theMonth, 1);
        nextDate = nextDate.addMonths(1).addDays(-1); */
        if (!Test.isRunningTest() && fromCreateOrders != null && fromCreateOrders) {
            return Database.getQueryLocator([select Service_Agreement__r.Service_Location__c, Bill_to_Account__c, Service_Agreement__r.Name,
                Bill_To_Account__r.Name, Next_Billing_Start_Date__c, Next_Billing_End_Date__c, Service_Agreement__c, 
                Service_Agreement__r.Last_Opportunity_Change_Type__c, Service_Agreement__r.Price_Book__c 
                from Billing_Agreement__c where /*Next_Billing_Date__c <= :nextDate */ ready_to_invoice__c = true]);
        }
        if (!Test.isRunningTest() && agreementId != null) {
            return Database.getQueryLocator([select Service_Agreement__r.Service_Location__c, Bill_to_Account__c, Service_Agreement__r.Name,
                Bill_To_Account__r.Name, Next_Billing_Start_Date__c, Next_Billing_End_Date__c, Service_Agreement__c, 
                Service_Agreement__r.Last_Opportunity_Change_Type__c, Service_Agreement__r.Price_Book__c 
                from Billing_Agreement__c where service_agreement__c = :agreementId and /*Next_Billing_Date__c <= :nextDate*/
                ready_to_invoice__c = true]);
        }
        if (!Test.isRunningTest()) {
            return Database.getQueryLocator([select Service_Agreement__r.Service_Location__c, Bill_to_Account__c, Service_Agreement__r.Name,
                Bill_To_Account__r.Name, Next_Billing_Start_Date__c, Next_Billing_End_Date__c, Service_Agreement__c, 
                Service_Agreement__r.Last_Opportunity_Change_Type__c, Service_Agreement__r.Price_Book__c 
                from Billing_Agreement__c where service_agreement__c = :agreementId and ready_to_invoice__c = true and Id = :billingId]);
        }
        return Database.getQueryLocator([select Service_Agreement__r.Service_Location__c, Bill_to_Account__c, Service_Agreement__r.Name,
            Bill_To_Account__r.Name, Next_Billing_Start_Date__c, Next_Billing_End_Date__c, Service_Agreement__c, 
            Service_Agreement__r.Last_Opportunity_Change_Type__c, Service_Agreement__r.Price_Book__c 
            from Billing_Agreement__c where Id in :testBillingIds]);
    }
  
    global void execute(Database.BatchableContext BC, List<Billing_Agreement__c> scope) {
        CreateOrderFromAgreementController.buildOrders(scope[0]);
    }

    global void finish(Database.BatchableContext BC) { 
        User user = [select email from User where Id = :userId];
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new List<String> { user.email });
        mail.setSenderDisplayName('Batch Billing');
        mail.setSubject('Batch Billing');
        mail.setPlainTextBody('Batch Billing has completed.');
        if (!Test.isRunningTest()) {
            try {
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            } catch (Exception e) {
                // do nothing -- mass email issue
            }
        }
    }
}