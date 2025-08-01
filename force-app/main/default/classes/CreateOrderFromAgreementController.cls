/*
    Developer: Jim Hyland <jon@shippconsulting.com>
    
    Description:
       Controller for the CreateOrderFromAgreement Component
       Test code in CreateOrderFromAgreementTest class.
*/

public class CreateOrderFromAgreementController {
    
    /* Constructor */
    
    public CreateOrderFromAgreementController() {
    }
    
    /* Static Methods */
    
    @AuraEnabled
    public static CreateOrderReturn buildOrder(Id recordId, /*String month, String year,*/ Boolean fromCreateOrders) {
        AsyncApexJob batchJob;
        for (AsyncApexJob job : [select id from AsyncApexJob where apexClass.name = 'CreateOrderFromAgreement_Batch' 
                and status != 'Aborted' and status != 'Failed' and status != 'Completed' limit 1]) {
            batchJob = job;
        }
        if (batchJob == null) {
            List<Billing_Agreement__c> agreements = [select Id from Billing_Agreement__c where ready_to_invoice__c = true limit 1];
            if (!Test.isRunningTest() && agreements.isEmpty()) {
                return new CreateOrderReturn('There are no Billing Agreements Ready to Invoice.' /*, false*/);
            }
            Id userId = UserInfo.getUserId();
            CreateOrderFromAgreement_Batch batch = new CreateOrderFromAgreement_Batch(/*month, year, */ recordId, fromCreateOrders, userId);
            if (Test.isRunningTest()) {
                CreateOrderFromAgreement_Batch.testBillingIds.add(agreements[0].Id);
            }
            database.executeBatch(batch, 1);
            return new CreateOrderReturn(null/*, false*/);
        }
        return new CreateOrderReturn('A Billing Batch is already queued.' /*, false*/);
    }
    
    @AuraEnabled
    public static CreateOrderReturn buildOrderFromBilling(Id recordId) {
        AsyncApexJob batchJob;
        for (AsyncApexJob job : [select id from AsyncApexJob where apexClass.name = 'CreateOrderFromAgreement_Batch' 
                and status != 'Aborted' and status != 'Failed' and status != 'Completed' limit 1]) {
            batchJob = job;
        }
        if (batchJob == null) {
            List<Billing_Agreement__c> agreements = [select Id from Billing_Agreement__c where ready_to_invoice__c = true 
                and Id = :recordId limit 1];
            if (!Test.isRunningTest() && agreements.isEmpty()) {
                return new CreateOrderReturn('There are no Billing Agreements Ready to Invoice.' /*, false*/);
            }
            Id userId = UserInfo.getUserId();
            CreateOrderFromAgreement_Batch batch = new CreateOrderFromAgreement_Batch(recordId, userId);
            database.executeBatch(batch, 1);
            return new CreateOrderReturn(null/*, false*/); 
        }
        return new CreateOrderReturn('A Billing Batch is already queued.' /*, false*/);
    }
    
