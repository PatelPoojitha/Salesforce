global class UpdateOpportunityLineItemsBatch implements Database.Batchable<SObject> {

    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator([
            SELECT Id, Minutes__c, Opportunity.StageName
            FROM OpportunityLineItem
            WHERE Minutes__c = 0 AND (NOT Opportunity.StageName LIKE '%Closed%')
        ]);
    }

    global void execute(Database.BatchableContext BC, List<OpportunityLineItem> scope) {
        // Update the modified records
        update scope;
    }

    global void finish(Database.BatchableContext BC) {
        // Any additional logic to execute after the batch job finishes
    }
}