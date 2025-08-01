/*
    Developer:  Jim Hyland <jon@shippconsulting.com>
    
    Description:
       Tests for ContractUpdateController
*/
@isTest
public class ContractUpdateTest {
     
    /* Test Methods */
    
    @isTest
    private static void testContractUpdateController() {
        
        // set up test data
        Account account = TestUtil.createAccount();
        Account badAccount = TestUtil.createAccount();
        Contact contact = TestUtil.generateContact(account.Id);
        Contact secondaryContact = TestUtil.createContact(account.Id);
        Contact billingContact = TestUtil.createContact(account.Id);
        contact.firstName = 'abc';
        contact.email = 'j@j.com';
        insert contact;
        Contact badContact = TestUtil.createContact(account.Id);
        Service_Agreement__c contract = new Service_Agreement__c(Service_Location__c = account.Id, Authorization_Contact__c = contact.Id,
            crm__c = 'eLead1', secondary_contact__c = secondaryContact.Id, Preferred_Contact_For_Billing__c = billingContact.Id,
            current__c = 'CallBright', is_test__c = true);
        Service_Agreement__c badContract = new Service_Agreement__c(Service_Location__c = account.Id, Authorization_Contact__c = contact.Id);
        insert new List<Service_Agreement__c> { contract, badContract };
        insert new Event(Type = 'Call', status__c = 'Open', startDateTime = system.now(), endDateTime = system.now().addMinutes(30));
         
        // run tests
        PageReference pageRef = Page.ContractUpdate;
        Test.setCurrentPage(pageRef);
        ContractUpdateController con = new ContractUpdateController();
        ApexPages.currentPage().getParameters().put(ContractUpdateController.CONTRACT_ID_PARAM, badContract.Id);
        ApexPages.currentPage().getParameters().put(ContractUpdateController.CONTACT_ID_PARAM, badContact.Id);
        con = new ContractUpdateController();
        ApexPages.currentPage().getParameters().put(ContractUpdateController.CONTRACT_ID_PARAM, contract.Id);
        con = new ContractUpdateController();
        ApexPages.currentPage().getParameters().put(ContractUpdateController.CONTACT_ID_PARAM, contact.Id);
        con = new ContractUpdateController();
        con.lastname = contact.lastName;
        con.contact.firstName = contact.firstName;
        con.contact.email = contact.email;
        con.contact.mobilePhone='508-123-1111';
        con.setUpAuthorizationContact();
        con.contact.phone='508-123-1112';
        con.setUpAuthorizationContact();
        con.finalAuthentication();
        con.lastname = contact.lastName;
        con.contact.firstName = contact.firstName;
        con.contact.email = contact.email;
        con.finalAuthentication();
        con.contact.email = 'test@test.com';
        con.finalAuthentication();
        con.updateAd();
        con.updateCompany();
        con.updateEmployee();
        con.saveAd();
        con.cancelAd();
        con.saveAd();
        con.updateEmployee();
        con.saveAd();
        con.saveAd();
        con.saveAd();
        con.defaultRep();
        con.deleteAd(); 
        con.saveDealershipStay();
        con.fromCheckSave = true;
        con.saveEmployees();
        con.endSession();
        con.endSession();
        con.exportCSV();
    } 
    
