/*
 * Developer: Jim Hyland <jon@shippconsulting.com>
 *  
 * Description: Controller for page for AccountInformationUpdate page.
 *
 * Test code in AccountInformationTest class.
 */
public class AccountInformationUpdateController {

    /* Constants */

    public static final String ACCOUNT_ID_PARAM = 'accountid';
    public static final String CONTACT_ID_PARAM = 'contactid';
    
    /* Variables */
    
 /*   public String adButton { get; private set; }
    public List<Ad_Source__c> ads { get; set; }
    public Integer adSize { get; private set; }
    public Boolean authenticated { get; private set; }
    public List<CallTime> callTimes { get; private set; }
    public List<Choice> choices { get; private set; }
    public Account company { get; set; }
    public Boolean confirmEnd { get; private set; }
    public Contact contact { get; set; }
    public Boolean displayAd { get; private set; }
    public Boolean displayCompany { get; private set; }
    public Boolean displayEmployee { get; private set; }
    public String employeeButton { get; private set; }
    public List<Active_Employees__c> employees { get; set; }
    public Integer employeeSize { get; private set; }
    public String endButton { get; private set; }
    public List<String> errorMsg { get; private set; }
    public List<Hour> hours { get; set; }
    public Boolean initialAuthentication { get; private set; }
    private Boolean inProcess;
    public String lastName { get; set; }
    private String multiSelectField;
    public Boolean noContactYet { get; private set; }
    public String scheduleButton { get; private set; }
    public Event selectedEvent { get; set; }
    public Boolean showPopup { get; private set; }
    public Boolean showSchedule { get; private set; } */
    
    /* Constructor */
    
  /*  public AccountInformationUpdateController() {
        adButton = 'Add Ad Source';
        employeeButton = 'Add Employee';
        displayAd = false;
        displayCompany = false;
        displayEmployee = false;
        confirmEnd = false;
        endButton = 'End Session';
        authenticated = false;
        initialAuthentication = false;
        contact = new Contact();
        inProcess = false;
        noContactYet = false;
        if (ApexPages.currentPage().getParameters().containsKey(ACCOUNT_ID_PARAM)) {
            company = buildCompany(ApexPages.currentPage().getParameters().get(ACCOUNT_ID_PARAM));
        } else {
            errorMsg = new List<String>();
            errorMsg.add('Authentication failed: missing account id in url.  Please contact your administrator.');
            return;
        }
        if (!ApexPages.currentPage().getParameters().containsKey(CONTACT_ID_PARAM) && company.Authorization_Contact__c == null) {
            noContactYet = true;
            return;
        } else if (!ApexPages.currentPage().getParameters().containsKey(CONTACT_ID_PARAM) && company.Authorization_Contact__c != null) {
            errorMsg = new List<String>();
            errorMsg.add('Authentication failed: this link is only valid before an Authorization Contact has been set up.'
                + '  Please use the link that was emailed after the Authorization Contact was set up.');
            return;
        }
        if (!ApexPages.currentPage().getParameters().containsKey(ACCOUNT_ID_PARAM) 
                || !ApexPages.currentPage().getParameters().containsKey(CONTACT_ID_PARAM)) {
            errorMsg = new List<String>();
            errorMsg.add('Authentication failed: missing or invalid contact id in url.  Please contact your administrator.');
            return;
        }
        String error = authenticate(ApexPages.currentPage().getParameters().get(ACCOUNT_ID_PARAM), 
            ApexPages.currentPage().getParameters().get(CONTACT_ID_PARAM));
        if (error != null) {
            errorMsg = new List<String>();
            errorMsg.add(error);
            return;
        }
        initialAuthentication = true;
        scheduleButton = 'Schedule Implementation Call';
    } */
    
    /* Instance Methods */
    
