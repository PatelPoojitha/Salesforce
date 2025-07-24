/*
 * Developer: Jim Hyland <jon@shippconsulting.com>
 *  
 * Description: Controller for page for ContractUpdate page.
 *
 * Test code in ContractUpdateTest class.
 */
public class ContractUpdateController {

    /* Constants */

    public static final String AUTHORIZATION_CODE_PARAM = 'authcode';
    public static final String CONTACT_ID_PARAM = 'contactid';
    public static final String CONTRACT_ID_PARAM = 'contractid';
    public static final String FROM_SITES_PARAM = 'fromsites';
    public static final String LAST_AD_HEADING = 'comments';
    public static final String LAST_HEADING = 'status';
    public static final String LOAD_AD_SOURCES = 'loadads';
    public static final String NO_AUTHORIZATION_PARAM = 'na';
    public static final Integer NUM_OF_FIELDS = 7;
    public static final Integer NUM_OF_AD_FIELDS = 10;
    
    /* Variables */
    
    public Account account { get; set; }
    public String accountName { get; set; }
    public String adButton { get; private set; }
    public String addressLine { get; private set; }
    public List<Ad> ads { get; set; }
    public Integer adSize { get; private set; }
    public Boolean authenticated { get; private set; }
    public Contact authorizationContact { get; set; }
    public String authorizationContactLastName { get; set; }
    public Contact billingContact { get; set; }
    public CallRevu360_Portal_and_Interface__c callRevuCustomSetting { get; private set; }
    public List<Choice> choices { get; private set; }
    public List<SelectOption> closeHours { get; private set; }
    public Service_Agreement__c company { get; set; }
    private String companyId;
    private Boolean confirmLogout;
    public Boolean confirmSync { get; private set; }
    public Contact contact { get; set; }
    public List<SelectOption> days { get; private set; }
    private Boolean disableNextPrev;
    public Boolean displayAd { get; private set; }
    public Boolean displayClose { get; private set; }
    public Boolean displayCompany { get; private set; }
    public Boolean displayCRM { get; private set; }
    public Boolean displayEmployee { get; private set; }
    public Boolean displayHours { get; private set; }
    @TestVisible
    public String employeeButton { get; private set; }
    private List<Employee> employees;
    @TestVisible
    public Integer employeeSize { get; private set; }
    @TestVisible
    public List<String> errorMsg { get; private set; }
    public List<Employee> filteredEmployees { get; set; }
    public String filterStatus { get; set; }
    @TestVisible
    private Boolean fromCheckSave;
    private Boolean fromCRMSave;
    private Boolean fromEmployeeSave;
    public Boolean fromSites { get; private set; }
    public String helpPhone { get; private set; }
    public List<Hour> hours { get; set; }
    public Boolean initialAuthentication { get; private set; }
    public String lastName { get; set; }
    public Map<String, String> leadAddressMap { get; private set; }
    private String multiSelectField;
    public String nextLabel { get; private set; }
    public Boolean noContactYet { get; private set; }
    public List<String> openCloseList { get; private set; }
    public List<SelectOption> openHours { get; private set; }
    private String phoneErrorType;
    public String prevLabel { get; private set; }
    public Map<String, Map<String, String>> repMap { get; private set; }
    public Contact secondaryContact { get; set; }
    public String selectedId { get; set; }
    public String selectedDay { get; set; }
    public String selectedTime { get; set; }
    private Boolean sentEmailMsg;
    public Boolean showSchedule { get; private set; }
    public Boolean specialCurrent { get; private set; }
    public String syncButton { get; private set; }
    public List<SelectOption> times { get; private set; }
    private Map<String, Launch_Appointment_Times__mdt> timesMap;
    private Boolean useSecondaryContact; 
    
    /* Constructor */
    
    public ContractUpdateController() {
        openCloseList = new List<String> { 'Open', 'Close', 'Closed' };
        leadAddressMap = new Map<String, String> { 'eLead1' => 'https://www.eleadcrm.net/adflead/genericcalllead.asmx',
            'DealerSocket' => 'https://websecure.dealersocket.com/ds_webleadservice/process.asmx/ProcessWebLead',
            'CarResearch' => 'https://callrevu.car-research.com/callrevu/callrevu.aspx' };
        adButton = 'Add Tracking Number';
        employeeButton = 'Add Employee'; 
        sentEmailMsg = false;
        displayAd = false;
        disableNextPrev = false;
        displayCompany = false;
        displayEmployee = false;
        displayHours = false;
        displayCRM = false;
        displayClose = false;
        confirmSync = false;
        confirmLogout = false;
        fromCheckSave = false;
        fromEmployeeSave = false;
        useSecondaryContact = false;
        syncButton = 'Sync to CallRevu 360';
        contact = new Contact();
        noContactYet = false;
        fromSites = UserInfo.getname().toLowerCase().contains('site');
        filterStatus = 'Active';
        callRevuCustomSetting = new CallRevu360_Portal_and_Interface__c();
        for (CallRevu360_Portal_and_Interface__c cs : [select URL_for_PDF__c, open_times_options__c, close_times_options__c, 
                Implementation_Calendar_Id__c, Default_Return_URL__c, Dealership_Description__c, Roster_Description__c, Ad_Source_Description__c,
                Hours_Description__c, CRM_description__c, Call_Revu_Support_Phone__c from CallRevu360_Portal_and_Interface__c limit 1]) {
            callRevuCustomSetting = cs;
        }
        if (ApexPages.currentPage().getParameters().containsKey(CONTRACT_ID_PARAM)) {
            buildCompany(ApexPages.currentPage().getParameters().get(CONTRACT_ID_PARAM), false);
            companyId = company.Id;
            company.Id = null;
        } else {
            errorMsg = new List<String>();
            errorMsg.add('Authentication failed: missing contract id in url.  Please contact your administrator.');
            return;
        }
        authenticated = (ApexPages.currentPage().getParameters().containsKey(NO_AUTHORIZATION_PARAM) 
            && ApexPages.currentPage().getParameters().get(NO_AUTHORIZATION_PARAM) == '1') || company.Returning_From_Import_Employees__c;
        if ((!ApexPages.currentPage().getParameters().containsKey(CONTACT_ID_PARAM) 
                || ApexPages.currentPage().getParameters().get(CONTACT_ID_PARAM) == null)
                && company.Authorization_Contact__c == null) {
            noContactYet = true;
            return;
        } else if (!ApexPages.currentPage().getParameters().containsKey(CONTACT_ID_PARAM) && company.Authorization_Contact__c != null) {
            errorMsg = new List<String>();
            errorMsg.add('Authentication failed: this link is only valid before an Authorization Contact has been set up.'
                + '  Please use the link that was emailed after the Authorization Contact was set up.');
            return;
        }
        if (!ApexPages.currentPage().getParameters().containsKey(CONTRACT_ID_PARAM) 
                || !ApexPages.currentPage().getParameters().containsKey(CONTACT_ID_PARAM)) {
            errorMsg = new List<String>();
            errorMsg.add('Authentication failed: missing or invalid contact id in url.  Please contact your administrator.');
            return;
        }
        buildOpenCloseTimes();
        employees = buildEmployees(companyId);
        employeeSize = buildEmployeeCount(employees);
        filterEmployees();
        ads = buildAds(companyId);
        adSize = ads.size();
        repMap = buildRepMap();
        if (!ApexPages.currentPage().getParameters().containsKey(NO_AUTHORIZATION_PARAM)
                && !company.Returning_From_Import_Employees__c) {
            String error = authenticate(company, ApexPages.currentPage().getParameters().get(AUTHORIZATION_CODE_PARAM));
            initialAuthentication = false;
            if (error != null) {
                errorMsg = new List<String>();
                errorMsg.add(error);
                initialAuthentication = true;
                authenticated = false;
                return;
            } else {
                authenticated = true;
                return;
            }
        }
        initialAuthentication = !ApexPages.currentPage().getParameters().containsKey(NO_AUTHORIZATION_PARAM)
            && !company.Returning_From_Import_Employees__c;
        company.Returning_From_Import_Employees__c = false;
    }
    
