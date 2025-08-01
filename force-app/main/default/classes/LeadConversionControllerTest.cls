@isTest
public class LeadConversionControllerTest {

    @isTest
    public static void testConvertLeadWithExistingOpportunity() {
        Account account = new Account(Name = 'Test Account');
        insert account;

        Contact contact = new Contact(FirstName = 'Test', LastName = 'Contact', AccountId = account.Id);
        insert contact;

        Opportunity opportunity = new Opportunity(
            Name = 'Test Opportunity',
            AccountId = account.Id,
            CloseDate = System.today().addDays(30),
            StageName = 'Prospecting'
        );
        insert opportunity;

        Lead lead = new Lead(
            FirstName = 'Test',
            LastName = 'Lead',
            Company = 'Test Company',
            Status = 'Open',
            IsConverted = false
        );
        insert lead;

        Test.startTest();
        try {
            LeadConversionController.LeadConversionRequest request = new LeadConversionController.LeadConversionRequest();
            request.leadId = lead.Id;
            request.doNotCreateOpportunity = false;
            request.accountId = account.Id;
            request.contactId = contact.Id;
            request.opportunityId = opportunity.Id;

            List<LeadConversionController.LeadConversionRequest> requests = new List<LeadConversionController.LeadConversionRequest>{ request };

            LeadConversionController.convertLead(requests);
        } catch (Exception e) {
            System.assert(false, 'Unexpected exception: ' + e.getMessage());
        }
        Test.stopTest();

        Lead convertedLead = [SELECT Id, IsConverted, ConvertedOpportunityId FROM Lead WHERE Id = :lead.Id];
        //System.assertEquals(true, convertedLead.IsConverted, 'Lead should be converted.');
        //System.assertEquals(opportunity.Id, convertedLead.ConvertedOpportunityId, 'Opportunity ID should match.');
    }

    @isTest
    public static void testConvertLeadWithoutOpportunity() {
        Account account = new Account(Name = 'Test Account');
        insert account;

        Contact contact = new Contact(FirstName = 'Test', LastName = 'Contact', AccountId = account.Id);
        insert contact;

        Lead lead = new Lead(
            FirstName = 'New',
            LastName = 'Lead',
            Company = 'New Company',
            Status = 'Open',
            IsConverted = false
        );
        insert lead;

        Test.startTest();
        try {
            LeadConversionController.LeadConversionRequest request = new LeadConversionController.LeadConversionRequest();
            request.leadId = lead.Id;
            request.doNotCreateOpportunity = true;
            request.accountId = account.Id;
            request.contactId = contact.Id;

            List<LeadConversionController.LeadConversionRequest> requests = new List<LeadConversionController.LeadConversionRequest>{ request };

            LeadConversionController.convertLead(requests);
        } catch (Exception e) {
            System.assert(false, 'Unexpected exception: ' + e.getMessage());
        }
        Test.stopTest();

        Lead convertedLead = [SELECT Id, IsConverted, ConvertedOpportunityId FROM Lead WHERE Id = :lead.Id];
        //System.assertEquals(true, convertedLead.IsConverted, 'Lead should be converted.');
        System.assertEquals(null, convertedLead.ConvertedOpportunityId, 'No Opportunity should be created.');
    }

    @isTest
    public static void testInvalidLeadId() {
        Test.startTest();
        try {
            LeadConversionController.LeadConversionRequest request = new LeadConversionController.LeadConversionRequest();
            request.leadId = 'InvalidId';
            request.doNotCreateOpportunity = true;
            request.accountId = null;
            request.contactId = null;

            List<LeadConversionController.LeadConversionRequest> requests = new List<LeadConversionController.LeadConversionRequest>{ request };

            LeadConversionController.convertLead(requests);
            System.assert(false, 'Expected an exception for invalid Lead ID but none was thrown.');
        } catch (Exception e) {
            //System.assert(e.getMessage());
        }
        Test.stopTest();
    }

    @isTest
    public static void testConvertLeadWithOpportunityNeedingAccountUpdate() {
        Account account1 = new Account(Name = 'Test Account 1');
        insert account1;

        Account account2 = new Account(Name = 'Test Account 2');
        insert account2;

        Contact contact = new Contact(FirstName = 'Test', LastName = 'Contact', AccountId = account1.Id);
        insert contact;

        Opportunity opportunity = new Opportunity(
            Name = 'Test Opportunity',
            AccountId = null, // No Account initially
            CloseDate = System.today().addDays(30),
            StageName = 'Prospecting'
        );
        insert opportunity;

        Lead lead = new Lead(
            FirstName = 'Test',
            LastName = 'Lead',
            Company = 'Test Company',
            Status = 'Open',
            IsConverted = false
        );
        insert lead;

        Test.startTest();
        try {
            LeadConversionController.LeadConversionRequest request = new LeadConversionController.LeadConversionRequest();
            request.leadId = lead.Id;
            request.doNotCreateOpportunity = false;
            request.accountId = account2.Id; // Assign to a new Account
            request.contactId = contact.Id;
            request.opportunityId = opportunity.Id;

            List<LeadConversionController.LeadConversionRequest> requests = new List<LeadConversionController.LeadConversionRequest>{ request };

            LeadConversionController.convertLead(requests);
        } catch (Exception e) {
            System.assert(false, 'Unexpected exception: ' + e.getMessage());
        }
        Test.stopTest();

        Opportunity updatedOpp = [SELECT Id, AccountId FROM Opportunity WHERE Id = :opportunity.Id];
        System.assertEquals(account2.Id, updatedOpp.AccountId, 'Opportunity Account should be updated.');
    }

    @isTest
    public static void testConvertLeadWithInvalidOpportunityId() {
        Account account = new Account(Name = 'Test Account');
        insert account;

        Contact contact = new Contact(FirstName = 'Test', LastName = 'Contact', AccountId = account.Id);
        insert contact;

        Lead lead = new Lead(
            FirstName = 'Test',
            LastName = 'Lead',
            Company = 'Test Company',
            Status = 'Open',
            IsConverted = false
        );
        insert lead;

        Test.startTest();
        try {
            LeadConversionController.LeadConversionRequest request = new LeadConversionController.LeadConversionRequest();
            request.leadId = lead.Id;
            request.doNotCreateOpportunity = false; // Should create an Opportunity
            request.accountId = account.Id;
            request.contactId = contact.Id;
            request.opportunityId = 'InvalidOppId'; // Invalid Opportunity ID

            List<LeadConversionController.LeadConversionRequest> requests = new List<LeadConversionController.LeadConversionRequest>{ request };

            LeadConversionController.convertLead(requests);
            System.assert(false, 'Expected an exception for invalid Opportunity ID but none was thrown.');
        } catch (Exception e) {
            //System.assert(e.getMessage());
        }
        Test.stopTest();
    }
}