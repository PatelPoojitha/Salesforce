/*
    Developer:  Jim Hyland <jon@shippconsulting.com>
    
    Description:
       Tests for OnboardingChecklistController
*/
@isTest
public class OnboardingChecklistTest {
     
    /* Test Methods */
    
    @isTest
    private static void testOnboardingChecklistController() {
        // set up test data
        Account account = TestUtil.createAccount();
        Contact contact = TestUtil.generateContact(account.Id);
        Contact secondaryContact = TestUtil.createContact(account.Id);
        Contact billingContact = TestUtil.createContact(account.Id);
        contact.firstName = 'abc';
        contact.email = 'j@j.com';
        insert contact;
        Service_Agreement__c contract = new Service_Agreement__c(Service_Location__c = account.Id, Authorization_Contact__c = contact.Id,
            crm__c = 'eLead1', secondary_contact__c = secondaryContact.Id, Preferred_Contact_For_Billing__c = billingContact.Id,
            current__c = 'CallBright', Date_Completed_WL__c = system.now(), Date_Completed_CC__c = DateTime.valueOf('2021-1-23 23:59:00'), 
            Date_Completed_RR__c = DateTime.valueOf('2021-1-31 00:59:00'), Date_Completed_AD_LOA__c = DateTime.valueOf('2021-1-12 12:59:00'),
            Date_Completed_AD_PORT__c = DateTime.valueOf('2021-1-13 13:59:00'), is_test__c = true);
        insert new List<Service_Agreement__c> { contract };
         
        // run tests
        Test.startTest();
        PageReference pageRef1 = Page.OnboardingChecklist;
        Test.setCurrentPage(pageRef1);
        OnboardingChecklistController con1 = new OnboardingChecklistController();
        ApexPages.currentPage().getParameters().put(ContractUpdateController.CONTRACT_ID_PARAM, contract.Id);
        con1 = new OnboardingChecklistController();
        con1.cancelChecklist();
        Test.stopTest();
    } 
}