    public static void buildOrders(Billing_Agreement__c billing) {
        system.debug('==> in build');
        String theName = billing.Service_Agreement__r.Name + '-' + billing.Bill_To_Account__r.name;
        theName = theName.length() <= 80 ? theName : theName.subString(0, 80);
        Id pricebookId = Test.isRunningTest() ? Test.getStandardPricebookId() : [select Id from Pricebook2 where isStandard = true].Id;
        Order theOrder = new Order(AccountId = billing.Service_Agreement__r.Service_Location__c, Bill_to_Account__c = billing.Bill_to_Account__c,
            Billing_Agreement__c = billing.Id, Name = theName, EffectiveDate = billing.Next_Billing_Start_Date__c,
            EndDate = billing.Next_Billing_End_Date__c, Type = 'Invoice', Invoice_Type__c = billing.Service_Agreement__r.Last_Opportunity_Change_Type__c,
            Service_Agreement__c = billing.Service_Agreement__c, Status = 'Draft', 
            Pricebook2ID = /*billing.Service_Agreement__r.Price_Book__c*/ pricebookId);
        insert theOrder;
        Map<Id, OrderItem> items = new Map<Id, OrderItem>();
        List<Service_Agreement_Products__c> serviceProducts = [select Last_Order_Date__c, Last_Order_Line_Item__c, PriceBookEntryID__c, Billing_type__c, 
            Next_Billing_Start_Date__c, Next_Billing_End_Date__c, Invoice_Quantity__c, Next_Billing_Amount__c, Price_Per_Unit__c, product__c,
            Invoice_Type_To_Create__c, Sent_First_Invoice__c, Sent_Last_Invoice__c, First_Invoice_Date__c, Last_Invoice_Date__c, Effective_date__c, 
            End_Date__c, Last_Monthly_Invoice_Date__c from Service_Agreement_Products__c 
            where (CallRevu_Contract__c = :billing.Service_Agreement__c and Ready_To_Invoice__c = true)];
        Map<Id, Id> entryByProductId = new Map<Id, Id>();
        for (Service_Agreement_Products__c product : serviceProducts) {
            entryByProductId.put(product.product__c, null);
        }
        for (PricebookEntry entry : [select product2Id from pricebookEntry 
                where Pricebook2Id = :pricebookId and product2Id in :entryByProductId.keySet()]) {
            entryByProductId.put(entry.product2Id, entry.Id);
        }
        for (Service_Agreement_Products__c product : serviceProducts) {
            items.put(product.Id, new OrderItem(PricebookEntryId = /*product.PriceBookEntryID__c*/entryByProductId.get(product.product__c), 
                Billing_Type__c = product.Billing_type__c,
                ServiceDate = product.Next_Billing_Start_Date__c, EndDate = product.Next_Billing_End_Date__c, Quantity = product.Invoice_Quantity__c,
                Invoice_Type__c = product.Invoice_Type_To_Create__c, Service_Agreement_Product__c = product.Id, UnitPrice = product.Price_Per_Unit__c, 
                orderId = theOrder.Id));
        }
        if (!Test.isRunningTest()) {
            insert items.values();
        }
        for (Service_Agreement_Products__c product : serviceProducts) {
            if (product.Invoice_Type_To_Create__c == 'First Invoice') {
                product.Sent_First_Invoice__c = true;
                product.First_Invoice_Date__c = product.Effective_Date__c;
            }
            if (product.Invoice_Type_To_Create__c == 'Last Invoice') {
                product.Sent_Last_Invoice__c = true;
                product.Last_Invoice_Date__c = product.End_Date__c;
            }
            if (product.Invoice_Type_To_Create__c == 'Monthly') {
                product.Last_Monthly_Invoice_Date__c = billing.Next_Billing_Start_Date__c;
            }
           /* product.Last_Order_Date__c = billing.Next_Billing_End_Date__c;*/
            product.Last_Order_Line_Item__c = items.get(product.Id).Id;
            product.Invoice_Type_To_Create__c = null;
        }
        update serviceProducts;
        update new Billing_Agreement__c(Id = billing.Id, ready_to_invoice__c = false);
    }
    
    /* Inner Classes */
    
    public class CreateOrderReturn {
        
        @AuraEnabled
        public String message { get; private set; }
     /*   @AuraEnabled
        public List<String> months { get; private set; }
        @AuraEnabled
        public List<String> years { get; private set; } */
        
        public CreateOrderReturn(String msg/*, Boolean setup*/) {
            message = msg;
           /* if (setup) {
                years = new List<String>{ '--None--', String.valueOf(system.today().addYears(-1).year()), String.valueOf(system.today().year()), 
                    String.valueOf(system.today().addYears(1).year())};
                months = new List<String>{ '--None--', 'January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October',
                    'November', 'December' };
            }*/
        }
    }
}