@isTest
public class CheckBusinessHoursTest {
	
    static BusinessHours bh;
    
    @testSetup
    static void setup() {
		CheckBusinessHoursTest.bh = [SELECT Name from BusinessHours where name = 'ChatBotHours' and IsActive = true]; // use specific
    }
    
    @isTest
    static void checkBusinessHoursByNamePositive() {
        List<String> input = new List<String>();
        if (CheckBusinessHoursTest.bh != null) {
            input.add(CheckBusinessHoursTest.bh.Name);
        }
        else {
	        input.add('default');
        }
        Boolean result = CheckBusinessHours.checkBusinessHoursByName(input)[0];
        System.debug('Result Pos is: ' +result);
        System.assert(result, 'Business Hours Found');
        System.assertEquals(true, result, 'No results returned.');
    }
    @isTest
    static void checkBusinessHoursByNameNegative() {
        List<String> input = new List<String>{'test'}; // using an invalid name
        Boolean result = CheckBusinessHours.checkBusinessHoursByName(input)[0];
        System.debug('Result Neg is: ' + result);
        System.assertEquals(false, result, 'Unexpected result for invalid input.');
    }
    
}