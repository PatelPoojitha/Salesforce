@isTest
public class FaultMailServiceTest {
	@isTest
    public static void testFaultMailService() {
        	// Call method of fault mail service class
            String faultMail =  FaultMailService.callFaultMailFlow('Testing Fault Mail', 'Sample error message', 'Sample emlement name');
			System.debug(faultMail);        
    }
     @isTest
    public static void testFaultMailService1() {
        	// Call method of fault mail service class
            String faultMail =  FaultMailService.callAIToxicityFaultMailFlow('Testing Fault Mail', 'Sample error message', 'Sample emlement name');
			System.debug(faultMail);        
    }
}