/*
 * Developer: Jim Hyland <jon@shippconsulting.com>
 *  
 * Description: Schedule class for CreateOrderFromAgreement_Batch.
 *
 * Test code in CreateOrderFromAgreementTest class.
 */
 
global class CreateOrderFromAgreement_Schedule implements Schedulable {

    public static final String BATCH_CLASS 
        = 'CreateOrderFromAgreement_Batch';

    global void execute(System.SchedulableContext SC) {
        Type t = Type.forName(BATCH_CLASS);
        Database.Batchable<sObject> batchClass 
            = (Database.Batchable<sObject>) t.newInstance();
        Database.executeBatch(batchClass, 1);
    }
}