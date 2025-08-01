public class CaseSubjectAddressDelete_TriggerHelper {
    
    public static void deleteCases(list <Case> cases){ 
        system.debug('in deleteCases');
        list <String> subjects = new list <String>(); 
        list <String> fromAddresses = new list <String>();
        set <Id> casesToDeleteIds = new set <Id>();
        set <Id> caseIds = new set<Id>();
        
        Case_Delete_Subjects__mdt[] subjectList = [SELECT Subject__c 
                                                   FROM Case_Delete_Subjects__mdt];  
        
        for (Case_Delete_Subjects__mdt sub : subjectList){  
            subjects.add(sub.Subject__c.toLowerCase());
        }
        
        system.debug('subjects: ' + subjects);
        
        Case_Delete_From_Address__mdt [] fromAddressList = [SELECT From_Address__c  
                                                            FROM Case_Delete_From_Address__mdt];
        
        for (Case_Delete_From_Address__mdt address : fromAddressList){
            fromAddresses.add(address.From_Address__c.toLowerCase());
        }
        
        system.debug('fromAddresses: ' + fromAddresses);
        
        
        for (Case cs : cases){
            caseIds.add(cs.Id);
        }
        
        list <Case> casesList = [Select Id, SuppliedEmail, Subject from Case where Id in :caseIds];
        system.debug(casesList);
        
        for (Case cs : casesList){
            for (String subject : subjects){
                if(cs.subject != Null){ 
                    if (cs.subject.toLowerCase().contains(subject)){
                        casesToDeleteIds.add(cs.Id);
                    }
                }
            }
        }
        
        for (Case cs : casesList){
            for (String fromAddress : fromAddresses){          
                if(cs.SuppliedEmail != Null){ 
                    if (cs.SuppliedEmail.toLowerCase().contains(fromAddress)){
                        casesToDeleteIds.add(cs.Id);
                    }
                } 
            }
        }
        
        list <Case> casesToDelete = [Select Id, Subject, SuppliedEmail, Description from Case where Id in :casesToDeleteIds];
      /*  if(casesToDelete.size() > 0){
            sendEmail(Json.serialize(casesToDelete));
            system.debug('sending to future');
        } */
        
        
        //query delete email. If there is a returned value proceed with code to send email for each deleted case
        list <Case_Delete_Email__mdt> deleteEmail = [Select Email__c FROM Case_Delete_Email__mdt limit 1];
        if (deleteEmail[0].Email__c != null){ 
        
            for (Case cs : casesToDelete){ 
            Messaging.Singleemailmessage mail = new Messaging.Singleemailmessage();
            String csSubject = 'Deleted Case Email - ' + cs.Subject;
            String finalSubject;
            String body = 'EmailAddress: ' + cs.SuppliedEmail + '\n';
            body += 'Subject: ' + cs.Subject + '\n';
            body += 'Description: ' + cs.Description + '\n';
            if(csSubject.length() > 80){ 
                finalSubject = csSubject.substring(0, 80);
            } else {
                finalSubject=csSubject;
            }
            mail.setToAddresses(new String[] {deleteEmail[0].Email__c});    //
            mail.setSenderDisplayName('Revu');
            mail.setSubject(finalSubject);
            mail.setBccSender(false);
            mail.setUseSignature(false);
            mail.setPlainTextBody(body);
            system.debug('mail : ' + mail);
            if(!test.isRunningTest()){ 
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
                system.debug('Email Sent!');
            }
        }  
        } 
        
        system.debug('casesToDeletefuture: ' + casesToDelete);
        // sending to future method to handle case deletion 
        sendEmail(Json.serialize(casesToDelete));
       // delete casesToDelete;    
    }
    
    
    @future
    public static void sendEmail (String casesToDeleteString){
        list <Case> casesToDelete = (list<Case>)JSON.deserialize(casesToDeleteString, list<Case>.class);

        delete casesToDelete;
    }
}