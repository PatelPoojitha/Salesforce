/*
    Developer:  Jim Hyland <jon@shippconsulting.com>
    
    Description:
       Tests for Cloner
*/
@isTest
public with sharing class ClonerTest {
    
    /* Constants */

    private static final Integer MULTIPLIER = 3;
    
    /* Test Methods */
    
    @isTest
    private static void testBulkClone() {
        // create test data
        List<Account> sourceAccounts = new List<Account>(); 
        for(Integer i = 0; i < MULTIPLIER; i++) {
            sourceAccounts.add(new Account(name = 'abc'));
        }
        insert sourceAccounts;
        Map<Id, Account> sourceAccountMap 
            = new Map<Id, Account>(sourceAccounts);
    
        // clone test data
        Test.startTest();
        Cloner accountCloner = new Cloner(Schema.SObjectType.Account);
        Map<Id, SObject> genericClonedAccountBySourceIdMap 
            = accountCloner.doClone(sourceAccountMap.keySet());
        Map<Id, Account> clonedAccountBySourceIdMap = new Map<Id, Account>();
        for(Id sourceAccountId : genericClonedAccountBySourceIdMap.keySet()) {
            clonedAccountBySourceIdMap.put(
                sourceAccountId, 
                (Account) genericClonedAccountBySourceIdMap.get(sourceAccountId));
        }
        Test.stopTest();
    
        // verify name field is copied over for each account
        for(Id sourceAccountId : clonedAccountBySourceIdMap.keySet()) {
            Account clonedAccount 
                = clonedAccountBySourceIdMap.get(sourceAccountId);
            Account sourceAccount = sourceAccountMap.get(sourceAccountId);
            system.assertEquals(sourceAccount.name, clonedAccount.name, 
                'Code Failure: Cloner is not working with accounts.');
        }
    }

    @isTest
    private static void testIndividualClone() {
        // create test data
        Account sourceAccount = new Account(name = 'abc');
        insert sourceAccount;
    
        // clone test data
        Test.startTest();
        Cloner accountCloner = new Cloner(Schema.SObjectType.Account);
        SObject genericClonedAccount = accountCloner.doClone(sourceAccount.id);
        Test.stopTest();
    
        // verify name field is copied over for account
        Account clonedAccount = (Account) genericClonedAccount;
        system.assertEquals(sourceAccount.name, clonedAccount.name, 
            'Code Failure: Cloner is failing on a single clone with accounts.');
    }

    @isTest
    private static void testSubstitutionRules() {
        // create test data
        Account sourceAccount = new Account(name = 'abc');
        insert sourceAccount;
    
        // clone while changing account name to new value
        String newValue = 'New Name';
        Test.startTest();
        Cloner accountCloner = new Cloner(Schema.SObjectType.Account);
        accountCloner.addSubstitutionRule('name',newValue);
        SObject genericClonedAccount = accountCloner.doClone(sourceAccount.id);
        Test.stopTest();
    
        // verify name field was substituted correctly
        system.assertEquals(newValue, genericClonedAccount.get('name'), 
            'Code Failure: Cloner substitution rule is failing.');
    }
}