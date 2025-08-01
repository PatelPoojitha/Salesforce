/*
 * Developer: Jim Hyland <jon@shippconsulting.com>
 *  
 * Description: Process ProcessSheet triggers.
 *
 * Test code in OpportunityTriggerTest class.
 */
public class OpportunityTriggerHelper {

    /* Variables */

    private List<Opportunity> opportunities;
    private static Set<Id> opportunitiesPreviouslyCloned = new Set<Id>();
    private Map<String, Id> recordTypes;
    
    /* Constructor */
    
    public OpportunityTriggerHelper(List<Opportunity> newList, Map<Id, Opportunity> oldMap) {
        return;
     /*   recordTypes = new Map<String, Id>();
        for (RecordType recordType : [select developerName from RecordType where sObjectType = 'Opportunity' 
                and (developerName = 'Trial_Pilot' or developerName = 'Dealer_Opportunity')]) {
            recordTypes.put(recordType.developerName, recordType.Id);
        }
        opportunities = new List<Opportunity>();
        for (Opportunity opportunity : newList) {
            if (opportunity.recordTypeId == recordTypes.get('Trial_Pilot') && opportunity.stageName == 'Converted' 
                    && opportunity.stageName != oldMap.get(opportunity.Id).stageName && !opportunitiesPreviouslyCloned.contains(opportunity.Id)) {
                opportunities.add(opportunity);
                opportunitiesPreviouslyCloned.add(opportunity.Id);
            }
        }*/
    }
    
    /* Instance Methods */
    
    public void cloneOpportunity() {
    /*    if (opportunities.isEmpty()) {
            return;
        }
        
        // NB: always add fields in lower case for easier comparison against those included in the field set 
        Set<String> queryFields =  Test.isRunningTest() ? new Set<String> { 'accountid', 'name' } : new Set<String>();
        if (!Test.isRunningTest()) {
            for (Schema.FieldSetMember f : SObjectType.Opportunity.FieldSets.Trial_Pilot_Opportunity_Clone.getFields()) {
                queryFields.add(f.getFieldPath().toLowerCase());
            }
        } 
        String query = 'select id';
        for (String queryField : queryFields) {
            if (queryField != 'id') {
                query += ', ' + queryField;
            }
        }
        query += ' from Opportunity where Id in :opportunities'; 
        Map<Id, Opportunity> clonedOpportunities = new Map<Id, Opportunity>();
        for (Opportunity opportunity : database.query(query)) {
            Opportunity clonedOpportunity = opportunity.clone(false);
            clonedOpportunity.stageName = 'TempStage';
            clonedOpportunity.closeDate = system.today().addDays(15);
            clonedOpportunity.related_opportunity__c = opportunity.Id;
            clonedOpportunities.put(opportunity.Id, clonedOpportunity);
        }
        insert clonedOpportunities.values();
        Cloner opportunityLineCloner = new Cloner(Schema.SObjectType.OpportunityLineItem);
        List<OpportunityLineItem> clonedLines = new List<OpportunityLineItem>();
        for (OpportunityLineItem line : [select opportunityId from OpportunityLineItem where opportunityId in :clonedOpportunities.keySet()]) {
            SObject genericClonedOpportunityLine = opportunityLineCloner.doClone(line.Id);
            genericClonedOpportunityLine.put('opportunityId', clonedOpportunities.get(line.opportunityId).Id);
            clonedLines.add((OpportunityLineItem)genericClonedOpportunityLine); 
        }
        insert clonedLines;
        for (Opportunity opportunity : clonedOpportunities.values()) {
            opportunity.recordTypeId = recordTypes.get('Dealer_Opportunity');
            opportunity.stageName = '3 - Proposal';
        }
        update clonedOpportunities.values(); */
    }
}