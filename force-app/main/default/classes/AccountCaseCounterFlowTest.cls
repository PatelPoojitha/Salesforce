@IsTest

private class AccountCaseCounterFlowTest{

    private static id getEnrollmentCaseRT(){
        return [SELECT Id FROM RecordType WHERE SObjectType = 'Case' AND DeveloperName = 'Enrollment' LIMIT 1].Id;
    }
    
    private static List<Account> createTestAccounts(){
        List<Account> createdAccountRecords = new List<Account>();

        for(Integer accCount = 0; accCount < 3; accCount++){
                createdAccountRecords.add(new Account(
                    Name = 'Test' + accCount,
                    Case_Rollup_Needed__c = true
                ));
                
        }
        
        insert createdAccountRecords;
        
        return createdAccountRecords;
    }
    
    @IsTest
    private static void testAccountCaseCounterFlow(){
        
        Id enrollmentRT = getEnrollmentCaseRT();
        
        List<Account> accountRecordSet = new List<Account>();
        accountRecordSet = createTestAccounts();
        
         Case caseForEnrollment = new Case(
            AccountId = accountRecordSet[0].Id,
            RecordTypeId = enrollmentRT,
            Status = 'New'
        );
        
        insert caseForEnrollment;
    
        
        List<AccountCaseInput> wrapperList = new List<AccountCaseInput>();
        
        for(Account thisAccount : accountRecordSet){
            AccountCaseInput aci = new AccountCaseInput();
            
            aci.recordId = thisAccount.Id;
            aci.caseRecordTypeId = enrollmentRT;
            
            wrapperList.add(aci);
        }
        
        String jsonWrapperList = JSON.serialize(wrapperList);
        List<String> inputWrapperJSON = new List<String>{jsonWrapperList};
        
        Test.startTest();
            AccountCaseCounterFlow.countCasesandUpdateAccounts(inputWrapperJSON);
        Test.stopTest();
        
        List<Account> assertAccounts = [SELECT Id, of_Open_Enrollment_Cases__c,Case_Rollup_Needed__c FROM Account where Id IN :accountRecordSet];
    
        System.assertEquals(1, assertAccounts[0].of_Open_Enrollment_Cases__c, 'Should have a count of 1');
        System.assertEquals(0, assertAccounts[1].of_Open_Enrollment_Cases__c, 'Should have a count of 0');
        System.assertEquals(0, assertAccounts[2].of_Open_Enrollment_Cases__c, 'Should have a count of 0');
        
        System.assertEquals(false, assertAccounts[0].Case_Rollup_Needed__c, 'Should be set to FALSE');

    }
    
    

    
}