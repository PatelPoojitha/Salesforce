@IsTest
public class CaseTriggerHandlerTest {
    
    @TestSetup
    static void setupTestData() {
        // Create Accounts
        Account acc1 = new Account(Name = 'Test Account 1',Open_Review_Cases__c=0);
        Account acc2 = new Account(Name = 'Test Account 2',Open_Review_Cases__c=0);
        insert new List<Account>{ acc1, acc2 };
        Contact contact1 = new Contact(LastName = 'Test Contact 1', AccountId = acc1.Id);
        Contact contact2 = new Contact(LastName = 'Test Contact 2', AccountId = acc2.Id);
        insert new List<Contact>{ contact1, contact2 };

        // Create Cases with required fields populated
        Case case1 = new Case(AccountId = acc1.Id, ContactId = contact1.Id,
                              RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(Constants.CASE_RECORD_TYPE_NAME).getRecordTypeId(), 
                              Status = 'New');
                              
        Case case2 = new Case(AccountId = acc2.Id, ContactId = contact2.Id,
                              RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(Constants.CASE_RECORD_TYPE_NAME).getRecordTypeId(), 
                              Status = 'New');
                              
        insert new List<Case>{ case1, case2 };
    }
    
    @IsTest
    static void testInsertCases() {
        // Fetch the existing accounts
        Account acc1 = [SELECT Id, Open_Review_Cases__c FROM Account WHERE Name = 'Test Account 1'];
        Account acc2 = [SELECT Id, Open_Review_Cases__c FROM Account WHERE Name = 'Test Account 2'];

        // Verify initial counts
        System.assertEquals(0, acc1.Open_Review_Cases__c);
        System.assertEquals(0, acc2.Open_Review_Cases__c);

        // Fetch a Contact to associate with the new Case
        Contact contact1 = [SELECT Id FROM Contact WHERE AccountId = :acc1.Id LIMIT 1];

        // Insert new cases to trigger the handler
        Test.startTest();
        List<Case> casesToInsert = new List<Case>();
        for (Integer i = 0; i < 500; i++) {
            casesToInsert.add(new Case(AccountId = acc1.Id, ContactId = contact1.Id,
                                       RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(Constants.CASE_RECORD_TYPE_NAME).getRecordTypeId(), 
                                       Status = Constants.CASE_STATUS_NEW, Touchpoint_Origin__c = Constants.CASE_TOUCHPOINT_QUARTERLY_REVIEW));
                                      
        }
        insert casesToInsert;
        Test.stopTest();

        // Verify the counts are updated
        acc1 = [SELECT Id, Open_Review_Cases__c FROM Account WHERE Id = :acc1.Id];
        acc2 = [SELECT Id, Open_Review_Cases__c FROM Account WHERE Id = :acc2.Id];

        System.assertEquals(500, acc1.Open_Review_Cases__c);
        System.assertEquals(0, acc2.Open_Review_Cases__c);  
    }

    @IsTest
    static void testBulkUpdateCases() {
        List<Case> casesToUpdate = [SELECT Id, Status FROM Case LIMIT 500];

        // Update the cases Origin to trigger the handler
        Test.startTest();
        for (Case c : casesToUpdate) {
            //c.Status = Constants.CASE_STATUS_CLOSED;
            c.Touchpoint_Type__c = Constants.CASE_TOUCHPOINT_TYPE_SAM;
           c.Touchpoint_Origin__c = Constants.CASE_TOUCHPOINT_MONTHLY_REVIEW;
            c.Status = Constants.CASE_STATUS_NEW; 
        }
        update casesToUpdate;
        Test.stopTest();

        // Verify the account case count is updated
        Account acc1 = [SELECT Id, Open_Review_Cases__c FROM Account WHERE Name = 'Test Account 1'];
        Account acc2 = [SELECT Id, Open_Review_Cases__c FROM Account WHERE Name = 'Test Account 2'];

        System.assertEquals(1, acc1.Open_Review_Cases__c);
        System.assertEquals(1, acc2.Open_Review_Cases__c);
    }

    @IsTest
    static void testBulkUpdateCasesClosed() {
        List<Case> casesToUpdate = [SELECT Id, Status FROM Case LIMIT 500];
        for (Case c : casesToUpdate) {            
            c.Touchpoint_Type__c = Constants.CASE_TOUCHPOINT_TYPE_SAM;
           c.Touchpoint_Origin__c = Constants.CASE_TOUCHPOINT_MONTHLY_REVIEW;
            c.Status = Constants.CASE_STATUS_NEW; 
        }
        update casesToUpdate;
        Test.startTest();
        for (Case c : casesToUpdate) {
            c.Status = Constants.CASE_STATUS_CLOSED;
            c.Closing_Outcome__c = Constants.CASE_CLOSING_OUTCOME_NO_SURVEY;
        }
        update casesToUpdate;
        Test.stopTest();

        // Verify the account case count is updated
        Account acc1 = [SELECT Id, Open_Review_Cases__c FROM Account WHERE Name = 'Test Account 1'];
        Account acc2 = [SELECT Id, Open_Review_Cases__c FROM Account WHERE Name = 'Test Account 2'];

        System.assertEquals(0, acc1.Open_Review_Cases__c);
        System.assertEquals(0, acc2.Open_Review_Cases__c);
    }

    @IsTest
    static void testBulkDeleteCases() {
        List<Case> casesToUpdate = [SELECT Id, Status FROM Case LIMIT 500];

        // Update the cases status to 'Closed' to trigger the handler
        Test.startTest();
        for (Case c : casesToUpdate) {
               c.Touchpoint_Origin__c = Constants.CASE_TOUCHPOINT_MONTHLY_REVIEW;

        }
        update casesToUpdate;
        delete casesToUpdate;
        Test.stopTest();


        // Verify the account case count is updated
        Account acc1 = [SELECT Id, Open_Review_Cases__c FROM Account WHERE Name = 'Test Account 1'];
        Account acc2 = [SELECT Id, Open_Review_Cases__c FROM Account WHERE Name = 'Test Account 2'];

        System.assertEquals(0, acc1.Open_Review_Cases__c);
        System.assertEquals(0, acc2.Open_Review_Cases__c);
    }

    @IsTest
    static void testEmptyCases() {
        Test.startTest();
        CaseTriggerHandler.updateCaseCount(null, null);
        Test.stopTest();
    }
}