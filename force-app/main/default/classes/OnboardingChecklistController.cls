/*
 * Developer: Jim Hyland <jon@shippconsulting.com>
 *  
 * Description: Controller for page for OnboardingChecklist page.
 *
 * Test code in OnboardingChecklistTest class.
 */
public class OnboardingChecklistController {

    /* Variables */
    
    public Service_Agreement__c company { get; set; }
    public List<Checklist> dates { get; set; }
    public Service_Agreement__c dummyAgreement { get; private set; }
    public List<String> errorMsg { get; private set; }
    public Boolean fromSites { get; private set; }
    
    /* Constructor */
    
    public OnboardingChecklistController() {
        if (ApexPages.currentPage().getParameters().containsKey(ContractUpdateController.CONTRACT_ID_PARAM)) {
            buildCompany(ApexPages.currentPage().getParameters().get(ContractUpdateController.CONTRACT_ID_PARAM));
        } else {
            errorMsg = new List<String>();
            errorMsg.add('Missing account id in url.  Please contact your administrator.');
            return;
        }
        fromSites = ApexPages.currentPage().getParameters().get(ContractUpdateController.FROM_SITES_PARAM) == 'true';
        dates = buildChecklist(company, fromSites);
        dummyAgreement = new Service_Agreement__c(active__c = true, Create_Account__c = false);
    } 
    
    /* Instance Methods */
    
    private void buildCompany(Id companyId) {
        company = [select partner_implementation__c, Service_Location__r.partner_logo_url__c, Bill_To_Account__r.partner_image_width__c, 
            Bill_To_Account__r.partner_image_height__c, Date_Completed_WL__c, Date_Completed_CC__c, Date_Completed_RR__c, Date_Completed_AD_LOA__c,
            Date_Completed_AD_PORT__c, Date_Completed_LT_PA__c, Date_Completed_RA__c, Date_Completed_LR__c, Date_Completed_LT_LC__c, 
            Date_Completed_CR360__c, Date_Completed_CRM__c, Date_Completed_TLE__c from Service_Agreement__c where Id = :companyId];
    } 
    
    public PageReference cancelChecklist() {
        errorMsg = null;
        if (!checkDates()) {
            errorMsg = new List<String>();
            errorMsg.add('Invalid Dates or Times entered.  Please enter Date and Time as MM-dd-YYYY HH:MM AM/PM');
            return null;
        }
        update company;
        PageReference nextPage = new PageReference('/apex/contractupdate?' + ContractUpdateController.CONTRACT_ID_PARAM + '=' 
            + ApexPages.currentPage().getParameters().get(ContractUpdateController.CONTRACT_ID_PARAM)
            + '&' + ContractUpdateController.CONTACT_ID_PARAM + '=' 
            + ApexPages.currentPage().getParameters().get(ContractUpdateController.CONTACT_ID_PARAM));
        nextpage.setRedirect(true);
        return nextPage;
    } 
    
    public Boolean checkDates() {
        for (Checklist ch : dates) {
            if (String.isBlank(ch.theDate)) {
                company.put(ch.theField, null);
                continue;
            }
            List<String> dateTimes;
            if (!ch.theDate.contains(' ') || !ch.theDate.contains('-') || !ch.theDate.contains(':')) {
                return false;
            }
            dateTimes = ch.theDate.split(' ');
            String theDate = dateTimes[0].trim().replace('-', '/');
            if (dateTimes[2].toLowerCase() != 'am' && dateTimes[2].toLowerCase() != 'pm') {
                return false;
            }
            DateTime dt;
            try {
                dt = DateTime.parse(theDate + ' ' + dateTimes[1].trim() + ' ' + dateTimes[2].trim().toUpperCase());
            } catch(Exception e) {
                return false;
            }
            company.put(ch.theField, dt);
        }
        return true;
    }
    
    /* Static Methds */
    
    private List<Checklist> buildChecklist(Service_Agreement__c company, Boolean fromSites) {
        List<Checklist> dates = new List<Checklist>();
        dates.add(new Checklist('Welcome Letter and Enrollment Portal Links Sent', company.Date_Completed_WL__c, 'Date_Completed_WL__c', fromSites));
        dates.add(new Checklist('Enrollment Call Completed', company.Date_Completed_CC__c, 'Date_Completed_CC__c', fromSites));
        dates.add(new Checklist('Roster Received', company.Date_Completed_RR__c, 'Date_Completed_RR__c', fromSites));
        dates.add(new Checklist('Ad Sources Received / LOA and lines Received for Port', company.Date_Completed_AD_LOA__c, 
            'Date_Completed_AD_LOA__c', fromSites));
        dates.add(new Checklist('Ad Sources Created / Port Submitted', company.Date_Completed_AD_PORT__c, 'Date_Completed_AD_PORT__c', fromSites));
        dates.add(new Checklist('Lines Tested / Port Accepted', company.Date_Completed_LT_PA__c, 'Date_Completed_LT_PA__c', fromSites));
        dates.add(new Checklist('Routing Approval received for new lines', company.Date_Completed_RA__c, 'Date_Completed_RA__c', fromSites));
        dates.add(new Checklist('Lines Routed / Port completed', company.Date_Completed_LR__c, 'Date_Completed_LR__c', fromSites));
        dates.add(new Checklist('Lines tested / additional lines created as needed', company.Date_Completed_LT_LC__c, 'Date_Completed_LT_LC__c', 
            fromSites));
        dates.add(new Checklist('If a group add group number and group to CR360', company.Date_Completed_CR360__c, 'Date_Completed_CR360__c', fromSites));
        dates.add(new Checklist('CRM and C2C integrations Requested', company.Date_Completed_CRM__c, 'Date_Completed_CRM__c', fromSites));
        dates.add(new Checklist('Transition to Launch Email', company.Date_Completed_TLE__c, 'Date_Completed_TLE__c', fromSites));
        return dates;
    }
    
    /* Inner Classes */
    
    public class Checklist {
        
        public String question { get; private set; }
        public String theDate { get; set; }
        public String theField;
        
        public Checklist(String ques, DateTime dt, String fld, Boolean fromSites) {
            theField = fld;
            if (dt == null) {
                theDate = '';
            } else {
                String ampm = dt.hour() == 0 ? 'AM' : dt.hour() >= 12 ? 'PM' : 'AM';
                theDate = dt.month() + '-' + dt.day() + '-' + dt.year() + ' ' + (dt.hour() == 0 ? '12' : dt.hour() <= 12 ? 
                    String.valueOf(dt.hour()) : String.valueOf(dt.hour() - 12)) + ':' 
                    + (dt.minute() < 10 ? ('0' + String.valueOf(dt.minute())) : String.valueOf(dt.minute())) + ' ' + ampm;
            }
            question = fromSites ? ques + ' ' + theDate : ques;
        }
    }
}