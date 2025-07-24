public class callrevu_AttachmentsBatch implements Database.Batchable<sObject>, Database.Stateful{

    public Integer total {get;set;}
    
   public Database.QueryLocator start(Database.BatchableContext BC){
      this.total = 0;
      return Database.getQueryLocator('SELECT Subject, (SELECT Id FROM Attachments WHERE ContentType = \'image/jpeg\' OR ContentType = \'image/png\') FROM Task WHERE Subject LIKE \'%Email:%\' LIMIT 50000000');
   }

   public void execute(Database.BatchableContext BC, List<sObject> scope){
     for(sobject s : scope){
         if(s.getSObjects('Attachments')!=null && s.getSObjects('Attachments').size()>0){
             this.total = this.total + 1;
         }
     }
    }

   public void finish(Database.BatchableContext BC){
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.toAddresses = new String[] { 'mathiasmoller@callrevu.com' };
        message.subject = 'Total number of Attachments';
        message.plainTextBody = 'Total: ' + this.total;
        Messaging.SingleEmailMessage[] messages =   new List<Messaging.SingleEmailMessage> {message};
        Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
   }
}