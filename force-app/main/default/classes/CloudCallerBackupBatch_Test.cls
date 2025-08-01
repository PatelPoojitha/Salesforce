@isTest
private class CloudCallerBackupBatch_Test {
    @isTest static void testWarmTemp() {
       Decimal celsius = CloudCallerBackupBatch.FahrenheitToCelsius(70);
       System.assertEquals(21.11,celsius);
    }
    
    @isTest static void testFreezingPoint() {
        Decimal celsius = CloudCallerBackupBatch.FahrenheitToCelsius(32);
        System.assertEquals(0,celsius);
    }
    @isTest static void testBoilingPoint() {
        Decimal celsius = CloudCallerBackupBatch.FahrenheitToCelsius(212);        
        System.assertEquals(100,celsius,'Boiling point temperature is not expected.');
    } 
    
    @isTest static void testNegativeTemp() {
        Decimal celsius = CloudCallerBackupBatch.FahrenheitToCelsius(-10);
        System.assertEquals(-23.33,celsius);
    }
    
        
        /*cloudcaller__CloudCaller_Call__c call = new cloudcaller__CloudCaller_Call__c();
        call.cloudcaller__Direction__c = 'Outbound';
        call.cloudcaller__Duration__c = 1;
        insert call;

        Test.startTest();
        CloudCallerBackupBatch callerBatch = new CloudCallerBackupBatch(null);
        Id jobid= Database.executeBatch(callerBatch, 200);
        Test.stopTest();
        CloudCaller_Call_Backup__c callBackup = [Select Direction__c, Duration__c FROM CloudCaller_Call_Backup__c];
        cloudcaller__CloudCaller_Call__c originalCall = [Select Backed_Up__c FROM cloudcaller__CloudCaller_Call__c WHERE Id =: call.Id];
        
        System.assertEquals('Outbound', callBackup.Direction__c);
        System.assertEquals(1, callBackup.Duration__c);

        System.assertEquals(true, originalCall.Backed_Up__c);*/
    
}