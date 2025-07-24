/*
 * Developer: Jim Hyland <jon@shippconsulting.com>
 *  
 * Description: Controller for page for LandingPage page.
 *
 * Test code in ContractUpdateTest class.
 */
public class LandingPageController {

    /* Variables */
    
    public Contact authorizationContact { get; set; }
    public String authorizationContactLastName { get; set; }
    private CallRevu360_Portal_and_Interface__c callRevuCustomSetting;
    public Service_Agreement__c company { get; private set; }
    public Boolean displayDesignate { get; private set; }
    public List<String> errorMsg { get; private set; }
    public String helpPhone { get; private set; }
    public String nextLabel { get; private set; }
    public Contact secondaryContact { get; set; }
    
    /* Constructor */
    
    public LandingPageController() {
        displayDesignate = false;
        callRevuCustomSetting = new CallRevu360_Portal_and_Interface__c();
        for (CallRevu360_Portal_and_Interface__c cs : [select Call_Revu_Support_Phone__c from CallRevu360_Portal_and_Interface__c limit 1]) {
            callRevuCustomSetting = cs;
        }
        if (ApexPages.currentPage().getParameters().containsKey(ContractUpdateController.CONTRACT_ID_PARAM)) {
            buildCompany(ApexPages.currentPage().getParameters().get(ContractUpdateController.CONTRACT_ID_PARAM));
        } else {
            errorMsg = new List<String>();
            errorMsg.add('Missing contract id in url.  Please contact your administrator.');
            return;
        }
        if (!ApexPages.currentPage().getParameters().containsKey(ContractUpdateController.CONTRACT_ID_PARAM) 
                || !ApexPages.currentPage().getParameters().containsKey(ContractUpdateController.CONTACT_ID_PARAM)) {
            errorMsg = new List<String>();
            errorMsg.add('Missing contact id in url.  Please contact your administrator.');
            return;
        }
        Map<String, String> labelMap = new Map<String, String> { 'dealership' => 'Update Roster', 'roster' => 'Update Ad Source Information',
            'adsource' => 'Update Hours of Operation', 'hours' => 'Update CRM Integration', 'crm' => 'Update Information' };
        nextLabel = company.last_saved_page__c == null || company.last_saved_page__c == 'noschedule' ?
            'Update Dealer Information' : labelMap.get(company.last_saved_page__c);
        authorizationContact = new Contact(accountId = company.Service_Location__c);
        secondaryContact = new Contact(accountId = company.Service_Location__c);
    } 
    
    /* Instance Methods */
    
    private void buildCompany(Id companyId) {
        company = [select partner_implementation__c, Service_Location__r.partner_logo_url__c, Bill_To_Account__r.partner_image_width__c, 
            Bill_To_Account__r.partner_image_height__c, last_saved_page__c, Service_Location__c, Launch_Call_Scheduled__c, Authorization_Contact__c,
            Send_Authorized_Sender_Notification__c, Secondary_Contact__c, Bill_To_Account__r.Partner_Data_Collection_Support_Phone__c 
            from Service_Agreement__c where Id = :companyId];
        if (company.partner_implementation__c) {
            helpPhone = company.Bill_To_Account__r.Partner_Data_Collection_Support_Phone__c;
        } else {
            helpPhone = callRevuCustomSetting.Call_Revu_Support_Phone__c;
        }
    } 
    
    public void fillOutDesignate() {
        displayDesignate = true;
        if (company.Authorization_Contact__c == null) {
            authorizationContact = new Contact(accountId = company.Service_Location__c);
        } else {
            authorizationContact = [select firstName, lastname, email from Contact where Id = :company.Authorization_Contact__c];
            authorizationContactLastName = authorizationContact.lastName;
        }
        if (company.Secondary_Contact__c == null) {
            secondaryContact = new Contact(accountId = company.Service_Location__c);
        } else {
            secondaryContact = [select firstName, lastname, email from Contact where Id = :company.Authorization_Contact__c];
        }
        secondaryContact = new Contact(accountId = company.Service_Location__c);
    }
    
    public PageReference fillOutSelf() {
        company.Authorization_Contact__c = ApexPages.currentPage().getParameters().get(ContractUpdateController.CONTACT_ID_PARAM);
        company.last_saved_page__c = company.Launch_Call_Scheduled__c == null ? 'noschedule' : 'dealership';
        update company;
        return next();
    }
    