  /*  public void cancelAd() {
        clearFlags();
        ads.remove(ads.size() - 1);
        adButton = 'Add Ad Source';
        displayAd = true;
        inProcess = false;
    }
    
    public void cancelEmployee() {
        clearFlags();
        employees.remove(employees.size() - 1);
        employeeButton = 'Add Employee';
        displayEmployee = true;
        inProcess = false;
    }
    
    public void cancelSelect() {
        showPopup = false;
    }
    
    private Boolean checkSave() {
        String updateObject = employeeButton == 'Save New Employee' ? 'New Employee' : 'New Ad Source';
        if (inProcess) {
            errorMsg = new List<String>();
            errorMsg.add('Please Save or Cancel the ' + updateObject + ' before changing the screen.');
            return true;
        }
        return false;
    }
    
    private void clearFlags() {
        errorMsg = null;
        displayAd = false;
        displayCompany = false;
        displayEmployee = false;
        confirmEnd = false;
        showSchedule = false;
    }
    
    public PageReference endSession() {
        if (!confirmEnd) {
            errorMsg = new List<String>();
            errorMsg.add('Any unsaved changes will be lost.  Confirm End Session.');
            confirmEnd = true;
            endButton = 'Confirm End Session';
            return null;
        }
        String url = 'www.callrevu.com';
        for (CallRevu360_Portal_and_Interface__c cs : [select End_of_Session_URL__c from CallRevu360_Portal_and_Interface__c limit 1]) {
            url = cs.End_of_Session_URL__c;
        }
        return new PageReference(url);
    }
    
    public void exitSchedule() {
        clearFlags(); 
    }
    
    public void exportCSV() {
        clearFlags();
        String body = 'First Name,Last Name,Title,Email,Cell Number,Tel. PIN,Preferred Login,Title Match?,Alert Details,'
            + 'Text Alerts,Email Alerts,Trans?Logn Type\n';
        for (Active_Employees__c employee : employees) {
            body += employee.first_name__c + ',' + employee.last_name__c + ',' + employee.title__c + ','
                + employee.email__c + ',' + employee.cell_phone__c + ',' + employee.Telephone_PIN__c + ',' + employee.Preferred_Login__c + ','
                + employee.Title_Match__c + ',' + employee.Alert_Details__c + ',' + employee.Text_Alerts__c + ',' + employee.Email_Alerts__c + ','
                + employee.Trans__c + ',' + employee.Login_Type__c + '\n';
        }
        Blob csv = Blob.valueOf(body);
        Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment(); 
        efa.setFileName('employees.csv'); 
        efa.setBody(csv); 
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new List<String> { company.Authorization_Contact__r.email });
        mail.setSenderDisplayName('Attached Employee CSV File');
        mail.setSubject('Attached Employee CSV File');
        mail.setPlainTextBody('Hello' + company.Authorization_Contact__r.firstName + ' ' + company.Authorization_Contact__r.lastName + '\n\n'
            + 'Please see that attched csv file of Employees.\n\nBest regards');
        mail.setFileAttachments(new Messaging.EmailFileAttachment[] {efa});
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        errorMsg = new List<String>();
        errorMsg.add('Please check your email for the csv export file.');
    }
    
    public void finalAuthentication() {
        clearFlags();
        Id companyId = ApexPages.currentPage().getParameters().get(ACCOUNT_ID_PARAM);
        if (String.isBlank(lastName) || String.isBlank(contact.firstName) || String.isBlank(contact.email)) {
            errorMsg = new List<String>();
            errorMsg.add('All fields must be completed.');
            return;
        }
        contact.lastname = lastName;
        for (Contact con : [select Id from Contact where accountId = :companyId and firstName = :contact.FirstName 
                and lastName = :contact.LastName and email = :contact.email]) {
            contact.Id = con.Id;
        }
        if (contact.Id == null) {
            errorMsg = new List<String>();
            errorMsg.add('No contact found.  Authentication failed.');
            return;
        }
        initialAuthentication = false;
        employees = buildEmployees(company.Id);
        employeeSize = employees.size();
        ads = buildAds(company.Id);
        adSize = ads.size();
        hours = buildHours(company);
        authenticated = true;
    }
    
    public void saveAd() {
        clearFlags();
        displayAd = true;
        if (AdButton == 'Add Ad Source') {
            ads.add(new Ad_Source__c(account__c = company.Id));
            adButton = 'Save New Ad Source';
            inProcess = true;
            return;
        }
        upsert ads;
        ads = buildAds(company.Id);
        adSize = ads.size();
        adButton = 'Add Ad Source';
        inProcess = false;
    }
    
    public void saveCompany() {
        clearFlags();
        update company;
    }
    
    public void saveEmployees() {
        clearFlags();
        displayEmployee = true;
        if (employeeButton == 'Add Employee') {
            employees.add(new Active_Employees__c(account__c = company.Id));
            employeeButton = 'Save New Employee';
            inProcess = true;
            return;
        }
        upsert employees;
        employees = buildEmployees(company.Id);
        employeeSize = employees.size();
        employeeButton = 'Add Employee';
        inProcess = false;
    }
    
    public void saveSelect() {
        company.put(multiSelectField, null);
        for (Choice ch : choices) {
            if (ch.selected) {
                if (company.get(multiSelectField) != null) {
                    company.put(multiSelectField, company.get(multiSelectField) + ch.choice + ';');
                } else {
                    company.put(multiSelectField, ch.choice + ';');
                }
            }
        }
        if (company.get(multiSelectField) != null) {
            company.put(multiSelectField, ((String)company.get(multiSelectField)).removeEnd(';'));
        }
        showPopup = false;
    }
    
    public void scheduleCall() {
        clearFlags();
        if (scheduleButton == 'Confirm Scheduled Call') {
            update selectedEvent;
            scheduleButton = 'Schedule Implementation Call';
            return;
        }
        showSchedule = true;
        callTimes = new List<CallTime>();
        for (Event theCallTime : [select startDateTime, endDateTime from Event where Type = 'Call' and status__c = 'Open']) {
            callTimes.add(new CallTime(theCallTime, company.Authorization_Contact__c, this));
        }
    }
    
    public void setUpAuthorizationContact() {
        if (String.isBlank(lastName) || String.isBlank(contact.firstName) || String.isBlank(contact.email) || String.isBlank(contact.mobilePhone) 
                || String.isBlank(contact.phone)) {
            errorMsg = new List<String>();
            errorMsg.add('All fields must be completed.');
            return;
        }
        contact.accountId = company.Id;
        contact.lastName = lastName;
        for (Contact con : [select Id from Contact where accountId = :company.Id and firstName = :contact.firstName and lastname = :contact.lastname
                and email = :contact.email limit 1]) {
            contact.Id = con.Id;
        }
        if (contact.Id == null) {
            insert contact;
        }
        company.Authorization_Contact__c = contact.Id;
        update company;
        company.Send_Account_Update_Link__c = true;
        update company;
        contact = new Contact();
        errorMsg = new List<String>();
        errorMsg.add('Please check your email for an Authentication link to continue.');
        noContactYet = false;
    }
    
    public void showPopupMakes() {
        multiSelectField = 'Main_Car_Makes_Sold__c';
        choices = buildPickList('Main_Car_Makes_Sold__c', company.Main_Car_Makes_Sold__c);
        showPopup = true;
    }
    
    public void updateAd() {
        if (checkSave()) {
            return;
        }
        clearFlags();
        displayAd = true;
    }
    
    public void updateAll() {
        if (checkSave()) {
            return;
        }
        clearFlags();
        displayAd = true;
        displayCompany = true;
        displayEmployee = true;
    }
    
    public void updateCompany() {
        if (checkSave()) {
            return;
        }
        clearFlags();
        displayCompany = true;
    }
    
    public void updateEmployee() {
        if (checkSave()) {
            return;
        }
        clearFlags();
        displayEmployee = true;
    } */
    
