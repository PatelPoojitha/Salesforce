global class callrevu_AttachmentsToFilesBatch implements Database.Batchable<sObject>{

    public final String query;
 
    public callrevu_AttachmentsToFilesBatch(String q){
        query=q;
    }
 
    global Database.QueryLocator start(Database.BatchableContext BC){
       return Database.getQueryLocator(query);
    }

 
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        List<Attachment> atts = new List<Attachment>();
        for(sObject obj : scope) {
            if(obj.getSObjects('Attachments')!=null && obj.getSObjects('Attachments').size()>0){
                atts.addAll((List<Attachment>) obj.getSObjects('Attachments'));
            }
        }
        callrevu_AttachmentsToFilesHelper.createFiles(atts);
        callrevu_AttachmentsToFilesHelper.updateRecords(scope);

    }
 
    global void finish(Database.BatchableContext BC){
    }
 }