public class CaseTriggerHelper {

    /* Variables */

    private List<Case> cases;
    private Map<Id, Case> oldCases;
    
    /* Constructor */
    
    public CaseTriggerHelper(List<Case> newList, Map<Id, Case> oldMap) {
        cases = newList;
        oldCases = oldMap;
    }
    
    /* Instance Methods */
    
    public void calculateHours() {
        BusinessHours theBusinessHours = [select Id from BusinessHours where IsDefault = true];
        List<Apex_SLAs__c> slaList = [select Critical_Priority_Response_Hours__c, High_Priority_Response_Hours__c, Medium_Priority_Response_Hours__c, 
            Low_Priority_Response_Hours__c from Apex_SLAs__c limit 1];
        Decimal goalHours;
        DateTime createdDate;
        for (Case theCase : cases) {
            if (theCase.Priority == 'Critical' && !slaList.isEmpty()) {
                goalHours = slaList[0].Critical_Priority_Response_Hours__c;
            } else if (theCase.Priority == 'High' && !slaList.isEmpty()) {
                goalHours = slaList[0].High_Priority_Response_Hours__c;
            } else if (theCase.Priority == 'Medium' && !slaList.isEmpty()) {
                goalHours = slaList[0].Medium_Priority_Response_Hours__c;
            } else if (theCase.Priority == 'Low' && !slaList.isEmpty()) {
                goalHours = slaList[0].Low_Priority_Response_Hours__c;
            } else { 
                goalHours = 0;
            }
            createdDate = theCase.createdDate != null ? theCase.CreatedDate : system.now();
            if (theCase.Response_Start_Date_Time__c == null) { 
                theCase.Response_Start_Date_Time__c = BusinessHours.isWithin(theBusinessHours.Id, createdDate) ?
                    createdDate : BusinessHours.nextStartDate(theBusinessHours.Id, createdDate);
            }
            if (theCase.Response_Goal_Date_Time__c == null || (oldCases != null && (theCase.Priority != oldCases.get(theCase.Id).Priority)
                    || theCase.Response_Start_Date_Time__c != oldCases.get(theCase.Id).Response_Start_Date_Time__c)) {
                theCase.Response_Goal_Date_Time__c = BusinessHours.add(theBusinessHours.Id, theCase.Response_Start_Date_Time__c, 
                    (Long) (goalHours * 3600 * 1000)); 
            }
            if (oldCases != null && theCase.Initial_Response_Date_Time__c != null
                    && theCase.Initial_Response_Date_Time__c != oldCases.get(theCase.Id).Initial_Response_Date_Time__c) {
                theCase.Response_Time_Actual_Minutes__c = Decimal.valueOf(BusinessHours.diff(theBusinessHours.Id, 
                    theCase.Response_Start_Date_Time__c, theCase.Initial_Response_Date_Time__c)) / (60 * 1000);
                theCase.Response_Time_Actual_Hours__c = Decimal.valueOf(BusinessHours.diff(theBusinessHours.Id, 
                    theCase.Response_Start_Date_Time__c, theCase.Initial_Response_Date_Time__c)) / (3600 * 1000);
            }
        }
    }
}