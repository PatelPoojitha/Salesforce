trigger CaseTrigger on Case (after insert, after update, after delete) {
    switch on Trigger.operationType {
        when AFTER_INSERT {
                  CaseSubjectAddressDelete_TriggerHelper.deleteCases(Trigger.New);
                  CaseTriggerHandler.updateCaseCount(Trigger.New, null);

        }
        when AFTER_UPDATE {
            CaseTriggerHandler.updateCaseCount(Trigger.New, Trigger.oldMap);
        }
        when AFTER_DELETE {
            CaseTriggerHandler.updateCaseCount(null, Trigger.oldMap);
        }
        when else {}
    }}