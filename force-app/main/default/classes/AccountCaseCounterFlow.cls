public class AccountCaseCounterFlow {

/*Method that's used in action*/

    @InvocableMethod(label='Count Cases for Account')
    public static void countCasesandUpdateAccounts(List<String> inputJson) {
    
        List<AccountCaseInput> inputIds = (List<AccountCaseInput>) JSON.deserialize(inputJson[0], List<AccountCaseInput>.class);
        
        Set<Id> accIds = new Set<Id>();
        
        for(AccountCaseInput input : inputIds){
            accIds.add(input.recordId);
        }
        
        String caseRecordTypeId = inputIds[0].caseRecordTypeId;
        
        List<Case> openEnrollmentCases = [SELECT Id, AccountId, Status FROM Case WHERE AccountId IN : accIds AND isClosed = false AND recordtypeId = :caseRecordTypeId];
        
        Map<Id,Integer> accCaseCount = new Map<Id,Integer>();
        
        for(Case thisCase : openEnrollmentCases){
            Id accId = thisCase.AccountId;
            
            if(!accCaseCount.containsKey(accId)){
                accCaseCount.put(accId,0);
            }
            
            accCaseCount.put(accId, accCaseCount.get(accId) +1);
        }
     List<Account> accountsToUpdate = new List<Account>();
     
     for(Id accId : accIds){
         Integer caseCount = accCaseCount.containsKey(accId) ? accCaseCount.get(accId) : 0;
         
         accountsToUpdate.add(new Account(
             Id = accId,
             of_Open_Enrollment_Cases__c = caseCount,
             Case_Rollup_Needed__c = false
         ));
     } 
     
     if(!accountsToUpdate.isEmpty()){
         update accountsToUpdate;
     }  
        
    }
}