    public PageReference next() {
        String url = '/apex/contractupdate?' + ContractUpdateController.CONTRACT_ID_PARAM + '=' 
            + ApexPages.currentPage().getParameters().get(ContractUpdateController.CONTRACT_ID_PARAM)
            + '&' + ContractUpdateController.CONTACT_ID_PARAM + '=' 
            + ApexPages.currentPage().getParameters().get(ContractUpdateController.CONTACT_ID_PARAM);
        if (ApexPages.currentPage().getParameters().containsKey(ContractUpdateController.NO_AUTHORIZATION_PARAM) 
                && ApexPages.currentPage().getParameters().get(ContractUpdateController.NO_AUTHORIZATION_PARAM) == '1') {
            url += '&na=1';
        }
        if (ApexPages.currentPage().getParameters().containsKey(ContractUpdateController.AUTHORIZATION_CODE_PARAM)) {
            url += '&' + ContractUpdateController.AUTHORIZATION_CODE_PARAM + '='
                + ApexPages.currentPage().getParameters().get(ContractUpdateController.AUTHORIZATION_CODE_PARAM);
        }
        PageReference nextPage = new PageReference(url);
        nextpage.setRedirect(true);
        return nextPage;
    }
    
    public void sendEmail() {
        errorMsg = null;
        if (String.isBlank(authorizationContact.firstName) || String.isBlank(authorizationContactLastName)
                || String.isBlank(authorizationContact.email)) {
            errorMsg = new List<String>();
            errorMsg.add('The Authorized Contact First Name, Last Name, and Email must be completed.');
            return;
        }
        authorizationContact.lastName = authorizationContactLastName;
        String authFirstName = authorizationContact.firstName;
        String authLastName = authorizationContact.lastName;
        String authEmail = authorizationContact.email;
        String secFirstName = authorizationContact.firstName;
        String secLastName = authorizationContact.lastName;
        String secEmail = authorizationContact.email;
        String query = 'select firstName, lastName, email from Contact where (firstName = :authFirstName'
            + ' and lastName = :authLastName and email = :authEmail)';
        if (String.isNotBlank(secondaryContact.firstName) && String.isNotBlank(secondaryContact.lastName)
                && String.isNotBlank(secondaryContact.email)) {
            query += ' or (firstName = :secFirstName and lastName = :secLastName and email = :secEmail)';
        } else if (String.isNotBlank(secondaryContact.firstName) || String.isNotBlank(secondaryContact.lastName)
                || String.isNotBlank(secondaryContact.email) && (String.isBlank(secondaryContact.firstName) || String.isBlank(secondaryContact.lastName)
                || String.isBlank(secondaryContact.email))) {
            errorMsg = new List<String>();
            errorMsg.add('The Secondary Contact First Name, Last Name, and Email must be completed, or all three fields left blank.');
            return;
        }
        query += ' limit 2';
        Set<String> names = new Set<String>();
        for (Contact contact : database.query(query)) {
            names.add(contact.firstName + ' ' + contact.lastName + ' ' + contact.email);
        }
        List<Contact> newContacts = new List<Contact>();
        if (!names.contains(authorizationContact.firstName + ' ' + authorizationContact.lastName + ' ' +  authorizationContact.email)) {
            authorizationContact.Id = null;
            newContacts.add(authorizationContact);
        }
        if (String.isNotBlank(secondaryContact.firstName) && String.isNotBlank(secondaryContact.lastName)
                && String.isNotBlank(secondaryContact.email) 
                && !names.contains(secondaryContact.firstName + ' ' + secondaryContact.lastName + ' ' +  secondaryContact.email)) {
            secondaryContact.Id = null;
            newContacts.add(secondaryContact);
        }
        insert newContacts;
        company.Authorization_Contact__c = authorizationContact.Id;
        company.Secondary_Contact__c = secondaryContact.Id;
        company.Send_Authorized_Sender_Notification__c = true;
        update company;
        errorMsg = new List<String>();
        errorMsg.add('An email has been sent to the designated contact(s).  You may now close the page.');
        return;
    }
}