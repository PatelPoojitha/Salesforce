/*
 * Developer: Jim Hyland <jon@shippconsulting.com>
 *  
 * Description: Controller for page for ImportEmployees page.
 *
 * Test code in ContractUpdateTest class.
 */
public class TestFileLoadController {

    /* Variables */
    
    private List<Ad_Source__c> ads;
    public Service_Agreement__c company { get; set; }
    private List<Active_Employees__c> employees;
    public List<String> errorMsg { get; private set; }
    public Boolean loadAdSources { get; private set; }
    public Attachment newAttachment { get; set; }
  
    /* Constructor */
    
    public TestFileLoadController() {
        newAttachment = new Attachment(); 
        loadAdSources = ApexPages.currentPage().getParameters().containsKey(ContractUpdateController.LOAD_AD_SOURCES);
        if (ApexPages.currentPage().getParameters().containsKey(ContractUpdateController.CONTRACT_ID_PARAM)) {
            buildCompany(ApexPages.currentPage().getParameters().get(ContractUpdateController.CONTRACT_ID_PARAM));
        } else {
            errorMsg = new List<String>();
            errorMsg.add('Missing account id in url.  Please contact your administrator.');
            return;
        }
        List<ContractUpdateController.Employee> emps = new List<ContractUpdateController.Employee>();
        employees = new List<Active_Employees__c>();
        emps = ContractUpdateController.buildEmployees(company.Id);
        for (ContractUpdateController.Employee emp : emps) {
            emp.employee.Id = emp.Id;
            employees.add(emp.employee);
        }
        List<ContractUpdateController.Ad> theAds = new List<ContractUpdateController.Ad>();
        ads = new List<Ad_Source__c>();
        theAds = ContractUpdateController.buildAds(company.Id);
        for (ContractUpdateController.Ad ad : theAds) {
            ad.ad.Id = ad.Id;
            ads.add(ad.ad);
        }
    } 
    
    /* Instance Methods */
    
    private void buildCompany(Id companyId) {
        company = [select partner_implementation__c, Service_Location__r.partner_logo_url__c, Bill_To_Account__r.partner_image_width__c, 
            Bill_To_Account__r.partner_image_height__c from Service_Agreement__c where Id = :companyId];
    } 
    
    public PageReference cancelImport() {
        PageReference nextPage = new PageReference('/apex/contractupdate?' + ContractUpdateController.CONTRACT_ID_PARAM + '=' 
            + ApexPages.currentPage().getParameters().get(ContractUpdateController.CONTRACT_ID_PARAM)
            + '&' + ContractUpdateController.CONTACT_ID_PARAM + '=' 
            + ApexPages.currentPage().getParameters().get(ContractUpdateController.CONTACT_ID_PARAM));
        nextpage.setRedirect(true);
        return nextPage;
    } 
    
    public void previewFile() { 
        errorMsg = null;
        if (String.isBlank(newAttachment.name)) {
            errorMsg = new List<String>();
            errorMsg.add('A file must be selected.');
            return;
        }
        if (newAttachment.body == null || newAttachment.body.size() == 0) {
            errorMsg = new List<String>();
            errorMsg.add('The file is empty.  Please import a different file.');
            return;
        }
        String b64 = EncodingUtil.base64Encode(newAttachment.body);
        newAttachment.body = EncodingUtil.base64Decode(b64);
        String strUrlUTF8 = newAttachment.body.toString();
        String body = EncodingUtil.urlDecode(strUrlUTF8, 'UTF-8');
        List<String> parsedBody = parseBody(body);
        
        // verify attachment format
        errorMsg = new List<String>();
        Integer numFields = loadAdSources ? ContractUpdateController.NUM_OF_AD_FIELDS : ContractUpdateController.NUM_OF_FIELDS;
        if (!parsedBody.isEmpty() && parsedBody.size() < numFields - 1) {
            errorMsg.add('Incorrect file format.\n' + body);
            return;
        } 
        String lastHeading = loadAdSources ? ContractUpdateController.LAST_AD_HEADING : ContractUpdateController.LAST_HEADING;
        if (!parsedBody.isEmpty() && parsedBody[numFields - 1].toLowerCase() == lastHeading) {
            String result = loadAdSources ? processAdFile(parsedBody, 
                    ApexPages.currentPage().getParameters().get(ContractUpdateController.CONTRACT_ID_PARAM), ads, numFields) :
                processFile(parsedBody, ApexPages.currentPage().getParameters().get(ContractUpdateController.CONTRACT_ID_PARAM),
                    employees, numFields);
            if (result != null) {
                errorMsg.add('Error Importing File: ' + result + '\n' + body); 
            } else {
                errorMsg.add('File successfully imported.');
            }
        } else {
            errorMsg.add('Incorrect file format.\n' + body); 
        } 
    }
    
    /* Static Methods */
   
