/*
*********************************************************
*   Apex Class Name    : AIToxicWordCheck
*   Created Date       : July 24, 2024
*   @description       : Call AIToxicWordCheckService class and get response.
*
*   @author            : CoreFlex
*/
public class AIToxicWordCheck {
    
    /*
    *********************************************************
    @description    : Invocable method to is used to check sentence is toxic or not.
    @param          : List String sentence
    @return         : Boolean
    ********************************************************
    */
	@InvocableMethod(label='Check AI Toxic Word')
	public static List<Boolean> checkSentences(List<String> inputToxicSentenceList) {
        List<Boolean> isToxicSentences = new List<Boolean>{false};
        try {
            String response = AIToxicWordCheckService.makePostRequest(inputToxicSentenceList[0]);
            System.debug(response);
            ResponseWrapper r = (ResponseWrapper) JSON.deserializeStrict(response, ResponseWrapper.class);
            
            isToxicSentences =  new List<Boolean>{r.toxicity == 'Toxic'};
            return isToxicSentences;
        } catch(Exception e) {
            // Call method of fault mail service class
            String faultMail =  FaultMailService.callAIToxicityFaultMailFlow('AIToxicWordCheck Apex class error', 'Error: ' + e.getMessage(), 'checkSentences method');
			System.debug(faultMail);
            
            System.debug('Exception is : ' + e.getMessage());
            return isToxicSentences;
        }
    }
    
    public class ResponseWrapper {
        public String toxicity;
        public String user_text;
    }
}