    /* Static Methods */
    
   /* private static String authenticate(Id accountId, Id contactId) {
        String error = 'The Account Id in url is not valid.  Please contact your administrator.';
        for (Account account : [select Authorization_Contact__c, Date_Last_Account_Update_Sent__c from Account where Id = :accountId]) {
            if (account.Authorization_Contact__c != contactId) {
                error = 'The Contact Id in url is not the Authorized Contact for the Account.  Please contact your administrator.';
                return error;
            } if (account.Date_Last_Account_Update_Sent__c == null || account.Date_Last_Account_Update_Sent__c.addHours(24) < system.now()) {
                error = 'The authorization email link has expired after 24 hours.  Please contact your administrator.';
                return error;
            }
            return null;
        }
        return error;
    }
    
    private static List<Ad_Source__c> buildAds(Id accountId) {
        List<Ad_Source__c> ads = new List<Ad_Source__c>();
        for (Ad_Source__c ad : [select method__c, name, area_code__c, Currently_Posted_Number__c, CallRevu_Tracking_Number__c, Rings_to__c,
                Posted_Number_Provided_By__c, Rep_Name__c, Rep_Email__c, comments__c, First_Test_Completed__c, Reroute_RespOrg_Request__c,
                Reroute_RespOrg_Completed__c from Ad_Source__c where account__c = :accountId order by name]) {
            ads.add(ad);
        }
        return ads;
    }
    
    private static Account buildCompany(Id accountId) {
        return [select name, billingstreet, dealer_group__c, mon_open__c, mon_close__c, tue_open__c, tue_close__c, wed_open__c, wed_close__c,
            thu_open__c, thu_close__c, fri_open__c, fri_close__c, sat_open__c, sat_close__c, sun_open__c, sun_close__c, billingcity, BillingState,
            billingpostalcode, billingcountry, phone, time_zone__c, website, Website_Provider__c, Website_Provider_Login__c,
            Website_Provider_Password__c, Main_Car_Makes_Sold__c, crm__c, Current_Call_Tracking_Setup_Name__c, Call_Tracking_Login__c,
            Call_Tracking_Password__c, Sold_By_Salesperson__c, Sold_By_Salesperson_Email__c, Authorization_Contact__c, Authorization_Contact__r.email,
            Secondary_Contact__c, Secondary_Contact__r.email, Authorization_Contact_PW_Reset__c, Secondary_Contact_PW_Reset__c,
            Authorization_Contact__r.firstName, Authorization_Contact__r.lastName, CRM_User_Name__c, CRM_Password__c, Inbound_Call_Address__c,
            Send_Account_Update_Link__c from Account where Id = :accountId];
    }
    
    private static List<Active_Employees__c> buildEmployees(Id accountId) {
        List<Active_Employees__c> employees = new List<Active_Employees__c>();
        for (Active_Employees__c emp : [select first_name__c, last_name__c, title__c, email__c, cell_phone__c, Telephone_PIN__c,
                Preferred_Login__c, Title_Match__c, Alert_Details__c, Text_Alerts__c, email_alerts__c, Trans__c, Login_Type__c
                from Active_Employees__c 
                where account__c = :accountId order by last_name__c]) {
            employees.add(emp);
        }
        return employees;
    }
    
    private static List<Hour> buildHours(account account) {
        List<Hour> hours = new List<Hour>();
        hours.add(new Hour('Open', account));
        hours.add(new Hour('Close', account));
        return hours;
    }
    
    private static List<Choice> buildPickList(String field, String companyField) {
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();  
        Schema.SObjectType systemObjectType = gd.get('Account');  
        Schema.DescribeSObjectResult r = systemObjectType.getDescribe();  
        Schema.SObjectField fieldResult = r.fields.getMap().get(field); 
        Schema.DescribeFieldResult fieldDescribe = fieldResult.getDescribe();
        List<Schema.PicklistEntry> ple = fieldDescribe.getPicklistValues();
        List<Choice> choices = new List<Choice>();
        Set<String> currentChoices = new Set<String>();
        List<String> currentChoiceList;
        if (companyField != null) {
            currentChoiceList = companyField.split(';');
            currentChoices.addAll(currentChoiceList);
        }
        for (Schema.PicklistEntry f : ple) {
            if (currentChoices.contains(f.getLabel())) {
                choices.add(new Choice(f.getLabel(), true));
            } else {
                choices.add(new Choice(f.getLabel(), false));
            }
        }
        return choices;
    } 
    
    private static String findDayOfWeek(DateTime theDate) {
        Datetime dt = DateTime.newInstance(theDate.date(), Time.newInstance(0, 0, 0, 0));
        return dt.format('EEEE');
    return null;
    } */
    
