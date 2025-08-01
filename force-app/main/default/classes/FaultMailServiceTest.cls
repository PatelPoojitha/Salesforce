@isTest
public class FaultMailServiceTest {
	@isTest
    public static void testFaultMailService() {
        	// Call method of fault mail service class
            String faultMail =  FaultMailService.callFaultMailFlow('Testing Fault Mail', 'Sample error message', 'Sample emlement name');
			System.debug(faultMail);        
    }

}