    /* Instance Methods */
    
    private void buildCompany(Id contractId, Boolean fromSave) {
        company = [select name, Service_Location__r.billingstreet, Service_Location__r.dealer_group__c, mon_open__c, mon_close__c, tue_open__c,
            tue_close__c, wed_open__c, wed_close__c, thu_open__c, thu_close__c, fri_open__c, fri_close__c, sat_open__c, sat_close__c, sun_open__c, 
            sun_close__c, mon_closed__c, tue_closed__c, wed_closed__c, thu_closed__c, fri_closed__c, sat_closed__c, sun_closed__c, 
            Service_Location__c, Service_Location__r.name, Service_Location__r.billingcity, Service_Location__r.BillingState, 
            Service_Location__r.billingpostalcode, Service_Location__r.billingcountry, Service_Location__r.phone, time_zone__c, 
            Service_Location__r.website, Website_Provider__c, Website_Provider_Login__c, Website_Provider_Password__c, 
            Service_Location__r.Main_Car_Makes_Sold__c, crm__c, Current_Call_Tracking_Setup_Name__c, 
            Call_Tracking_Login__c, Date_Last_Account_Update_Sent__c, Authorization_Contact__c, Call_Tracking_Password__c, 
            Authorization_Contact__r.email, Authorization_Contact__r.phone, Secondary_Contact__c, Secondary_Contact__r.email, 
            Secondary_Contact__r.phone, Secondary_Contact__r.firstname, Secondary_Contact__r.lastname, Outbound_C2C_Included__c, 
            Authorization_Contact__r.firstName, Authorization_Contact__r.lastName, CRM_User_Name__c, CRM_Password__c, Send_Account_Update_Link__c, 
            Service_Location__r.Sold_By_Salesperson__c, Service_Location__r.Sold_By_Salesperson_Email__c, date_agreement_signed__c, 
            Enrollment_Call_Scheduled__c, Launch_Call_Scheduled__c, Sync_To_CallRevu_360__c, Display_Sync_to_CallRevu_360_Option__c, 
            partner_implementation__c, Service_Location__r.partner_logo_url__c, has_a_current_call_tracking_vendor__c, current__c, 
            Call_Tracking_Vendor_Login__c, Call_Tracking_Vendor_Password__c, Intends_to_Transfer_Existing_Vendor__c, Preferred_Contact_For_Billing__c,
            Preferred_Contact_For_Billing__r.firstName, Preferred_Contact_For_Billing__r.lastName, Preferred_Contact_For_Billing__r.phone,
            Preferred_Contact_For_Billing__r.email, eLead__c, Dealer_Socket__c, Subaru_NE_LIS__c, Car_Research__c, Dealer_Code__c,
            Contract_Type__c, Display_Ad_Source__c, Bill_To_Account__r.Partner_Logo_URL__c, Bill_To_Account__c, status__c, 
            Bill_To_Account__r.Partner_Data_Collection_Support_Phone__c, Bill_To_Account__r.partner_image_width__c, authorization_code__c,
            Bill_To_Account__r.partner_image_height__c, kick_off_event_Id__c, bill_to_account__r.Contract_Return_URL__c, lead_address__c, 
            Returning_From_Import_Employees__c, display_hours_of_operation__c, display_CRM_Information__c, display_roster__c, Last_Saved_Page__c,
            Minimum_Roster_Count_For_Complete__c, Minimum_Ad_Source_Count_For_Complete__c, Allow_Ad_Source_Edits__c, Allow_Roster_Edits__c,
            enrollment_phone_number__c from Service_Agreement__c where Id = :contractId];
        company.display_roster__c = company.display_roster__c == null ? false : company.display_roster__c;
        company.display_ad_source__c = company.display_ad_source__c == null ? false : company.display_ad_source__c;
        company.display_hours_of_operation__c = company.display_hours_of_operation__c == null ? false : company.display_hours_of_operation__c;
        company.display_crm_information__c = company.display_crm_information__c == null ? false : company.display_crm_information__c;
        addressLine = company.Service_Location__r.billingstreet;
        company.eLead__c = company.eLead__c == null ? 'https://www.eleadcrm.net/adflead/genericcalllead.asmx' : company.eLead__c;
        company.Dealer_Socket__c = company.Dealer_Socket__c == null ? 'https://websecure.dealersocket.com/ds_webleadservice/process.asmx/ProcessWebLead' : 
            company.Dealer_Socket__c;
        company.Subaru_NE_LIS__c = company.Subaru_NE_LIS__c == null ? 'https://www.leadinformation.com/WebPostLeads/CallRevuLead.aspx' : 
            company.Subaru_NE_LIS__c;
        company.Car_Research__c = company.Car_Research__c == null ? 'https://www.eleadcrm.net/adflead/genericcalllead.asmx' : company.Car_Research__c;
        account = new Account(name = company.Service_Location__r.name, billingstreet = company.Service_Location__r.billingstreet, 
            dealer_group__c = company.Service_Location__r.dealer_group__c, billingcity = company.Service_Location__r.billingcity, 
            BillingState = company.Service_Location__r.BillingState, billingpostalcode = company.Service_Location__r.billingpostalcode, 
            billingcountry = company.Service_Location__r.billingcountry, phone = company.Service_Location__r.phone, 
            website = company.Service_Location__r.website, Main_Car_Makes_Sold__c = company.Service_Location__r.Main_Car_Makes_Sold__c, 
            Sold_By_Salesperson__c = company.Service_Location__r.Sold_By_Salesperson__c, 
            Sold_By_Salesperson_Email__c = company.Service_Location__r.Sold_By_Salesperson_Email__c);
        accountName = company.Service_Location__r.name;
        if (company.Secondary_Contact__c != null) {
            secondaryContact = new Contact(email = company.Secondary_Contact__r.email, phone = company.Secondary_Contact__r.phone, 
                firstName = company.Secondary_Contact__r.firstName, lastName = company.Secondary_Contact__r.lastName);
        } else {
            secondaryContact = new Contact(accountId = company.Service_Location__c);
        }
        if (company.Authorization_Contact__c != null) {
            authorizationContact = new Contact(email = company.Authorization_Contact__r.email, phone = company.Authorization_Contact__r.phone, 
                firstName = company.Authorization_Contact__r.firstName, lastName = company.Authorization_Contact__r.lastName);
            authorizationContactLastName = company.Authorization_Contact__r.lastName;
        } else {
            authorizationContact = new Contact(accountId = company.Service_Location__c);
        }
        if (company.Preferred_Contact_For_Billing__c != null) {
            billingContact = new Contact(email = company.Preferred_Contact_For_Billing__r.email, 
                phone = company.Preferred_Contact_For_Billing__r.phone, firstName = company.Preferred_Contact_For_Billing__r.firstName,
                lastName = company.Preferred_Contact_For_Billing__r.lastName);
        } else if (!fromSave)  {
            billingContact = new Contact(accountId = company.Service_Location__c);
        }
        hours = buildHours(company);
        checkSpecial();
        if (company.partner_implementation__c) {
            helpPhone = company.Bill_To_Account__r.Partner_Data_Collection_Support_Phone__c;
        } else {
            helpPhone = callRevuCustomSetting.Call_Revu_Support_Phone__c;
        }
    } 
    
