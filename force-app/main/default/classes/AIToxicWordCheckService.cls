/*
*********************************************************
*   Apex Class Name    : AIToxicWordCheckService
*   Created Date       : July 24, 2024
*   @description       : HTTP Callout class for configure API and callout.
*
*   @author            : CoreFlex
*/
public class AIToxicWordCheckService {
    
    /*
    *********************************************************
    @description    : method to is used to check sentence is toxic or not.
    @param          : String sentence
    @return         : JSON response
    ********************************************************
    */
    public static String makePostRequest(String sentence) {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        // get custom metadata
        Flow_Configuration_Settings__mdt FCS = Flow_Configuration_Settings__mdt.getInstance('Flow_Settings');
        //request.setEndpoint(FCS.AIToxicWordCheckService_API_URL__c);
        request.setMethod('POST');
        // Set the request body
        String jsonBody = '{"sentence":"'+sentence+'"}';
        request.setBody(jsonBody);
        
        // Set content type to JSON
        request.setHeader('Content-Type', 'application/json');
        
        // Optionally, set other headers
        // request.setHeader('Authorization', 'Bearer <token>');
        
        HttpResponse response = http.send(request);
        
        if (response.getStatusCode() == 200) {
            // Successfully received the response
            String responseBody = response.getBody();
            // Parse the JSON response
            // Do something with the parsed data
            return responseBody;
        } else {
            String errorStr = 'Error: \n' + response.getStatusCode() + '\n ' + response.getStatus() +'\n '+ response.getBody();
            // Call method of fault mail service class
            String faultMail =  FaultMailService.callAIToxicityFaultMailFlow('AIToxicWordCheckService Apex class error', errorStr, 'makePostRequest method');
            System.debug(faultMail);
            // Handle error
            return errorStr;
        }
    }
}