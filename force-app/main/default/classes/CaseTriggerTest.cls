@isTest
private class CaseTriggerTest {

    @isTest
    private static void testCaseTriggerHelper() {
        
        // set up test data
        Case testCase = TestUtil.generateCase();
        testCase.Type = 'Archived Salesforce Cases';
        testCase.Priority = 'Low';
        testCase.Case_Subtype__c = 'Add Employee';
        Apex_SLAs__c existingSLA = [SELECT Id FROM Apex_SLAs__c LIMIT 1];
        existingSLA.Critical_Priority_Response_Hours__c = 1;
        existingSLA.High_Priority_Response_Hours__c = 1;
        existingSLA.Medium_Priority_Response_Hours__c = 1;
        existingSLA.Low_Priority_Response_Hours__c = 1;
        update existingSLA;
        
        // run tests
        insert testCase;
        testCase.Priority = 'High';
        testCase.Initial_Response_Date_Time__c = system.now();
        update testCase;
    }
}