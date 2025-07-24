/*
    Developer:  Jim Hyland <jon@shippconsulting.com>
    
    Description:
       Tests for AccountInformationController
*/
@isTest
public class AccountInformationTest {
     
    /* Test Methods */
    
    @isTest
    private static void testAccountInformationController() {
        
        // set up test data
    /*    Account account = TestUtil.createAccount();
        Account badAccount = TestUtil.createAccount();
        Contact contact = TestUtil.generateContact(account.Id);
        contact.firstName = 'abc';
        contact.email = 'j@j.com';
        insert contact;
        Contact badContact = TestUtil.createContact(account.Id);
        account.Authorization_Contact__c = contact.Id;
        update account;
        insert new Event(Type = 'Call', status__c = 'Open', startDateTime = system.now(), endDateTime = system.now().addMinutes(30));
         
        // run tests
        PageReference pageRef = Page.AccountInformationUpdate;
        Test.setCurrentPage(pageRef);
        AccountInformationUpdateController con = new AccountInformationUpdateController();
        ApexPages.currentPage().getParameters().put(AccountInformationUpdateController.ACCOUNT_ID_PARAM, badAccount.Id);
        ApexPages.currentPage().getParameters().put(AccountInformationUpdateController.CONTACT_ID_PARAM, badContact.Id);
        con = new AccountInformationUpdateController();
        ApexPages.currentPage().getParameters().put(AccountInformationUpdateController.ACCOUNT_ID_PARAM, account.Id);
        con = new AccountInformationUpdateController();
        ApexPages.currentPage().getParameters().put(AccountInformationUpdateController.CONTACT_ID_PARAM, contact.Id);
        con = new AccountInformationUpdateController();
        con.lastname = contact.lastName;
        con.contact.firstName = contact.firstName;
        con.contact.email = contact.email;
        con.contact.mobilePhone='508-123-1111';
        con.setUpAuthorizationContact();
        con.contact.phone='508-123-1112';
        con.setUpAuthorizationContact();
        con.lastname = contact.lastName;
        con.contact.firstName = contact.firstName;
        con.contact.email = contact.email;
        con.finalAuthentication();
        con.updateAd();
        con.updateAll();
        con.updateCompany();
        con.updateEmployee();
        con.saveAd();
        con.cancelAd();
        con.saveAd();
        con.saveAd();
        con.saveAd();
        con.saveCompany();
        con.saveEmployees();
        con.cancelEmployee();
        con.saveEmployees();
        con.saveEmployees();
        con.endSession();
        con.endSession();
        con.showPopupMakes();
        con.saveSelect();
        con.cancelSelect();
        con.exportCSV();
        con.scheduleCall();
        con.callTimes[0].updateEvent();
        con.exitSchedule(); */
    }
}