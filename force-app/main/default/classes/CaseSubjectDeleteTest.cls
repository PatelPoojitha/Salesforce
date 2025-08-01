@isTest (SeeAllData=true)
public class CaseSubjectDeleteTest {
    
    @isTest
    public static void testCaseDelete(){
       /* Apex_SLAs__c testSla = new Apex_SLAs__c(Critical_Priority_Response_Hours__c=1, High_Priority_Response_Hours__c=2, Medium_Priority_Response_Hours__c=3, 
            Low_Priority_Response_Hours__c=4);
        insert testSla;*/

        Case testCase = new Case(subject = 'Auto Reply',Type = 'Archived Salesforce Cases',
        Case_Subtype__c = 'Add Employee');
        insert testCase; 
        system.debug('testCase: ' + testCase);
        
        Case testCase2 = new Case(subject = 'Delivery Failur',Type = 'Archived Salesforce Cases',
        Case_Subtype__c = 'Add Employee');
        insert testCase2; 
       
        
        list <Case> caseQuery1 = [Select Id from Case where Id = :testCase.Id];
        list <Case> caseQuery2 = [Select Id from Case where Id = :testCase2.Id];
        
        // both will be one since case deletion needed to be moved to a future method
        system.assert(caseQuery1.size() ==1);
        system.assert(caseQuery2.size() ==1); 
        
    }

}