@isTest
private class UpdateOpportunityLineItemsBatchTest {

    @isTest
    static void testBatchJob() {
        
        // set up test data
        Account account = TestUtil.createAccount();
        Opportunity opportunity = TestUtil.generateOpportunity(account.Id);
        opportunity.order_type__c = 'New';
        opportunity.pricebook2Id = Test.getStandardPricebookId();
        insert opportunity;
        Product2 product = TestUtil.generateProduct();
        product.product_category__c = 'Call Tracking Packages';
        Product2 product1 = TestUtil.generateProduct();
        product1.product_category__c = 'Call Tracking Packages';
        Product2 associatedProduct = TestUtil.generateProduct();
        associatedProduct.product_category__c = 'Call Tracking Packages';
        insert new List<Product2> { product, product1, associatedProduct };
        product.Associated_Product_1__c = associatedProduct.Id;
        product.Associated_Product_2__c = associatedProduct.Id;
        product.Associated_Product_3__c = associatedProduct.Id;
        product.Associated_Product_4__c = associatedProduct.Id;
        product.Associated_Product_5__c = associatedProduct.Id;
        product.Associated_Product_6__c = associatedProduct.Id;
        product.Associated_Product_7__c = associatedProduct.Id;
        product.Associated_Product_8__c = associatedProduct.Id;
        product.Associated_Product_9__c = associatedProduct.Id;
        product.Associated_Product_10__c = associatedProduct.Id;
        update product;
        PricebookEntry entry1 = new PricebookEntry(Pricebook2Id = Test.getStandardPricebookId(), product2Id = product.Id, unitPrice = 1, 
            isActive = true);
        PricebookEntry entry2 = new PricebookEntry(Pricebook2Id = Test.getStandardPricebookId(), product2Id = product1.Id, unitPrice = 1, 
            isActive = true);
        PricebookEntry entry3 = new PricebookEntry(Pricebook2Id = Test.getStandardPricebookId(), product2Id = associatedProduct.Id, unitPrice = 1, 
            isActive = true);
        insert new List<PricebookEntry> { entry1, entry2, entry3 };
        OpportunityLineItem line1 = new OpportunityLineItem(opportunityId = opportunity.Id, product2Id = product.Id, pricebookEntryId = entry1.Id,
            quantity = 1, unitPrice = 1);
        OpportunityLineItem line2 = new OpportunityLineItem(opportunityId = opportunity.Id, product2Id = product1.Id, pricebookEntryId = entry2.Id,
            quantity = 1, unitPrice = 1);
        insert new List<OpportunityLineItem> { line1, line2 };

        // Execute the batch job
        Test.startTest();
        UpdateOpportunityLineItemsBatch batchJob = new UpdateOpportunityLineItemsBatch();
        Database.executeBatch(batchJob, 200);
        Test.stopTest();

    }
}