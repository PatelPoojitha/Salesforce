public with sharing class callrevu_AttachmentsToFilesHelper {
    public static void createFiles (List<Attachment> attachments) {

        List<Attachment> attachmentsWithBody = [SELECT Id, Name, Description, Body, ContentType, OwnerId, ParentId FROM Attachment WHERE Id IN: attachments];

        Map<Id, Id> attIdToParentId = new Map<Id, Id>();
        Map<Id, ContentVersion> attIdToContentVersion = new Map<Id, ContentVersion>();
        Map<Id, Id> cvIdToAttachmentId = new Map<Id, Id>();

        for(Attachment a : attachmentsWithBody) {
            if(a.ContentType != 'image/jpeg' && a.ContentType != 'image/png') {
                ContentVersion file = new ContentVersion();
                file.ContentLocation = 'S';
                file.VersionData = a.Body;
                file.Title = a.Name;
                file.Description = a.Description;
                file.OwnerId = a.OwnerId;
                file.PathOnClient = '/' + a.Name;
                file.FirstPublishLocationId = a.ParentId;

                attIdToParentId.put(a.Id, a.ParentId);
                attIdToContentVersion.put(a.Id, file);
            }
        }

        insert attIdToContentVersion.values();
        
        for(Id attId : attIdToContentVersion.keySet()) {
            cvIdToAttachmentId.put(attIdToContentVersion.get(attId).Id, attId);
        }

        List<ContentDocumentLink> docLinks = new List<ContentDocumentLink>();

        List<ContentVersion> contentVersions = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id IN: attIdToContentVersion.values()];

        for(ContentVersion cv : contentVersions) {
            ContentDocumentLink cdl = new ContentDocumentLink();
            cdl.ContentDocumentId = cv.ContentDocumentId;
            cdl.LinkedEntityId = attIdToParentId.get(cvIdToAttachmentId.get(cv.Id));
            cdl.ShareType = 'V';

            docLinks.add(cdl);
        }
        
        // insert docLinks;
    }

    public static void updateRecords(List<sObject> objs) {
        List<Id> parentIds = new List<Id>();
        for(sObject obj : objs) {
            obj.put('Attachments_Moved__c', true);
        }
        update objs;
    }
}