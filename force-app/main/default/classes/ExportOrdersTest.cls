/*
    Developer:  Jim Hyland <jon@shippconsulting.com>
    
    Description:
       Tests for ExportOrdersController
*/
@isTest
public class ExportOrdersTest {
    
    /* Variables */
    
    public static Id pricebookId;
    public static PricebookEntry entry;
    private static Product2 product;
    public static String productCode;
    
    static {
        product = TestUtil.createProduct();
        pricebookId = Test.getStandardPricebookId();
        entry = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = product.Id, unitPrice = 10000, isActive = true, 
            useStandardPrice = false, is_test__c = true); 
        insert entry; 
        productCode = entry.Id;
    } 

    /* Test Methods */
    
    @isTest
    private static void testExportOrdersController() {
        
        // set up test data
        Account account = TestUtil.createAccount();
        Order testOrder = new Order(accountId = account.Id, status = 'Draft', pricebook2Id = pricebookId, 
            effectiveDate = system.today(), invoice_type__c = 'New', is_test__c = true);
        insert testOrder;
        insert new OrderItem(orderId = testOrder.Id, PricebookEntryId = productcode, quantity = 1, UnitPrice = 1, is_test__c = true);
           
        // run tests
        ExportOrdersController con = new ExportOrdersController();
        ExportOrdersController.buildOrders();
        ExportOrdersController.exportOrders(testOrder.Id);
    }
}