    private static List<String> parseBody(String body) { 
        
        // check for null fields
        while (body.indexOf(',,') >= 0 || body.indexOf('\n\n') >= 0 || body.indexOf('\r\r') >= 0 
                || body.indexOf('\n\r') >= 0 || body.indexOf('\r\n') >= 0 || body.indexOf('\r') >= 0
                || body.indexOf('\r\n\r\n') >= 0 || body.indexOf('\n\r\n\r') >= 0) {
            body = body.replace(',,', ', ,');
            body = body.replace('\r\n\r\n', '\n');
            body = body.replace('\n\r\n\r', '\n');
            body = body.replace('\n\n', '\n');
            body = body.replace('\r\r', '\n');
            body = body.replace('\n\r', '\n');
            body = body.replace('\r\n', '\n');
            body = body.replace('\r', '\n');
        }
        
        // parse body
        List<String> lines = body.split('\n', 0);
        while (!lines.isEmpty() && (String.isBlank(lines[0]) || String.isBlank(lines[lines.size() - 1]))) {
            if (String.isBlank(lines[0])) {
                lines.remove(0);
            }
            if (String.isBlank(lines[lines.size() - 1])) {
                lines.remove(lines.size() - 1);
            }
        }
        List<String> parsedBody = new List<String>();
        String tempLine;
        List<String> fieldsOnLine;
        for (String currentLine : lines) {
            if (currentLine.endsWith(',')) {
                currentLine += ' ';
            }
            while (currentLine.contains('\"')) {
                tempLine = currentLine.subString(0, currentLine.indexOf('\"'));
                if (tempLine.length() > 1) {
                    fieldsOnLine = tempLine.split(',', 0);
                    parsedBody.addAll(fieldsOnLine);
                }
                tempLine = currentLine.subString(currentLine.indexOf('\"') + 1, currentLine.length());
                parsedBody.add(tempLine.subString(0, tempLine.indexOf('\"')));
                currentLine = tempLine.indexOf('\"') + 2 < tempLine.length() && tempLine.indexOf('\"') < tempLine.length() ? 
                    tempLine.subString(tempLine.indexOf('\"') + 2, tempLine.length()) : '';
            }
            if (currentLine.length() > 1) {
                fieldsOnLine = currentLine.split(',', 0);
                parsedBody.addAll(fieldsOnLine);
            }
        }
        return parsedBody;
    }
    
    private static String processAdFile(List<String> attachment, Id companyId, List<Ad_Source__c> ads, Integer numFields) { 
        List<Ad_Source__c> importedAds = new List<Ad_Source__c>();
        Set<String> existingAds = new Set<String>();
        for (Ad_Source__c ad : ads) {
            existingAds.add(ad.method__c + ' ' + ad.name + ' ' + ad.Area_Code__c + ' ' + ad.Rep_Email__c);
        } 
        for (Integer i = numFields; i < attachment.size(); i += numFields) {
            if (!existingAds.contains(attachment[i] + ' ' + attachment[i + 1] + ' ' + attachment[i + 2] + ' ' + attachment[i + 8])) {
                importedAds.add(new Ad_Source__c(Service_Agreement__c = companyId, method__c = attachment[i], name = attachment[i + 1], 
                   area_code__c = attachment[i + 2], Currently_Posted_Number__c = attachment[i + 3], CallRevu_Tracking_Number__c = attachment[i + 4],
                   Rings_to__c = attachment[i + 5], Posted_Number_Provided_By__c = attachment[i + 6], Rep_Name__c = attachment[i + 7], 
                   Rep_Email__c = attachment[i + 8], Comments__c = attachment[i + 9]));
            }
        }
        try {
            insert importedAds;
        } catch (Exception e) {
            return e.getMessage();
        } 
        return null;
    } 
    
    private static String processFile(List<String> attachment, Id companyId, List<Active_Employees__c> employees, Integer numFields) { 
        List<Active_Employees__c> importedEmployees = new List<Active_Employees__c>();
        Set<String> existingEmployees = new Set<String>();
        for (Active_Employees__c employee : employees) {
            existingEmployees.add(employee.first_name__c + ' ' + employee.last_name__c + ' ' + employee.email__c);
        }
        for (Integer i = numFields; i < attachment.size(); i += numFields) {
            if (!existingEmployees.contains(attachment[i] + ' ' + attachment[i + 1] + ' ' + attachment[i + 4])) {
                importedEmployees.add(new Active_Employees__c(Service_Agreement__c = companyId, first_name__c = attachment[i], 
                    last_name__c = attachment[i + 1], title__c = attachment[i + 2], email__c = attachment[i + 3],
                    cell_phone__c = attachment[i + 4], Telephone_PIN__c = attachment[i + 5], status__c = attachment[i + 6]));
            }
        }
        try {
            insert importedEmployees;
        } catch (Exception e) {
            return e.getMessage();
        }
        return null;
    } 
}