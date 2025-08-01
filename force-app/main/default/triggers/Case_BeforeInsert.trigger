trigger Case_BeforeInsert on Case (before insert) {  
   /* for (Case cs : trigger.New){
        
        cs.Type = 'Archived Salesforce Cases';
        cs.Case_Subtype__c = 'Add Employee'; 
    }*/
    
    CaseTriggerHelper caseHelper = new CaseTriggerHelper(trigger.new, trigger.oldMap);
    caseHelper.calculateHours();   
}