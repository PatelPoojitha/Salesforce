/*
*********************************************************
*   Apex Class Name    : FaultMailService
*   Created Date       : July 24, 2024
*   @description       : Send error mail using flow.
*
*   @author            : CoreFlex
*/
public class FaultMailService {
    
    /*
    *********************************************************
    @description    : method to is used to pass paramters and call fault send mail flow.
    @param          : String varFlowname, String varFaultMessage, String varElementName
    ********************************************************
    */
    public static String callFaultMailFlow(String varFlowname, String varFaultMessage, String varElementName) {
        try{
            //Create parameter
			Map<String, Object> params = new Map<String, Object>
            {
                'varFlowname' => varFlowname,
                'varFaultMessage' => varFaultMessage,
                'varElementName' => varElementName
            };

			//create instance of Interview
			Flow.Interview.Fault_Path_Flow FaultMail = new Flow.Interview.Fault_Path_Flow(params);

			//Invoke start method
			FaultMail.start();
            
            return 'Apex Fault Mail Sent';

        } catch(Exception e) {
            System.debug('Exception is : ' + e.getMessage());
            return 'Apex Fault Mail not Sent';
        }
    }

}