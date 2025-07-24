@isTest
private class callrevu_AttachmentsBatchTest {
    static testmethod void test() { 
        
        Task c = new Task(Subject = 'Email:');
        insert c;
        
        Test.startTest();
            callrevu_AttachmentsBatch b = new callrevu_AttachmentsBatch();
        	Database.executeBatch(b);
        Test.stopTest();
    }
}