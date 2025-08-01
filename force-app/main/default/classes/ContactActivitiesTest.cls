/*
    Developer:  Jim Hyland <jon@shippconsulting.com>
    
    Description:
       Tests for ContactActivitiesController
*/
@isTest
public class ContactActivitiesTest {

    /* Test Methods */
    
@isTest
    private static void testContactActivitiesController() {
        
        // set up test data
        Contact contact = TestUtil.createContact();
        insert new Task(WhoId = contact.Id, status = 'Completed');
        CallRevu_Lead__c testLead = new CallRevu_Lead__c(contact__c = contact.Id, name = 'Lead');
        insert testLead;
        
        // run tests
        ApexPages.Standardcontroller sc3 = new ApexPages.StandardController(testLead);
        ContactActivitiesController con = new ContactActivitiesController(sc3);
        ContactActivitiesController.getActivityRecords('Task', 'CallRevu_Leads', testLead.Id, 'Completed');
    }    
}