@isTest // prevents methods from being called outside test context and excludes code from apex code limits
public class TestUtil {
    /**
     * Author:  Jim Hyland <jon@shippconsulting.com>
     *
     * Class to set up test code
     */
     
    /* Test Lock */

    static {
    // Per the apex documentation it shouldn't be possible to call methods in this class outside of
    // test context, but as of 6/2/12 that wasn't being enforced in sandboxes.
        system.assert(Test.isRunningTest(), 'UTIL_TestUtil methods may only be called from test methods');
    }
    
    /* Quick Test Values */
    
    public static Decimal DEFAULT_PRICE = 1;
    public static Decimal DEFAULT_QUANTITY = 1;
    public static Date TEST_DATE = System.today();
    public static String TEST_STRING = generateRandomString(16);
  
    /* Standard Object Functions */

    // Accounts
    public static Account createAccount() {
        Account account = generateAccount();
        insert account;
        return account;
    }
    public static Account generateAccount() {
        return new Account(name = generateRandomString(16), is_test__c = true);
    }
    
    // Cases
    public static Case createCase() {
        Account account = createAccount();
        return createCase(account.id);
    }
    public static Case createCase(Id accountId) {
        Case theCase = generateCase(accountId);
        insert theCase;
        return theCase;
    }
    public static Case generateCase() {
        Account account = createAccount();
        return generateCase(account.id);
    }
    public static Case generateCase(Id accountId) {
        insert new Apex_SLAs__c(Critical_Priority_Response_Hours__c = 1, High_Priority_Response_Hours__c = 1, Medium_Priority_Response_Hours__c = 1, 
            Low_Priority_Response_Hours__c = 1);
        return new Case(accountId = accountId, is_test__c = true);
    }

    // Contacts
    public static Contact createContact() {
        Account account = createAccount();
        return createContact(account.id);
    }
    public static Contact createContact(Id accountId) {
        Contact contact = generateContact(accountId);
        insert contact;
        return contact;
    }
    public static Contact generateContact() {
        Account account = createAccount();
        return generateContact(account.id);
    }
    public static Contact generateContact(Id accountId) {
        return new Contact(lastName = generateRandomString(), accountId = accountId, is_test__c = true);
    }
    
    // Opportunity
    public static Opportunity createOpportunity(Id accountId) {
        Opportunity testOpportunity = generateOpportunity(accountId);
        insert testOpportunity;
        return testOpportunity;
    }
    public static Opportunity generateOpportunity(Id accountId) {
        Campaign testCampaign = new Campaign(name = generateRandomString(), Type = generateRandomString(), is_test__c = true);
    insert testCampaign;
    return new Opportunity(campaignId = testCampaign.Id, accountId = accountId, name = TEST_STRING, closeDate = TEST_DATE,
        StageName = generateRandomString(8), is_test__c = true);
    }
  
    // Opportunity Line Items
    public static OpportunityLineItem createOpportunityLineItem(Id opportunityId, Id pricebookEntryId) {
        OpportunityLineItem lineItem = generateOpportunityLineItem(opportunityId, pricebookEntryId);
        insert lineItem;
        return lineItem;
    }
    public static OpportunityLineItem generateOpportunityLineItem(Id opportunityId, Id pricebookEntryId) {
        return new OpportunityLineItem(opportunityId = opportunityId, pricebookEntryId = pricebookEntryId,
            quantity = DEFAULT_QUANTITY, totalPrice = DEFAULT_PRICE, is_test__c = true);
    }
    
    // Products
    public static Product2 createProduct() {
        Product2 product = generateProduct();
        insert product;
        return product;
    } 
    public static Product2 generateProduct() {
        return new Product2(name = TEST_STRING, isActive = true, is_test__c = true);
    }
    
    /* Random Functions */

    private static Set<String> priorRandoms;
    public static String generateRandomString(){return generateRandomString(null);}
    public static String generateRandomString(Integer length){
        if(priorRandoms == null)
            priorRandoms = new Set<String>();

        if(length == null) length = 1+Math.round( Math.random() * 8 );
            String characters = 'abcdefghijklmnopqrstuvwxyz1234567890';
            String returnString = '';
            while(returnString.length() < length){
            Integer charpos = Math.round( Math.random() * (characters.length()-1) );
            returnString += characters.substring( charpos , charpos+1 );
        }
        if(priorRandoms.contains(returnString)) {
            return generateRandomString(length);
        } else {
            priorRandoms.add(returnString);
            return returnString;
        }
    }
    public static String generateRandomEmail(){return generateRandomEmail(null);}
    public static String generateRandomEmail(String domain){
        if(domain == null || domain == '')
        domain = generateRandomString() + '.com';
        return generateRandomString() + '@' + domain;
    }

    public static String generateRandomUrl() {
        return 'http://' + generateRandomString() + '.com'; 
    }
  
    /* Test Functions */
    
    @isTest
    private static void randomFunctionsTest() {
        system.assertNotEquals(null, generateRandomString());
        system.assertNotEquals(null, generateRandomEmail());
        system.assertNotEquals(null, generateRandomUrl());
    }
    
    @isTest
    private static void testRandomDoesNotRepeat() {
        // With 36 potential characters, a single length string will have a 75% chance
        // of recurring after 10 iterations.  To ensure we skip repeated randoms run through
        // 10 iterations adding each to the set and confirm the final set size is 10.  Because
        // this is probabilistic this test will catch a bug only 75% of the time.
        Set<String> randoms = new Set<String>();
        for(Integer i = 0; i < 10; i++) {
            randoms.add(TestUtil.generateRandomString(1));
        }    
        system.assertEquals(10, randoms.size());
    }
    
    @isTest
    private static void testStandardObjects1() {
        Account testAccount = createAccount();
        assertIdNotNull(testAccount);
        Opportunity testOpportunity = createOpportunity(testAccount.id);
        assertIdNotNull(testOpportunity);
        assertIdNotNull(createContact());
        assertIdNotNull(createCase());
        Product2 product = createProduct();
        assertIdNotNull(product);
    }
  
    /* Test Helpers */
  
    private static void assertIdNotNull(SObject obj) {
        system.assertNotEquals(null, obj.id);
    }
}