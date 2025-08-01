@isTest
public class AIToxicWordCheckTest {
	@isTest
    public static void testToxicDataRulePositive() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        List<String> testWords = new List<String>{'How could you be so stupid', 'What a blockhead', 'You are utterly senseless'};
        List<Boolean> results = AIToxicWordCheck.checkSentences(testWords);
       // System.assertEquals(true, results[0], 'Toxic Word Detected.');
    }
    
    @isTest
    public static void testToxicDataRuleNegative() {
        MockHttpResponseGenerator m = new  MockHttpResponseGenerator();
        m.isError = true;
        Test.setMock(HttpCalloutMock.class, m);
        
        List<String> testWords = new List<String>{'1/0'};
        List<Boolean> results = AIToxicWordCheck.checkSentences(testWords);
        System.assertEquals(false, results[0], 'Toxic Word Not Detected.');
    }
    
    // true and false need to check good and bad snetence
    public class MockHttpResponseGenerator implements HttpCalloutMock {
        public Boolean isError = false;
        public HTTPResponse respond(HTTPRequest req) {
            String mockReq;
            HttpResponse res = new HttpResponse();
            
            if(req.getEndpoint()=='http://20.244.4.24:8081/check_toxicity'){
                res.setHeader('Content-Type', 'application/json');
                res.setBody('{"user_text": "i need to speak to higher authority", "toxicity": "Toxic"}');
                res.setStatusCode(200);
            }else {
               system.debug('else condition entered');
               res.setStatusCode(404);
            }
            if(isError){
                res.setHeader('Content-Type', 'application/json');
                res.setBody('');
                res.setStatusCode(200);
            }
            return res;   
        }
    }
}