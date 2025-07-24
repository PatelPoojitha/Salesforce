public class AccountCaseInput {
/*Variables that can be populated*/
    @AuraEnabled
    @InvocableVariable(label='List of Accounts')
    public Id recordId;
    
    @AuraEnabled
    @InvocableVariable(label='Case Record Type Id')
    public String caseRecordTypeId;
}