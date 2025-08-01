trigger Case_BeforeUpdate on Case (before update) {

    CaseTriggerHelper caseHelper = new CaseTriggerHelper(trigger.new, trigger.oldMap);
    caseHelper.calculateHours();
}