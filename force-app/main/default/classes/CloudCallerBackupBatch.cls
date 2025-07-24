public class CloudCallerBackupBatch {

    public static Decimal FahrenheitToCelsius(Decimal fh) {
        Decimal cs = (fh - 32) * 5/9;
        return cs.setScale(2);
    }
}

/*public class CloudCallerBackupBatch implements Database.Batchable<sObject>, Database.Stateful{

    public String query;
    public String errors = '';

    public CloudCallerBackupBatch(String q) {
        if(String.isBlank(q)) {
            query = 'SELECT Id, cloudcaller__Call_Type__c, cloudcaller__CloudCaller_User__c, cloudcaller__Direction__c, ';
                query = query + 'cloudcaller__Duration__c, cloudcaller__From__c, cloudcaller__Phone_Type__c, cloudcaller__Price__c, ';
                query = query + 'cloudcaller__RelatedTo__c, cloudcaller__Related_To_Account__c, cloudcaller__Related_To_Contact__c, ';
                query = query + 'cloudcaller__Related_To_Lead__c, cloudcaller__Status__c, cloudcaller__To__c, Backed_Up__c, ';
                query = query + 'LastModifiedById, CreatedById ';
                query = query + 'FROM cloudcaller__CloudCaller_Call__c WHERE Backed_Up__c = false LIMIT 500000';
        } else {
            query = q;
        }
    }

    public Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }
 
    public void execute(Database.BatchableContext BC, List<sObject> scope){
        Boolean hasErrors = false;
        List<CloudCaller_Call_Backup__c> callsBackupList = new List<CloudCaller_Call_Backup__c>();
        for(sObject call : scope) {
            CloudCaller_Call_Backup__c bkpCall = new CloudCaller_Call_Backup__c(
                //CloudCaller_Call__c = (String) call.get('Id'),
                CloudCaller_User__c = (String) call.get('cloudcaller__CloudCaller_User__c'),
                Direction__c = (String) call.get('cloudcaller__Direction__c'),
                Duration__c = (Decimal) call.get('cloudcaller__Duration__c'),
                From__c = (String) call.get('cloudcaller__From__c'),
                Phone_Type__c = (String) call.get('cloudcaller__Phone_Type__c'),
                Price__c = (Decimal) call.get('cloudcaller__Price__c'),
                RelatedTo__c = (String) call.get('cloudcaller__RelatedTo__c'),
                Related_To_Account__c = (String) call.get('cloudcaller__Related_To_Account__c'),
                Related_To_Contact__c = (String) call.get('cloudcaller__Related_To_Contact__c'),
                Related_To_Lead__c = (String) call.get('cloudcaller__Related_To_Lead__c'),
                Status__c = (String) call.get('cloudcaller__Status__c'),
                To__c = (String) call.get('cloudcaller__To__c'),
                Originally_Last_Modified_By__c = (String) call.get('LastModifiedById'),
                Originally_Created_By__c = (String) call.get('CreatedById')
            );
            call.put('Backed_Up__c', true);
            callsBackupList.add(bkpCall);
        }

        try {
            insert callsBackupList;
        } catch (DmlException e) {
            errors = errors + 'Error inserting. ' + e.getMessage() + ';';
            hasErrors = true;
        }
        if(!hasErrors) {
            update scope;          
        }
     }
 
    public void finish(Database.BatchableContext BC){
        if(!String.isBlank(errors) && !Test.isRunningTest()) {
            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            // Set recipients to two contact IDs.
            // Replace IDs with valid record IDs in your org.
            message.toAddresses = new String[] { 'mathiasmoller@callrevu.com' };
            message.subject = 'Errors running Cloudcaller backup';
            message.plainTextBody = this.errors;
            Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage> {message};
            Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
        }
    }
 }*/