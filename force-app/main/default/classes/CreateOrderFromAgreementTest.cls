/*
    Developer: Jim Hyland <jon@shippconsulting.com>
    
    Description:
       Tests for CreateOrderFromAgreementController and CreateOrderFromAgreement_Batch
*/
@isTest
public class CreateOrderFromAgreementTest {

    /* Variables */
    
    private static Billing_Agreement__c billing;
    private static Service_Agreement__c contract;

    /* Test Methods */
    
    static {
        
        // set up test data
        Account account = TestUtil.createAccount();
        Contact contact = TestUtil.createContact();
        Product2 theProduct = TestUtil.createProduct();
        contract = new Service_Agreement__c(Service_Location__c = account.Id, Authorization_Contact__c = contact.Id,
            crm__c = 'eLead1', Preferred_Contact_For_Billing__c = contact.Id, current__c = 'CallBright', bill_to_account__c = account.Id,
            Bill_To_Share_Account__c = account.Id, Price_Book__c = Test.getStandardPricebookId(), is_test__c = true);
        insert contract;
        PricebookEntry entry = new PricebookEntry(Pricebook2Id = Test.getStandardPricebookId(), product2Id = theProduct.Id, unitPrice = 1, 
            is_test__c = true); 
        insert entry;
        billing = new Billing_Agreement__c(Service_Agreement__c = contract.Id, Next_Billing_Start_Date__c = system.today().toStartOfMonth(),
            ready_to_invoice__c = true);
        insert billing;
        Service_Agreement_Products__c product = new Service_Agreement_Products__c(CallRevu_Contract__c = contract.Id, 
            product__c = theProduct.Id, next_billing_date__c = system.today(), bill_to_account__c = account.Id, MRR__c = 1,
            Bill_To_Share_Account__c = account.Id, Effective_Date__c = system.today().toStartOfMonth(), 
            End_Date__c = system.today().toStartOfMonth().addDays(27), quantity__c = 1, 
            Price_Per_Unit__c = 1, PricebookEntryId__c = entry.Id, invoice_type_to_create__c = 'Monthly',  is_test__c = true);
        insert product; 
    }
    
    @isTest
    private static void testCreateOrderFromAgreementController() {
        
        // run tests
        CreateOrderFromAgreementController con = new CreateOrderFromAgreementController();
    /*    CreateOrderFromAgreementController.setupComponent();*/
    /*    String year = String.valueOf(system.today().year()); */
        Test.startTest();
        CreateOrderFromAgreementController.CreateOrderReturn orderReturn = CreateOrderFromAgreementController.buildOrder(contract.Id,/* 'January', year,*/
            true); 
        Test.stopTest(); 
        CreateOrderFromAgreementController.CreateOrderReturn billingReturn = CreateOrderFromAgreementController.buildOrderFromBilling(billing.Id);
    }
}