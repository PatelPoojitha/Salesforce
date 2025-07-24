/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
@IsTest
private class dlrs_CallRevu_LeadTest
{
    @IsTest
    private static void testTrigger()
    {
        // Force the dlrs_CallRevu_LeadTrigger to be invoked, fails the test if org config or other Apex code prevents this.
        dlrs.RollupService.testHandler(new CallRevu_Lead__c());
    }
}