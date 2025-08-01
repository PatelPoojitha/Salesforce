/*
    Developer:  Jim Hyland <jon@shippconsulting.com>
    
    Description:
       Tests for OpportunityTriggerController
*/
@isTest
public class OpportunityTriggerTest {
    
    /* Test Methods */
    
    @isTest
    private static void testOpportunityTriggerController() {
        
        // set up test data
        Map<String, Id> recordTypes = new Map<String, Id>();
        for (RecordType recordType : [select developerName from RecordType where sObjectType = 'Opportunity' 
                and (developerName = 'Trial_Pilot' or developerName = 'Dealer_Opportunity')]) {
            recordTypes.put(recordType.developerName, recordType.Id);
        }
        Account account = TestUtil.generateAccount();
        account.Lead_Source__c = 'Referral';
        account.Lead_Sub_source__c = 'New Dealer';
        insert account;
        Opportunity opportunity = TestUtil.generateOpportunity(account.Id);
        opportunity.stageName = '4 - Trial/Pilot Pending';
        opportunity.recordTypeId = recordTypes.get('Trial_Pilot');
        opportunity.pricebook2Id = Test.getStandardPricebookId();
        insert opportunity;
        Product2 product = TestUtil.createProduct();
        PricebookEntry item = new PricebookEntry(Product2Id = product.Id, UnitPrice = 0, Pricebook2Id = Test.getStandardPricebookId(), isActive = true, 
            is_test__c = true);
        insert item;
        OpportunityLineItem line = TestUtil.generateOpportunityLineItem(opportunity.Id, item.Id);
        //insert line;
         
        // run tests
        opportunity.stageName = 'Converted';
        update opportunity;
      /*  List<Opportunity> clonedOpportunities = [select recordTypeId, stageName, related_opportunity__c 
            from Opportunity where related_opportunity__c = :opportunity.Id limit 2];
        system.assertEquals(1, clonedOpportunities.size());
        system.assertEquals(recordTypes.get('Dealer_Opportunity'), clonedOpportunities[0].recordTypeId);
        system.assertEquals('3 - Proposal', clonedOpportunities[0].stageName);
        system.assertEquals(opportunity.Id, clonedOpportunities[0].related_opportunity__c);
        List<OpportunityLineItem> clonedLines = [select Id from OpportunityLineItem where opportunityId = :clonedOpportunities[0].Id limit 2];
        system.assertEquals(clonedLines.size(), 1); */
    }
}