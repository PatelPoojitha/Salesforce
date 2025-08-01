@isTest
private class callrevu_AttachmentsToFilesBatchTest {
    static testmethod void test() { 
        
        Task c = new Task(Subject = 'Email:');
        insert c;
        
        Test.startTest();
        String query = 'SELECT Id, (SELECT Id FROM Attachments WHERE ContentType = \'image/jpeg\' OR ContentType = \'image/png\') FROM Task WHERE Subject LIKE \'%Email:%\' LIMIT 50000000';
        callrevu_AttachmentsToFilesBatch b = new callrevu_AttachmentsToFilesBatch(query);
        	Database.executeBatch(b);
        Test.stopTest();
    }
}