@isTest
private class EmailMessageServiceTest {

    @isTest
    static void testUpdateContentDocumentToMessage() {
        // Create test EmailMessages
        List<EmailMessage> oldEmailMessages = new List<EmailMessage>();
        List<EmailMessage> newEmailMessages = new List<EmailMessage>();
        for (Integer i = 0; i < 5; i++) {
            EmailMessage oldEmail = new EmailMessage(
                Subject = 'Old Email ' + i,
                TextBody = 'Old Email Body ' + i
            );
            oldEmailMessages.add(oldEmail);
            
            EmailMessage newEmail = new EmailMessage(
                Subject = 'New Email ' + i,
                TextBody = 'New Email Body ' + i
            );
            newEmailMessages.add(newEmail);
        }
        insert oldEmailMessages;
        insert newEmailMessages;
        
        
        List<ContentVersion> newContentVersions = new List<ContentVersion>();
        for (Integer i = 0; i < 5; i++) {
            ContentVersion content = new ContentVersion(
            Title = 'content ' + i,
            PathOnClient = 'content '+ i,
            IsMajorVersion = true,
            VersionData = Blob.valueOf('Test data'),
            ContentLocation = 'S', // Set to 'S' for Salesforce CRM Content
            FirstPublishLocationId = oldEmailMessages[i].Id
        );
        newContentVersions.add(content);
        }
        insert newContentVersions;
        
        /*List<ContentVersion> contents = [Select Id from ContentVersion where Id in :newContentVersions];
        // Create ContentDocumentLinks related to oldEmailMessages
        List<ContentDocumentLink> docLinks = new List<ContentDocumentLink>();
        for (Integer i = 0; i < oldEmailMessages.size(); i++) {
            ContentDocumentLink cdl = new ContentDocumentLink(
                LinkedEntityId = oldEmailMessages[i].Id,
                ContentDocumentId = contents[i].Id,
                ShareType = 'V'
            );
            docLinks.add(cdl);
        }
        insert docLinks;*/
        
        // Call the method to be tested
        Test.startTest();
        List<EmailMessageService.EmailMessageRequest> reqList = new List<EmailMessageService.EmailMessageRequest>();
        EmailMessageService.EmailMessageRequest r = new EmailMessageService.EmailMessageRequest();
        r.newEmailMessages =newEmailMessages;
        r.oldEmailMessages =oldEmailMessages;
        //r.oldEmailMessages =new List<EmailMessage>{oldEmailMsg};
        reqList.add(r);
        EmailMessageService.EmailService(reqList);
        Test.stopTest();
        
        // Verify if the ContentDocumentLinks have been updated
        Set<Id> newEmailMessageIds = (new Map<Id,EmailMessage>(newEmailMessages)).keySet();

        List<ContentDocumentLink> updatedDocLinks = [SELECT Id, LinkedEntityId, ContentDocumentId, ShareType FROM ContentDocumentLink WHERE LinkedEntityId IN :newEmailMessageIds];
        System.assertEquals(oldEmailMessages.size(), updatedDocLinks.size());
    }
}