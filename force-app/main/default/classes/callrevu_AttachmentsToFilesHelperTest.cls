@isTest
private class callrevu_AttachmentsToFilesHelperTest {

    @TestSetup
    static void makeData(){
        Task t = new Task(Subject = 'Test task');
        insert t;

        Attachment a = new Attachment(Name = 'Test attachment', Body = EncodingUtil.base64Decode('Test attachment body content'), ParentId = t.Id);
        insert a;

    }
    static testmethod void testCreateFiles() { 
        
        Test.startTest();
        callrevu_AttachmentsToFilesHelper.createFiles([SELECT Id FROM Attachment]);
        Test.stopTest();
    }

    static testmethod void testUpdateTask() { 
        
        Test.startTest();
        callrevu_AttachmentsToFilesHelper.updateRecords([SELECT Id FROM Task]);
        Test.stopTest();
    }
}