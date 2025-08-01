/*
 * Developer: Jim Hyland <jon@shippconsulting.com>
 *  
 * Description: Order the Opportunity trigger processing.
 */
trigger Opportunity_AfterUpdate on Opportunity (after update) {

    OpportunityTriggerHelper opportunityHelper = new OpportunityTriggerHelper(trigger.new, trigger.oldMap);
    opportunityHelper.cloneOpportunity();
}