    /* Inner Classes */
   
  /*  public class Choice {
       
        public String choice { get; set; }
        public Boolean selected { get; set; }
       
        public Choice(String chc, Boolean sel) {
            choice = chc;
            selected = sel;
        }
    }
    
    public class CallTime {
        
        private Id authorizedContactId;
        private AccountInformationUpdateController con;
        public String dayOfWeek { get; private set; }
        public Event event { get; private set; }
        
        public callTime(Event theEvent, Id contactId, AccountInformationUpdateController cn) {
            event = theEvent;
            dayOfWeek = findDayOfWeek(event.startDateTime);
            authorizedContactId = contactId;
            con = cn;
        }
        
        public void updateEvent() {
            con.clearFlags();
            con.showSchedule = true;
            event.whoId = authorizedContactId;
            con.selectedEvent = event;
            con.errorMsg = new List<String>();
            con.errorMsg.add('You have selected ' + dayOfWeek + ', ' + event.startDateTime.format() + '.\n'
                + 'If you want to change the selected time, choose a different time; otherwise, Confirm Scheduled Call');
            con.scheduleButton = 'Confirm Scheduled Call';
        }
    }
    
    public class Hour {
        
        public String openClose { get; private set; }
        public Account theAccount { get; set; }
        
        public Hour(String label, Account account) {
            openClose = label;
            theAccount = account;
        }
    } */
}