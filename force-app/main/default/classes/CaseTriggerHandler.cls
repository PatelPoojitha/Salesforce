public class CaseTriggerHandler {
    public static void updateCaseCount(List<Case> newCases, Map<Id, Case> oldCaseMap) {
        try {
            Set<Id> accountIds = new Set<Id>();

            // Collect account IDs from new cases
            if (newCases != null) {
                for (Case c : newCases) {
                    case oldcase  = oldCaseMap?.get(c.Id);
                    boolean isUpdatedToClosed = (oldcase?.Status != c.Status && c.IsClosed);
                    boolean isPicklistChanged = (oldcase?.Touchpoint_Origin__c != c.Touchpoint_Origin__c);
                    if (c.AccountId != null && 
                        ((c.Touchpoint_Origin__c == Constants.CASE_TOUCHPOINT_QUARTERLY_REVIEW || 
                         c.Touchpoint_Origin__c == Constants.CASE_TOUCHPOINT_MONTHLY_REVIEW) &&
                         (isPicklistChanged || isUpdatedToClosed)
						)){
                        accountIds.add(c.AccountId);
                    }
                }
            }

            // Collect account IDs from old cases if oldCaseMap is not null
            if (newCases == null) {
                for (Case c : oldCaseMap.values()) {
                    if (c.AccountId != null && 
                        (c.Touchpoint_Origin__c == Constants.CASE_TOUCHPOINT_QUARTERLY_REVIEW || 
                         c.Touchpoint_Origin__c == Constants.CASE_TOUCHPOINT_MONTHLY_REVIEW)) {
                        accountIds.add(c.AccountId);
                             
                    }
                }
            }

            // Exit if no account IDs to process
            if (accountIds.isEmpty()) {
                return;
            }

            // Query to get the count of open review cases for each account
            List<AggregateResult> caseCounts = [
                SELECT AccountId, COUNT(Id) caseCount
                FROM Case
                WHERE AccountId IN :accountIds
                AND RecordType.Name = :Constants.CASE_RECORD_TYPE_NAME
                AND Status != :Constants.CASE_STATUS_CLOSED
                AND (Touchpoint_Origin__c = :Constants.CASE_TOUCHPOINT_QUARTERLY_REVIEW OR 
                     Touchpoint_Origin__c = :Constants.CASE_TOUCHPOINT_MONTHLY_REVIEW)
                GROUP BY AccountId
            ];

            Map<Id, Integer> accountCaseCountMap = new Map<Id, Integer>();
            for (AggregateResult ar : caseCounts) {
                accountCaseCountMap.put((Id) ar.get('AccountId'), (Integer) ar.get('caseCount'));
            }

            List<Account> accountsToUpdate = new List<Account>();
            for (Id accountId : accountIds) {
                Account acc = new Account(Id = accountId);
                acc.Open_Review_Cases__c = accountCaseCountMap.containsKey(accountId) ? accountCaseCountMap.get(accountId) : 0;
                accountsToUpdate.add(acc);
            }

            if (!accountsToUpdate.isEmpty()) {
                update accountsToUpdate;
            }
        } catch (Exception e) {
            System.debug('An unexpected error occurred: ' + e.getMessage());
        }
    }
}