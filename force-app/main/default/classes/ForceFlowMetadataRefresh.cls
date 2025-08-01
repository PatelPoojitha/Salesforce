public class ForceFlowMetadataRefresh {
    @InvocableMethod
    public static void run(List<AccountCaseInput> input) {
        System.debug('This is just to force metadata refresh in Flow.');
    }
}