    @isTest
    private static void testContractUpdateControllerContinued() {
        // set up test data
        Account account = TestUtil.createAccount();
        Account badAccount = TestUtil.createAccount();
        Contact contact = TestUtil.generateContact(account.Id);
        Contact secondaryContact = TestUtil.createContact(account.Id);
        Contact billingContact = TestUtil.createContact(account.Id);
        contact.firstName = 'abc';
        contact.email = 'j@j.com';
        insert contact;
        Contact badContact = TestUtil.createContact(account.Id);
        Service_Agreement__c contract = new Service_Agreement__c(Service_Location__c = account.Id, Authorization_Contact__c = contact.Id,
            crm__c = 'eLead1', secondary_contact__c = secondaryContact.Id, Preferred_Contact_For_Billing__c = billingContact.Id,
            current__c = 'CallBright', is_test__c = true);
        Service_Agreement__c badContract = new Service_Agreement__c(Service_Location__c = account.Id, Authorization_Contact__c = contact.Id, 
            is_test__c = true);
        insert new List<Service_Agreement__c> { contract, badContract };
        insert new Event(Type = 'Call', status__c = 'Open', startDateTime = system.now(), endDateTime = system.now().addMinutes(30));
        Blob badAttachmentBody1 = Blob.valueOf('ID NUM.');
        Blob badAttachmentBody2 = Blob.valueOf('First Name,Last Name,Title,Email,Cell Number,Status,Tel. PIN\n'
            + 'first,last,vp,j@j.com,5081231212,1234,Active');
        Blob attachmentBody = Blob.valueOf('First Name,Last Name,Title,Email,Cell Number,Tel. PIN,Status\n'
            + 'first,"last",vp,j@j.com,5081231212,1234,Active');
        Blob adAttachmentBody = Blob.valueOf('Method,Ad Source Name,Area Code,Currently Posted Number,CallRevu Tracking Number,Rings-to,'
            + 'Posted Number Provided By,Rep Name, Rep Email,Comments\n'
            + 'ad,"name",508,5081231212,3,5081231212,a,Rep,r@r.com,abc');
        Attachment attachment = new Attachment();
        insert new Data_Collection_HTML__c(html__c = 'test', Currently_Displaying__c = true);
        Active_Employees__c ae =  new Active_Employees__c(Service_Agreement__c = contract.Id);
        insert ae;
        Ad_Source__c adsource = new Ad_Source__c(Service_Agreement__c = contract.Id);
        insert adsource;
        
        // run tests
        Test.startTest();
        PageReference pageRef = Page.ContractUpdate;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put(ContractUpdateController.CONTRACT_ID_PARAM, contract.Id);
        ApexPages.currentPage().getParameters().put(ContractUpdateController.CONTACT_ID_PARAM, contact.Id);
        ContractUpdateController con = new ContractUpdateController();
        con.scheduleCall();
        con.selectedDay = system.today() + '';
        con.selectedTime = '8:00 am to 8:30 am';
        con.confirmAppointment();
        //con.confirmAppointment();
        con.sync();
        //con.sync();
        con.updateHours();
        con.company.Mon_Closed__c = true;
        con.company.Tue_Closed__c = true;
        con.company.Wed_Closed__c = true;
        con.company.Thu_Closed__c = true;
        con.company.Fri_Closed__c = true;
        con.company.Sat_Closed__c = true;
        con.company.Sun_Closed__c = true;
        con.errorMsg = null;
        con.errorMsg = null;
        con.updateCRM();
        con.errorMsg = null;
        con.saveCRM();
        con.company.crm_user_name__c = 'test';
        con.company.crm_password__c = 'test';
        con.errorMsg = null;
        con.saveCRMStay();
        con.saveCRM();
        con.errorMsg = null;
        con.saveHours();
        con.errorMsg = null;
        con.filterEmployees();
        con.errorMsg = null;
        con.displayPDF();
        con.errorMsg = null;
        con.exportTemplate();
        con.errorMsg = null;
        con.importRoster();
        con.errorMsg = null;
        con.exportAdCSV();
        con.errorMsg = null;
        con.exportAdTemplate();
        con.errorMsg = null;
        con.importAd();
        con.errorMsg = null;
        con.errorMsg = null;
        con.updateCompany();
        con.errorMsg = null;
        con.next();
        con.errorMsg = null;
        //con.next();
        con.errorMsg = null;
        //con.next();
        con.errorMsg = null;
        //con.next();
        con.errorMsg = null;
        //con.next();
        con.errorMsg = null;
        //con.updateCRM();
        con.errorMsg = null;
        con.previous();
        con.errorMsg = null;
        //con.previous();
        con.errorMsg = null;
        //con.previous();
        con.errorMsg = null;
        //con.previous();
        con.errorMsg = null;
        //con.previous();
        con.errorMsg = null;
        con.company.Returning_From_Import_Employees__c = false;
        con.company.kick_off_event_Id__c = 'Test';
        con.updateReturnFlag(); 
        con.saveAllAds();
        con.cancelEmployee();
        con.errorMsg = null;
        con.phoneError();
        con.errorMsg = null;
        con.cancelImport();
        con.errorMsg = null;
        con.deleteEmployee();
        con.errorMsg = null;
        con.saveEmployeesStay();
        con.onboarding();
        PageReference pageRef1 = Page.TestFileLoad;
        Test.setCurrentPage(pageRef1);
        TestFileLoadController con1 = new TestFileLoadController();
        ApexPages.currentPage().getParameters().put(ContractUpdateController.CONTRACT_ID_PARAM, contract.Id);
        con1 = new TestFileLoadController();
        con1.newAttachment = attachment;
        con1.previewFile();
        con1.newAttachment.Name = 'testAttachment.txt';
        con1.previewFile();
        con1.newAttachment.Body = badAttachmentBody1;
        con1.previewFile();
        con1.newAttachment.Body = badAttachmentBody2;
        con1.previewFile();
        con1.newAttachment.Body = attachmentBody;
        con1.previewFile();
        con1.cancelImport(); 
        ApexPages.currentPage().getParameters().put(ContractUpdateController.LOAD_AD_SOURCES, 'true');
        con1 = new TestFileLoadController();
        con1.newAttachment = attachment;
        con1.newAttachment.Body = adAttachmentBody;
        con1.previewFile();
        PageReference pageRef2 = Page.LandingPage;
        Test.setCurrentPage(pageRef2);
        LandingPageController con2 = new LandingPageController();
        ApexPages.currentPage().getParameters().put(ContractUpdateController.CONTRACT_ID_PARAM, contract.Id);
        ApexPages.currentPage().getParameters().put(ContractUpdateController.CONTACT_ID_PARAM, contact.Id);
        con2 = new LandingPageController();
        con2.fillOutSelf();
        con2.next();
        con2.fillOutDesignate();
        con2.authorizationContact.firstName = 'first';
        con2.authorizationContactLastName = 'lasta';
        con2.authorizationContact.email = 'l@l.com';
        con2.secondaryContact.firstName = 'first';
        con2.secondaryContact.lastName = 'lastb';
        con2.secondaryContact.email = 'k@k.com';
        con2.sendEmail();
        Test.stopTest();
    } 
}