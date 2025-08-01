global class EmailMessageService {
    
    
    global static void UpdateContentDocumentToMessage(List<EmailMessage> oldEmailMsgs,List<EmailMessage> newEmailMsgs){
       Set<Id> oldEmailRecordIds = (new Map<Id,EmailMessage>(oldEmailMsgs)).keySet();
        
       List<ContentDocumentLink> oldDocLinkList = [Select Id,ContentDocumentId, LinkedEntityId,ShareType from ContentDocumentLink  where LinkedEntityId in :oldEmailRecordIds];
       List<ContentDocumentLink> docLinkList = new List<ContentDocumentLink>();
        
        for(ContentDocumentLink cdl : oldDocLinkList){
            for(integer i=0;i < oldEmailRecordIds.size();i++){
                system.debug('i'+i);
                if(cdl.LinkedEntityId == oldEmailMsgs[i].Id){
                 ContentDocumentLink varcontentdoclink =new ContentDocumentLink();
                    varcontentdoclink.LinkedEntityId = newEmailMsgs[i].Id;
                    varcontentdoclink.ShareType = cdl.ShareType;
                    varcontentdoclink.ContentDocumentId = cdl.ContentDocumentId;
                    docLinkList.add(varcontentdoclink);
                }
            }
        }
        insert docLinkList;
    }
    
    global class EmailMessageRequest {
    @InvocableVariable(required=true)
    global List<EmailMessage> oldEmailMessages;

    @InvocableVariable(required=true)
    global List<EmailMessage> newEmailMessages;
    }
    
    @InvocableMethod(label='Link Content Documents' description='Insert the content Document Link.' category='EmailMessage')
    global static void EmailService(List<EmailMessageRequest> EmailMessageRequestList){
        for (EmailMessageRequest request : EmailMessageRequestList) {
          UpdateContentDocumentToMessage(request.oldEmailMessages,request.newEmailMessages);
        }
    }
}