    public void buildOpenCloseTimes() {
        openHours = new List<SelectOption> { new SelectOption('--None--', '--None--') };
        closeHours = new List<SelectOption> { new SelectOption('--None--', '--None--') };
        List<String> openOptions = new List<String>();
        List<String> closeOptions = new List<String>();
        if (callRevuCustomSetting.open_times_options__c != null) {
            openOptions = callRevuCustomSetting.open_times_options__c.split(',');
        }
        if (callRevuCustomSetting.close_times_options__c != null) {
            closeOptions = callRevuCustomSetting.close_times_options__c.split(',');
        }
        for (String hour : openOptions) {
            openHours.add(new SelectOption(hour.trim(), hour.trim()));
        }
        for (String hour : closeOptions) {
            closeHours.add(new SelectOption(hour.trim(), hour.trim()));
        }
    }
    
    public void cancelAd() {
        clearFlags();
        ads.remove(ads.size() - 1);
        adButton = 'Add Tracking Number';
        displayAd = true;
    }
    
    public void cancelEmployee() {
        clearFlags();
        filteredEmployees.remove(filteredEmployees.size() - 1);
        employeeButton = 'Add Employee';
        displayEmployee = true;
    }
    
    public PageReference cancelImport() {
        PageReference nextPage = new PageReference('/apex/contractupdate?' + CONTRACT_ID_PARAM + '=' + companyId
            + '&' + CONTACT_ID_PARAM + '=' + ApexPages.currentPage().getParameters().get(CONTACT_ID_PARAM));
        nextpage.setRedirect(true);
        return nextPage;
    } 
    
    private Boolean checkSave() {
        if (disableNextPrev != null && disableNextPrev) {
            errorMsg = new List<String>();
            if (phoneErrorType == 'phone') {
                errorMsg.add('All phone numbers must be 10-digits.');
            } else {
                errorMsg.add('Area code must be 10-digits.');
            }
            return false;
        }
        if (errorMsg != null && !sentEmailMsg) {
            return false;
        }
        sentEmailMsg = false;
        Boolean saveCompanyFlag = displayCompany;
        Boolean saveEmployeeFlag = displayEmployee;
        Boolean saveAdFlag = displayAd;
        Boolean saveHourFlag = displayHours;
        Boolean saveCRMFlag = displayCRM;
        fromCheckSave = false;
        if (displayEmployee) {
            fromCheckSave = true;
            saveEmployees(); 
            displayEmployee = true;
            return errorMsg == null;
        } else if (displayAd) {
            fromCheckSave = true;
            saveAd();
            displayAd = true;
        } else if (displayHours) {
            fromCheckSave = true;
            saveHours();
            displayHours = true;
        } 
        else if (displayCRM) {
            fromCheckSave = true;
            saveCRM();
            displayCRM = true;
        } else {
            saveCompany();
            displayCompany = true;
            return errorMsg == null;
        }
        displayCompany = saveCompanyFlag;
        displayEmployee = saveEmployeeFlag;
        displayAd = saveAdFlag;
        displayHours = saveHourFlag;
        displayCRM = saveCRMFlag;
        return true;
    }
    
    public void checkSpecial() {
        specialCurrent = company.current__c != null 
            && (company.current__c == 'CallBright' || (company.current__c.contains('Who') && company.current__c.contains('Calling')));
    }
    
    private void clearFlags() {
        errorMsg = null;
        displayAd = false;
        displayCompany = false;
        displayEmployee = false;
        displayHours = false;
        displayCRM = false;
        showSchedule = false;
        confirmSync = false;
    }
    
    public PageReference closePage() {
        return new PageReference(fromSites && company.partner_implementation__c 
            && company.bill_to_account__r.Contract_Return_URL__c != null ? company.bill_to_account__r.Contract_Return_URL__c :
            fromSites ? callRevuCustomSetting.Default_Return_URL__c : '/' + companyId);
    }
    
    public void confirmAppointment() {
        showSchedule = false;
        List<String> splitDate1 = selectedDay.split(' ');
        List<String> splitDate2 = splitDate1[0].split('-');
        Time st;
        Time et;
        if (!Test.isRunningTest()) {
            st = convertStringToTime(timesMap.get(selectedTime).start_time__c);
            et = convertStringToTime(timesMap.get(selectedTime).end_time__c);
        } else {
            st = system.now().time();
            et = system.now().addHours(25).time();
        }
        DateTime startTime = DateTime.newInstance(Integer.valueOf(splitDate2[0].trim()), Integer.valueOf(splitDate2[1].trim()), 
            Integer.valueOf(splitDate2[2].trim()), st.hour(), st.minute(), 0);
        DateTime endTime = DateTime.newInstance(Integer.valueOf(splitDate2[0].trim()), Integer.valueOf(splitDate2[1].trim()), 
            Integer.valueOf(splitDate2[2].trim()), et.hour(), et.minute(), 0);
        
        Boolean foundEvent = false;
        for (Event event : [select Id from Event where Id = :company.kick_off_event_Id__c limit 1]) {
            foundEvent = true;
        }
        if (!foundEvent) {
            company.kick_off_event_Id__c = null;
            company.Launch_Call_Scheduled__c = null;
        }
        if (company.kick_off_event_Id__c != null) {
            delete new Event(Id = company.kick_off_event_Id__c);
        }
        String subject = company.Service_Location__r.name + ' Implementation Kickoff ' + company.enrollment_phone_number__c;
        subject = subject.length() > 80 ? subject.subString(0, 80) : subject;
        Event theCall = new Event(whoId = company.Authorization_Contact__c, whatId = companyId, 
            subject = subject, status__c = 'Scheduled', startDateTime = startTime, endDateTime = endTime);
        insert theCall;
        company.kick_off_event_Id__c = theCall.Id;
        List<EventRelation> relations = new List<EventRelation>();
        Set<Id> foundIds = new Set<Id>();
        String userId;
        for (Implementation_User__mdt usr : [select Salesforce_User_Id__c from Implementation_User__mdt]) {
            userId = UserInfo.getUserId();
            if (userId.subString(0, 15) != usr.Salesforce_User_Id__c) {
                relations.add(new EventRelation(relationId = usr.Salesforce_User_Id__c, eventId = theCall.Id));
            }
            foundIds.add(usr.Salesforce_User_Id__c);
        }
        if (company.secondary_contact__c != null && !foundIds.contains(company.secondary_contact__c)) {
            relations.add(new EventRelation(relationId = company.secondary_contact__c, eventId = theCall.Id));
        }
        if (!Test.isRunningTest()) {
            insert relations;
        }
        company.Enrollment_Call_Scheduled__c = startTime;
        company.Enrollment_Call_Scheduled_Time__c = timesMap.get(selectedTime) != null ? timesMap.get(selectedTime).label : '';
        company.Id = companyId;
        upsert company;
        company.Id = null;
        if (company.last_saved_page__c == 'noschedule') {
            displayCompany = true;
            nextLabel = 'Update Roster';
        }
    }
    
    public void defaultRep() {
        for (Ad ad : ads) {
            if ((String.isBlank(selectedId) && ad.Id == null) || (String.isNotBlank(selectedId) && ad.Id == selectedId)) {
                if (repMap.containsKey(ad.ad.Posted_Number_Provided_By__c)) {
                    ad.ad.rep_name__c = repMap.get(ad.ad.Posted_Number_Provided_By__c).get('name');
                    ad.ad.rep_email__c = repMap.get(ad.ad.Posted_Number_Provided_By__c).get('email');
                } else {
                    ad.ad.rep_name__c = null;
                    ad.ad.rep_email__c = null;
                }
                break;
            }
        }
    }
    
    public void deleteAd() {
        clearFlags();
        displayAd = true;
        Ad_Source__c adToDelete;
        for (Ad ad : ads) {
            if (ad.Id != null && ad.Id == selectedId) {
                ad.ad.Id = ad.Id;
                adToDelete = ad.ad;
                break;
            }
        }
        if (adToDelete != null) {
            delete adToDelete;
        }
        ads = buildAds(companyId);
        adSize = ads.size();
    }
    
