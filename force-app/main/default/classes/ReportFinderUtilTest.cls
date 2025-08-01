@isTest
public class ReportFinderUtilTest {

    @isTest
    static void testFindReportId() {
        // Initialize the class
        ReportFinderUtil util = new ReportFinderUtil();
        
        // Test with a mock report name (this will not exist in the test environment)
        String mockReportName = 'Nonexistent Report';
        
        // We expect this to throw an exception since no reports exist in test context
        try {
            String reportId = util.findReportId(mockReportName);
            System.assert(false, 'Expected an exception, but none occurred.');
        } catch (QueryException e) {
            // Catch the exception that occurs when no report is found
            System.assertEquals('List has no rows for assignment to SObject', e.getMessage(), 'Correct exception should be thrown.');
        }
    }
}