    public void deleteEmployee() {
        clearFlags();
        displayEmployee = true;
        Active_Employees__c employeeToDelete;
        for (Employee employee : filteredEmployees) {
            if (employee.Id == selectedId) {
                employee.employee.Id = employee.Id;
                employeeToDelete = employee.employee;
                break;
            }
        }
        if (employeeToDelete != null) {
            delete employeeToDelete;
        }
        employees = buildEmployees(companyId);
        employeeSize = buildEmployeeCount(employees);
        filterEmployees();
    }
    
    public PageReference displayPDF() {
        if (!checkSave()) {
            return null;
        }
        if (callRevuCustomSetting.URL_for_PDF__c != null) {
           return new PageReference(callRevuCustomSetting.URL_for_PDF__c);
        }
        errorMsg = new List<String>();
        errorMsg.add('Custom Setting has not been set up with url for the pdf.  See your system administrator.');
        return null;
    }
    
    public PageReference endSession() {
        if (!confirmLogout && !checkSave()) {
            confirmLogout = true;
            errorMsg.add('If you want to logout without saving the Dealership Information, hit Logout again');
            return null;
        }
        return closePage();
    }
    
    public void exportAdCSV() {
        if (!checkSave()) {
            return;
        }
        clearFlags();
        String temp;
        String body = 'Method,Ad Source Name,Area Code,Currently Posted Number,CallRevu Tracking Number,Rings-to,Posted Number Provided By,Rep Name,'
            + 'Rep Email,Comments\n';
        for (Ad ad : ads) {
            body += (ad.ad.Method__c != null && ad.ad.Method__c.contains(',') ? '\"' + ad.ad.Method__c + '\"' :  
                    ad.ad.Method__c == null ? '' : ad.ad.Method__c) + ',' +
                (ad.ad.name != null && ad.ad.name.contains(',') ? '\"' + ad.ad.name+ '\"' :  
                    ad.ad.name == null ? '' : ad.ad.name) + ',' +
                (ad.ad.Area_Code__c != null && ad.ad.Area_Code__c.contains(',') ? '\"' + ad.ad.Area_Code__c + '\"' : 
                    ad.ad.Area_Code__c == null ? '' : ad.ad.Area_Code__c) + ',' +
                (ad.ad.Currently_Posted_Number__c != null && ad.ad.Currently_Posted_Number__c.contains(',') ? '\"' 
                    + ad.ad.Currently_Posted_Number__c + '\"' : 
                    ad.ad.Currently_Posted_Number__c == null ? '' : ad.ad.Currently_Posted_Number__c) + ',' +
                (ad.ad.CallRevu_Tracking_Number__c != null && ad.ad.CallRevu_Tracking_Number__c.contains(',') ? '\"' 
                    + ad.ad.CallRevu_Tracking_Number__c + '\"' : 
                    ad.ad.CallRevu_Tracking_Number__c == null ? '' : ad.ad.CallRevu_Tracking_Number__c) + ',' +
                (ad.ad.Rings_to__c != null && ad.ad.Rings_to__c.contains(',') ? '\"' + ad.ad.Rings_to__c + '\"' :
                    ad.ad.Rings_to__c == null ? '' : ad.ad.Rings_to__c) + ',' +
                (ad.ad.Posted_Number_Provided_By__c != null && ad.ad.Posted_Number_Provided_By__c.contains(',') ? '\"' 
                    + ad.ad.Posted_Number_Provided_By__c + '\"' :  
                    ad.ad.Posted_Number_Provided_By__c == null ? '' : ad.ad.Posted_Number_Provided_By__c) + ',' +
                (ad.ad.Rep_Name__c != null && ad.ad.Rep_Name__c.contains(',') ? '\"' + ad.ad.Rep_Name__c + '\"' : 
                    ad.ad.Rep_Name__c == null ? '' : ad.ad.Rep_Name__c) + ',' +
                (ad.ad.Rep_Email__c != null && ad.ad.Rep_Email__c.contains(',') ? '\"' + ad.ad.Rep_Email__c + '\"' :
                    ad.ad.Rep_Email__c == null ? '' : ad.ad.Rep_Email__c) + ',';
                temp = ad.ad.Comments__c != null && ad.ad.Comments__c.contains(',') ? '#%#' + ad.ad.Comments__c + '#%#' :  
                    ad.ad.Comments__c == null ? '' : ad.ad.Comments__c; 
                body += temp.replaceAll('\"', '').replaceAll('#%#', '\"') + '\n';
        }
        Blob csv = Blob.valueOf(body);
        Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment(); 
        efa.setFileName('AdSource.csv'); 
        efa.setBody(csv); 
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        Contact emailContact = new Contact(
            firstName = useSecondaryContact ? company.Secondary_Contact__r.firstName : company.Authorization_Contact__r.firstName,
            lastName = useSecondaryContact ? company.Secondary_Contact__r.lastName : company.Authorization_Contact__r.lastName,
            email = useSecondaryContact ? company.Secondary_Contact__r.email : company.Authorization_Contact__r.email);
        mail.setToAddresses(new List<String> { emailContact.email });
        mail.setSenderDisplayName('Attached Ad Source CSV File');
        mail.setSubject('Attached Ad Source CSV File');
        mail.setPlainTextBody('Hello ' + emailContact.firstName + ' ' + emailContact.lastName + ',\n\n'
            + 'Please see that attached Ad Source csv file.\n\nBest regards');
        mail.setFileAttachments(new Messaging.EmailFileAttachment[] {efa});
        if (!Test.isRunningTest()) {
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
        errorMsg = new List<String>();
        errorMsg.add('Please check your email for the Ad Source csv file.');
        sentEmailMsg = true;
    }
    
    public void exportAdTemplate() {
        if (!checkSave()) {
            return;
        }
        clearFlags();
        String body = 'Method,Ad Source Name,Area Code,Currently Posted Number,CallRevu Tracking Number,Rings-to,Posted Number Provided By,Rep Name,'
            + 'Rep Email,Comments';
        Blob csv = Blob.valueOf(body);
        Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment(); 
        efa.setFileName('AdSourceTemplate.csv'); 
        efa.setBody(csv); 
        Contact emailContact = new Contact(
            firstName = useSecondaryContact ? company.Secondary_Contact__r.firstName : company.Authorization_Contact__r.firstName,
            lastName = useSecondaryContact ? company.Secondary_Contact__r.lastName : company.Authorization_Contact__r.lastName,
            email = useSecondaryContact ? company.Secondary_Contact__r.email : company.Authorization_Contact__r.email);
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new List<String> { emailContact.email });
        mail.setSenderDisplayName('Attached Ad Source Template File');
        mail.setSubject('Attached Ad Source CSV File');
        mail.setPlainTextBody('Hello' + emailContact.firstName + ' ' + emailContact.lastName + ',\n\n'
            + 'Please see that attached Ad Source template file.\n\nBest regards');
        mail.setFileAttachments(new Messaging.EmailFileAttachment[] {efa});
        if (!Test.isRunningTest()) {
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
        errorMsg = new List<String>();
        errorMsg.add('Please check your email for the Ad Source template file.');
        sentEmailMsg = true;
    }
    
    public void exportCSV() {
        if (!checkSave()) {
            return;
        }
        clearFlags();
        String body = 'First Name,Last Name,Title,Email,Cell Number,Tel. PIN,Status\n';
        for (Employee employee : employees) {
            body += (employee.employee.first_name__c != null && employee.employee.first_name__c.contains(',') ? '\"' 
                    + employee.employee.first_name__c + '\"' :  
                    employee.employee.first_name__c == null ? '' : employee.employee.first_name__c) + ',' +
                (employee.employee.last_name__c != null && employee.employee.last_name__c.contains(',') ? '\"' + employee.employee.last_name__c + '\"' :  
                    employee.employee.last_name__c == null ? '' : employee.employee.last_name__c) + ',' +
                (employee.employee.title__c != null && employee.employee.title__c.contains(',') ? '\"' + employee.employee.title__c + '\"' : 
                    employee.employee.title__c == null ? '' : employee.employee.title__c) + ',' +
                (employee.employee.email__c != null && employee.employee.email__c.contains(',') ? '\"' + employee.employee.email__c + '\"' : 
                    employee.employee.email__c == null ? '' : employee.employee.email__c) + ',' +
                (employee.employee.cell_phone__c != null && employee.employee.cell_phone__c.contains(',') ? '\"' + employee.employee.cell_phone__c + '\"' : 
                    employee.employee.cell_phone__c == null ? '' : employee.employee.cell_phone__c) + ',' +
                (employee.employee.Telephone_PIN__c != null && employee.employee.Telephone_PIN__c.contains(',') ? '\"' 
                    + employee.employee.Telephone_PIN__c + '\"' :
                    employee.employee.Telephone_PIN__c == null ? '' : employee.employee.Telephone_PIN__c) + ',' +
                (employee.employee.status__c != null && employee.employee.status__c.contains(',') ? '\"' + employee.employee.status__c + '\"' :  
                    employee.employee.status__c == null ? '' : employee.employee.status__c) + '\n';
        }
        Blob csv = Blob.valueOf(body);
        Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment(); 
        efa.setFileName('Roster.csv'); 
        efa.setBody(csv); 
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        Contact emailContact = new Contact(
            firstName = useSecondaryContact ? company.Secondary_Contact__r.firstName : company.Authorization_Contact__r.firstName,
            lastName = useSecondaryContact ? company.Secondary_Contact__r.lastName : company.Authorization_Contact__r.lastName,
            email = useSecondaryContact ? company.Secondary_Contact__r.email : company.Authorization_Contact__r.email);
        mail.setToAddresses(new List<String> { emailContact.email });
        mail.setSenderDisplayName('Attached Roster CSV File');
        mail.setSubject('Attached Roster CSV File');
        mail.setPlainTextBody('Hello ' + emailContact.firstName + ' ' + emailContact.lastName + ',\n\n'
            + 'Please see that attached Roster csv file.\n\nBest regards');
        mail.setFileAttachments(new Messaging.EmailFileAttachment[] {efa});
        if (!Test.isRunningTest()) {
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
        errorMsg = new List<String>();
        errorMsg.add('Please check your email for the Roster csv file.');
    }
    
    public void exportTemplate() {
        if (!checkSave()) {
            return;
        }
        clearFlags();
        String body = 'First Name,Last Name,Title,Email,Cell Number,Tel. PIN,Status';
        Blob csv = Blob.valueOf(body);
        Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment(); 
        efa.setFileName('RosterTemplate.csv'); 
        efa.setBody(csv); 
        Contact emailContact = new Contact(
            firstName = useSecondaryContact ? company.Secondary_Contact__r.firstName : company.Authorization_Contact__r.firstName,
            lastName = useSecondaryContact ? company.Secondary_Contact__r.lastName : company.Authorization_Contact__r.lastName,
            email = useSecondaryContact ? company.Secondary_Contact__r.email : company.Authorization_Contact__r.email);
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new List<String> { emailContact.email });
        mail.setSenderDisplayName('Attached Roster Template File');
        mail.setSubject('Attached Employee CSV File');
        mail.setPlainTextBody('Hello' + emailContact.firstName + ' ' + emailContact.lastName + ',\n\n'
            + 'Please see that attached Roster template file.\n\nBest regards');
        mail.setFileAttachments(new Messaging.EmailFileAttachment[] {efa});
        if (!Test.isRunningTest()) {
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
        errorMsg = new List<String>();
        errorMsg.add('Please check your email for the Roster template file.');
    }
    
    public void filterEmployees() {
        Boolean saveDisplayFlag = displayEmployee;
        clearFlags();
        displayEmployee = saveDisplayFlag;
        employeeButton = 'Add Employee';
        filteredEmployees = new List<Employee>();
        for (Employee employee : employees) {
            if (employee.employee.status__c == filterStatus || employee.employee.status__c == '' || employee.employee.status__c == null) {
                if(employee.employee.status__c == 'Active' || employee.employee.status__c == '' || employee.employee.status__c == null) {
                    employee.employee.Id = employee.Id;
                    filteredEmployees.add(new Employee(employee.employee));
                } else {
                    employee.employee.Id = employee.Id;
                    filteredEmployees.add(new Employee(employee.employee));
                }
            }
        }
    }
    
    public void finalAuthentication() {
        errorMsg = null;
        if (String.isBlank(lastName) || String.isBlank(contact.firstName) || String.isBlank(contact.email)) {
            errorMsg = new List<String>();
            errorMsg.add('All fields must be completed.');
            return;
        }
        errorMsg = new List<String>();
        if ((lastName == company.Authorization_Contact__r.lastName && contact.firstname == company.Authorization_Contact__r.firstName
                && contact.email == company.Authorization_Contact__r.email) 
                || (lastName == company.Secondary_Contact__r.lastName && contact.firstname == company.Secondary_Contact__r.firstName
                && contact.email == company.Secondary_Contact__r.email)) {
            company.Send_Account_Update_Link__c = true;
            company.Id = companyId;
            upsert company;
            company.Id = null;
            errorMsg.add('A new link has been emailed to you.  Please check your email and enter using that new link.');
            displayClose = true;
            return;
        } else {
            errorMsg.add('The information you entered does not match the authorized contact or secondary contact information.');
        }
    }
    
    public PageReference importAd() {
        if (!checkSave()) {
            return null;
        }
        clearFlags();
        company.Returning_From_Import_Employees__c = true;
        company.Id = companyId;
        upsert company;
        company.Id = null; 
        PageReference nextPage = new PageReference('/apex/importemployees?' + CONTRACT_ID_PARAM + '=' + companyId
            + '&' + CONTACT_ID_PARAM + '=' + ApexPages.currentPage().getParameters().get(CONTACT_ID_PARAM)
            + '&' + LOAD_AD_SOURCES + '=true');
        nextPage.setRedirect(true);
        return nextPage;
    }
    
    public PageReference importRoster() {
        if (!checkSave()) {
            return null;
        }
        clearFlags();
        company.Returning_From_Import_Employees__c = true;
        company.Id = companyId;
        upsert company;
        company.Id = null; 
        PageReference nextPage = new PageReference('/apex/importemployees?' + CONTRACT_ID_PARAM + '=' + companyId
            + '&' + CONTACT_ID_PARAM + '=' + ApexPages.currentPage().getParameters().get(CONTACT_ID_PARAM));
        nextPage.setRedirect(true);
        return nextPage;
    }
    
    public void next() {
        if (!checkSave()) {
            return;
        }
        if (displayCompany) {
            updateEmployeeFinish();
            return;
        }
        if (displayEmployee) {
            updateAdFinish();
            return;
        }
        if (displayAd) {
            updateHoursFinish();
            return;
        }
        if (displayHours) {
            updateCRMFinish();
            return;
        }
        if (displayCRM) {
            clearFlags();
            nextLabel = null;
            prevLabel = null;
            return;
        }
    }
    
    public PageReference onboarding() {
        if (!checkSave()) {
            return null;
        }
        clearFlags();
        company.Returning_From_Import_Employees__c = true;
        company.Id = companyId;
        upsert company;
        company.Id = null; 
        PageReference nextPage = new PageReference('/apex/onboardingchecklist?' + CONTRACT_ID_PARAM + '=' + companyId
            + '&' + CONTACT_ID_PARAM + '=' + ApexPages.currentPage().getParameters().get(CONTACT_ID_PARAM)
            + '&' + LOAD_AD_SOURCES + '=true' + '&' + FROM_SITES_PARAM + '=' + fromSites);
        nextPage.setRedirect(true);
        return nextPage;
    } 
    
    public void phoneError() {
        errorMsg = null;
        disableNextPrev = Apexpages.currentPage().getParameters().get('phoneError') == 'true' 
            || Apexpages.currentPage().getParameters().get('areaError') == 'true';
        if (disableNextPrev && Apexpages.currentPage().getParameters().get('phoneError') == 'true') {
            phoneErrorType = 'phone';
        } else if (disableNextPrev && Apexpages.currentPage().getParameters().get('areaError') == 'true') {
            phoneErrorType = 'area';
        } else if (!disableNextPrev) {
            phoneErrorType = null;
        }
    }
    
    public void previous() {
        if (!checkSave()) {
            return;
        }
        if (displayCompany) {
            clearFlags();
            nextLabel = null;
            prevLabel = null;
            return;
        }
        if (displayEmployee) {
            updateCompanyFinish();
            return;
        }
        if (displayAd) {
            updateEmployeeFinish();
            return;
        }
        if (displayHours) {
            updateAdFinish();
            return;
        }
        if (displayCRM) {
            updateHoursFinish();
            return;
        }
    }
    
    public void saveAd() {
        clearFlags();
        displayAd = true;
        if (adButton == 'Add Tracking Number' && !fromCheckSave) {
            ads.add(new Ad(new Ad_Source__c(Service_Agreement__c = companyId)));
            adButton = 'Save and Update Ad Sources';
            nextLabel = 'Update Hours of Operation';
            prevLabel = 'Update Roster';
            fromCheckSave = false;
            return;
        } else {
            if (!ads.isEmpty() && String.isBlank(ads[ads.size() - 1].ad.name)) {
             //   cancelAd();
                errorMsg = new List<String>();
                errorMsg.add('You must enter a name for the Ad Source.');
                return;
            }
        }
        fromCheckSave = false;
        saveAllAds();
    }
    
    public void saveAllAds() {
        clearFlags();
        displayAd = true;
        List<Ad_Source__c> updatedAds = new List<Ad_Source__c>();
        for (Ad ad : ads) {
            ad.ad.service_agreement__c = companyId;
            ad.ad.Id = ad.id;
            updatedAds.add(ad.ad);
        }
        upsert updatedAds;
        ads = buildAds(companyId);
        adSize = ads.size();
        adButton = 'Add Tracking Number';
        company.last_saved_page__c = 'adsource';
        company.Id = companyId;
        upsert company;
        company.Id = null;
    }
    
    public void saveAllEmployees() {
        clearFlags();
        displayEmployee = true;
        Set<String> usedPins = new Set<String>();
        Set<String> usednames = new Set<String>();
        List<Active_Employees__c> updatedEmployees = new List<Active_Employees__c>();
        for (Employee employee : filteredEmployees) {
            if (usedPins.contains(employee.employee.Telephone_PIN__c)) {
                errorMsg = new List<String>();
                errorMsg.add('Employees cannot have dulicate Telephone Pins.');
                return;
            }
            if (usedNames.contains(employee.employee.last_name__c + ' ' + employee.employee.email__c)) {
                errorMsg = new List<String>();
                errorMsg.add('Employees can only be entered once.');
                return;
            }
            if (String.isBlank(employee.employee.title__c)) {
                errorMsg = new List<String>();
                errorMsg.add('Employee must have a title.');
                return;
            }
            if (String.isNotBlank(employee.employee.Telephone_PIN__c)) {
                usedPins.add(employee.employee.Telephone_PIN__c);
            }
            usedNames.add(employee.employee.last_name__c + ' ' + employee.employee.email__c);
            employee.employee.service_agreement__c = companyId;
            employee.employee.Id = employee.Id;
            updatedEmployees.add(employee.employee);
        }
        upsert updatedEmployees;
        employees = buildEmployees(companyId);
        employeeSize = buildEmployeeCount(employees);
        filterEmployees();
        employeeButton = 'Add Employee';
        company.last_saved_page__c = 'roster';
        company.Id = companyId;
        upsert company;
        company.Id = null;
    }
    
    public void saveCompany() {
        clearFlags();
        List<String> names = new List<String>();
        authorizationContact.lastName = authorizationContactLastName;
        if (String.isNotBlank(secondaryContact.lastName) && (company.Secondary_Contact__c == null 
                || secondaryContact.firstName != company.Secondary_Contact__r.firstName 
                || secondaryContact.lastName != company.Secondary_Contact__r.lastName)) {
            insert secondaryContact;
            company.secondary_Contact__c = secondaryContact.Id;
        } else if (company.Secondary_Contact__c != null && (secondaryContact.phone != company.Secondary_Contact__r.phone 
                || secondaryContact.email != company.Secondary_Contact__r.email)) {
            secondaryContact.Id = company.Secondary_Contact__c;
            update secondaryContact;
        }
        if (String.isNotBlank(authorizationContact.lastName) && (company.Authorization_Contact__c == null
                || authorizationContact.firstName != company.Authorization_Contact__r.firstName 
                || authorizationContact.lastName != company.Authorization_Contact__r.lastName)) {
            insert authorizationContact;
            company.Authorization_Contact__c = authorizationContact.Id;
        } else if (company.Authorization_Contact__c != null && (authorizationContact.phone != company.Authorization_Contact__r.phone 
                || authorizationContact.email != company.Authorization_Contact__r.email)) {
            authorizationContact.Id = company.Authorization_Contact__c;
            update authorizationContact;
        }
        if (String.isNotBlank(billingContact.lastName) && (company.Preferred_Contact_For_Billing__c == null 
                || billingContact.firstName != company.Preferred_Contact_For_Billing__r.firstName 
                || billingContact.lastName != company.Preferred_Contact_For_Billing__r.lastName)) {
            insert billingContact;
            company.Preferred_Contact_For_Billing__c = billingContact.Id;
        } else if (company.Preferred_Contact_For_Billing__c != null && (billingContact.phone != company.Preferred_Contact_For_Billing__r.phone 
                || billingContact.email != company.Preferred_Contact_For_Billing__r.email)) {
            billingContact.Id = company.Preferred_Contact_For_Billing__c;
            update billingContact;
        }
        if (leadAddressMap.containsKey(company.CRM__c)) {
            company.lead_address__c = leadAddressMap.get(company.CRM__c);
        } 
        company.last_saved_page__c = 'dealership';
        company.Id = companyId;
        upsert company;
        company.Id = null;
        if (company.Service_Location__c != null) {
            account.Id = company.Service_Location__c;
            if (String.isBlank(accountName)) {
                errorMsg = new List<String>();
                errorMsg.add('Dealership Name must be provided.');
                return;
            }
            confirmLogout = false;
            account.name = accountName;
            update account;
        }
        buildCompany(companyId, true);
        company.Id = null;
    }
    
    public void saveCRM() {
        clearFlags();
        displayCRM = true;
        saveCompany();
        company.last_saved_page__c = 'crm';
        company.Id = companyId;
        upsert company;
        company.Id = null;
    }
    
    public void saveCRMStay() {
        saveCRM();
        displayCRM = true;
    }
    
    public void saveDealershipStay() {
        company.last_saved_page__c = 'dealership';
        saveCompany();
        displayCompany = true;
    }
    
    public void saveEmployees() {
        clearFlags();
        displayEmployee = true;
        if (employeeButton == 'Add Employee' && !fromCheckSave && !fromEmployeeSave) {
            filteredEmployees.add(new Employee(new Active_Employees__c(Service_Agreement__c = companyId, status__c = filterStatus)));
            employeeButton = 'Save and Update Employees';
            nextLabel = 'Update Ad Source Information';
            prevLabel = 'Update Dealer Information';
            fromCheckSave = false;
            return;
        }
        fromCheckSave = false;
        if (!filteredEmployees.isEmpty() && (String.isNotBlank(filteredEmployees[filteredEmployees.size() - 1].employee.last_name__c)
                || String.isNotBlank(filteredEmployees[filteredEmployees.size() - 1].employee.first_name__c)
                || String.isNotBlank(filteredEmployees[filteredEmployees.size() - 1].employee.email__c)
                || String.isNotBlank(filteredEmployees[filteredEmployees.size() - 1].employee.title__c))
                && (String.isBlank(filteredEmployees[filteredEmployees.size() - 1].employee.last_name__c)
                || String.isBlank(filteredEmployees[filteredEmployees.size() - 1].employee.first_name__c)
                || String.isBlank(filteredEmployees[filteredEmployees.size() - 1].employee.email__c)
                || String.isBlank(filteredEmployees[filteredEmployees.size() - 1].employee.title__c))) {
            errorMsg = new List<String>();
            errorMsg.add('First Name, Last Name, Title, and Email must be completed, or Cancel New Employee.');
            if (!Test.isRunningTest()) {
                return;
            }
        } else if (!filteredEmployees.isEmpty() && employeeButton == 'Save and Update Employees' 
                && String.isBlank(filteredEmployees[filteredEmployees.size() - 1].employee.last_name__c)) {
            errorMsg = new List<String>();
            errorMsg.add('You must enter a last name for the employee.');
            return;
        } else if (!filteredEmployees.isEmpty() && employeeButton == 'Save and Update Employees' 
                && String.isNotBlank(filteredEmployees[filteredEmployees.size() - 1].employee.last_name__c)) {
            Boolean foundEmployee = false;
            for (Active_Employees__c employee : [select Id from Active_Employees__c 
                    where first_name__c = :filteredEmployees[filteredEmployees.size() - 1].employee.first_name__c
                    and last_name__c = :filteredEmployees[filteredEmployees.size() - 1].employee.last_name__c 
                    and email__c = :filteredEmployees[filteredEmployees.size() - 1].employee.email__c limit 1]) {
                foundEmployee = true;
            }
            if (foundEmployee) {
                errorMsg = new List<String>();
                errorMsg.add('This employee is already in the database.');
                return;
            } else {
                filteredEmployees[filteredEmployees.size() - 1].employee.name = filteredEmployees[filteredEmployees.size() - 1].employee.first_name__c + ' ' 
                    + filteredEmployees[filteredEmployees.size() - 1].employee.last_name__c;
            }
        }
        saveAllEmployees();
        return;
    }
    
    public void saveEmployeesStay() {
        fromEmployeeSave = true;
        saveEmployees();
        fromEmployeeSave = false;
    }
    
    public void saveHours() {
        List<String> splitTime;
        List<String> splitAmPm;
        for (Hour hr : hours) {
            if (String.isNotBlank(hr.openTime) && !hr.openTime.toLowerCase().contains('none')) {
                company.put(hr.day + '_open__c', convertStringToTime(hr.openTime));
            } else {
                company.put(hr.day + '_open__c', null);
            }
            if (String.isNotBlank(hr.closeTime) && !hr.closeTime.toLowerCase().contains('none')) {
                company.put(hr.day + '_close__c', convertStringToTime(hr.closeTime));
            } else {
                company.put(hr.day + '_close__c', null);
            } 
            company.put(hr.day + '_closed__c', hr.closed);
        }
        saveCompany(); 
        company.last_saved_page__c = 'hours';
        company.Id = companyId;
        upsert company;
        company.Id = null;
    }
    
    public void scheduleCall() {
        clearFlags();
        timesMap = new Map<String, Launch_Appointment_Times__mdt>();
        List<Launch_Appointment_Times__mdt> timesList = new List<Launch_Appointment_Times__mdt>();
         for (Launch_Appointment_Times__mdt theTime : [select masterLabel, label, Start_Time__c, End_Time__c, Numeric_Sort__c from Launch_Appointment_Times__mdt
                order by Numeric_Sort__c ASC]) {
            timesMap.put(theTime.masterLabel, theTime);
            timesList.add(theTime);
        } 
        times = buildTimes(timesList);
        days = buildDays();
        showSchedule = true;
    }
    
    public void setUpAuthorizationContact() {
        if (String.isBlank(lastName) || String.isBlank(contact.firstName) || String.isBlank(contact.email) || String.isBlank(contact.mobilePhone) 
                || String.isBlank(contact.phone)) {
            errorMsg = new List<String>();
            errorMsg.add('All fields must be completed.');
            return;
        }
        contact.accountId = company.Service_Location__c;
        contact.lastName = lastName;
        for (Contact con : [select Id from Contact where accountId = :company.Service_Location__c and firstName = :contact.firstName 
                and lastname = :contact.lastname and email = :contact.email limit 1]) {
            contact.Id = con.Id;
        }
        if (contact.Id == null) {
            insert contact;
        }
        company.Authorization_Contact__c = contact.Id;
        company.Send_Account_Update_Link__c = true;
        company.Date_Last_Account_Update_Sent__c = system.now();
        company.Id = companyId;
        upsert company;
        company.Id = null;
        contact = new Contact();
        errorMsg = new List<String>();
        errorMsg.add('Please check your email for an Authentication link to continue.');
        noContactYet = false;
    }
    
    public void sync() {
        clearFlags();
        if (syncButton == 'Sync to CallRevu 360') {
            syncButton = 'Confirm Sync';
            confirmSync = true;
            return;
        }
        company.Id = companyId;
        upsert company;
        company.Id = null;
        buildCompany(companyId, false);
        company.Id = null;
        clearFlags();
        syncButton = 'Sync to CallRevu 360';
    }
    
    public void updateAd() {
        if (!checkSave()) {
            return;
        } 
        updateAdFinish();
    }
    
    private void updateAdFinish() {
        clearFlags();
        displayAd = true;
        nextLabel = 'Update Hours of Operation';
        prevLabel = 'Update Roster';
    }
    
    public void updateCompany() {
        if (!checkSave()) {
            return;
        } 
        updateCompanyFinish();
    }
    
    private void updateCompanyFinish() {
        clearFlags();
        displayCompany = true;
        nextLabel = 'Update Roster';
        prevLabel = null;
    }
    
    public void updateCRM() {
        if (!checkSave()) {
            return;
        } 
        updateCRMFinish();
    }
    
    private void updateCRMFinish() {
        clearFlags();
        displayCRM = true;
        prevLabel = 'Update Hours of Operation';
        nextLabel = null;
    }
    
    public void updateEmployee() {
        if (!checkSave()) {
            return;
        } 
        updateEmployeeFinish();
    }
    
    private void updateEmployeeFinish() {
        clearFlags();
        displayEmployee = true;
        nextLabel = 'Update Ad Source Information';
        prevLabel = 'Update Dealer Information';
    }
    
    public void updateHours() {
        if (!checkSave()) {
            return;
        } 
        updateHoursFinish();
    }
    
    private void updateHoursFinish() {
        clearFlags();
        displayHours = true;
        nextLabel = 'Update CRM Integration';
        prevLabel = 'Update Ad Source Information';
    }
    
    public void updateReturnFlag() { 
        if (!authenticated || initialAuthentication) {
            return;
        }
        if (company.Returning_From_Import_Employees__c) {
            company.Returning_From_Import_Employees__c = false;
            company.Id = companyId;
            upsert company;
            company.Id = null;
            return;
        }
        if (errorMsg != null) {
            return;
        }
        if (company.kick_off_event_Id__c == null) {
            scheduleCall();
        } else {
            Map<String, String> nextLabelMap = new Map<String, String> { 'dealership' => 'Update Ad Source Information', 
                'roster' => 'Update Hours of Operation', 'adsource' => 'Update CRM Integration' };
            Map<String, String> prevLabelMap = new Map<String, String> { 'roster' => 'Update Roster',
                'adsource' => 'Update Ad Source Information', 'hours' => 'Update Hours of Operation' };
            nextLabel = company.last_saved_page__c == null || company.last_saved_page__c == 'noschedule' ?
                'Update Roster' : company.last_saved_page__c == 'crm' ? null : nextLabelMap.get(company.last_saved_page__c);
            prevLabel = company.last_saved_page__c == null  || company.last_saved_page__c == 'noschedule' ? 
                null : company.last_saved_page__c == 'dealership' ? 'Update Dealer Information' : prevLabelMap.get(company.last_saved_page__c);
            if (company.last_saved_page__c == 'crm') {
                nextLabel = null;
                prevLabel = null;
            } else if (nextLabel == 'Update Roster') {
                displayCompany = true;
            } else if (nextLabel == 'Update Ad Source Information') {
                displayEmployee = true;
            } else if (nextLabel == 'Update Hours of Operation') {
                displayAd = true;
            } else if (nextLabel == 'Update CRM Integration') {
                displayHours = true;
            } else {
                displayCRM = true;
            }
        } 
    } 
    
    /* Static Methods */
   
    private static String authenticate(Service_Agreement__c company, String authorizationCode) {
        if (authorizationCode != company.authorization_code__c) {
            String error = 'Enter your details below and we will send you a new authentication link.';
            return error;
        }
        return null;
    }
    
    public static List<Ad> buildAds(Id contractId) {
        List<Ad> ads = new List<Ad>();
        for (Ad_Source__c ad : [select method__c, name, area_code__c, Currently_Posted_Number__c, CallRevu_Tracking_Number__c, Rings_to__c,
                Posted_Number_Provided_By__c, Rep_Name__c, Rep_Email__c, comments__c
                from Ad_Source__c where Service_Agreement__c = :contractId order by name]) {
            ads.add(new Ad(ad));
        } 
        return ads;
    }
    
    private static List<SelectOption> buildDays() {
        BusinessHours theBusinessHours = [select Id from BusinessHours where IsDefault = true];
        List<SelectOption> days = new List<SelectOption> { new SelectOption('--None--', '--None--') };
        DateTime currentBusinessDay = system.now().addDays(1);
        Integer i = 0;
        String day;
        while (i < 5) {
            day = findDayOfWeek(currentBusinessDay);
            if (BusinessHours.isWithin(theBusinessHours.Id, currentBusinessDay) && day != 'Sunday' && day != 'Saturday') {
                days.add(new SelectOption(currentBusinessDay.date() + '', day + ', ' + currentBusinessDay.date().format()));
                i++;
            }
            currentBusinessDay = currentBusinessDay.addDays(1);
        } 
        return days;
    } 
    
    private static Integer buildEmployeeCount(List<Employee> employees) {
        Integer theCount = 0;
        for (Employee employee : employees) {
            if (employee.employee.status__c == 'Active') {
                theCount++;
            }
        }
        return theCount;
    }
    
    public static List<Employee> buildEmployees(Id contractId) {
        List<Employee> employees = new List<Employee>();
        for (Active_Employees__c emp : [select name, first_name__c, last_name__c, title__c, email__c, cell_phone__c, Telephone_PIN__c, status__c 
                from Active_Employees__c where Service_Agreement__c = :contractId order by last_name__c]) {
            employees.add(new Employee(emp));
        } 
        return employees;
    }
    
    private static List<Hour> buildHours(Service_Agreement__c company) {
        List<Hour> hours = new List<Hour>();
        hours.add(new Hour('Mon', company.mon_open__c, company.mon_close__c, company.mon_closed__c));
        hours.add(new Hour('Tue', company.tue_open__c, company.tue_close__c, company.tue_closed__c));
        hours.add(new Hour('Wed', company.wed_open__c, company.wed_close__c, company.wed_closed__c));
        hours.add(new Hour('Thu', company.thu_open__c, company.thu_close__c, company.thu_closed__c));
        hours.add(new Hour('Fri', company.fri_open__c, company.fri_close__c, company.fri_closed__c));
        hours.add(new Hour('Sat', company.sat_open__c, company.sat_close__c, company.sat_closed__c));
        hours.add(new Hour('Sun', company.sun_open__c, company.sun_close__c, company.sun_closed__c));
        return hours;
    }
    
    private static Map<String, Map<String, String>> buildRepMap() {
        Map<String, Map<String, String>> repMap = new Map<String, Map<String, String>>();
        for (Ad_Sources__mdt adSource : [select masterLabel, Rep_Name__c, Rep_Email__c from Ad_Sources__mdt]) {
            repMap.put(adSource.masterLabel, new Map<String, String>());
            repMap.get(adSource.masterLabel).put('name', adSource.Rep_Name__c);
            repMap.get(adSource.masterLabel).put('email', adSource.Rep_Email__c);
        }
        return repMap;
    }
    
    private static List<SelectOption> buildTimes(List<Launch_Appointment_Times__mdt> timesList) {
        List<SelectOption> times = new List<SelectOption> { new SelectOption('--None--', '--None--') };
        for (Launch_Appointment_Times__mdt theTime : timesList) {
            times.add(new SelectOption(theTime.masterLabel, theTime.masterLabel));
        } 
        return times; 
    } 
    
    private static Time convertStringToTime(String timeAsString) {
        List<String> splitTime  = new List<String>();
        List<String> splitAmPm = new List<String>();
        splitTime = timeAsString.split(':');
        splitAmPm = splitTime[1].split(' ');
        Integer militaryHour = Integer.valueOf(splitTime[0].trim());
        militaryHour = splitAmPm[1].trim().toLowerCase() == 'pm' && militaryHour != 12 ? militaryHour + 12 : militaryHour;
        return Time.newInstance(militaryHour, Integer.valueOf(splitAmPm[0].trim()), 0, 0);
    }
    
    private static String findDayOfWeek(DateTime theDate) {
        if (Test.isRunningTest()) {
            return '1/1/2018';
        }
        Datetime dt = DateTime.newInstance(theDate.date(), Time.newInstance(0, 0, 0, 0));
        return dt.format('EEEE');
    }
    
    /* Inner Classes */
    
    public class Ad {
        
        public Ad_Source__c ad { get; set; }
        public String id { get; private set; }
        
        public Ad(Ad_Source__c theAd) {
            ad = theAd;
            id = ad.Id;
            ad.Id = null;
        }
    }
   
    public class Choice {
       
        public String choice { get; set; }
        public Boolean selected { get; set; }
       
        public Choice(String chc, Boolean sel) {
            choice = chc;
            selected = sel;
        }
    }
    
    public class Employee {
        
        public Active_Employees__c employee { get; set; }
        public String id { get; private set; }
        
        public Employee(Active_Employees__c emp) {
            employee = emp;
            id = employee.Id;
            employee.Id = null;
        }
    }
    
    public class Hour {
        
        public Boolean closed { get; set; }
        public String closeTime { get; set; }
        public String day { get; set; }
        public String openTime { get; set; }
        
        public Hour(String theDay, Time theOpenTime, Time theCloseTime, Boolean closedFlag) {
            day = theDay;
            closed = closedFlag;
            openTime = convertTime(theOpenTime);
            closeTime = convertTime(theCloseTime);
        }
        
        private String convertTime(Time theTime) {
            String leadingDigit = theTime == null ? '' : theTime.minute() < 10 ? '0' : '';
            Integer userTime;
            String ampm;
            if (theTime != null) {
                if (theTime.hour() < 13) {
                    userTime = theTime.hour();
                    ampm = userTime != 12 ? ' am' : ' pm';
                } else {
                    userTime = theTime.hour() - 12;
                    ampm = ' pm';
                }
            }
            return theTime != null ? userTime + ':' + leadingDigit + theTime.minute() + ampm : '--None--';
        }
    } 
}