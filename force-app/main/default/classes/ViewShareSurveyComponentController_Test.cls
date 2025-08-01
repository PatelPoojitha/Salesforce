@isTest
private with sharing class ViewShareSurveyComponentController_Test {
    private static testmethod void testShareSurvey()
    {
        Survey__c mySurvey = new Survey__c();
        mySurvey.Thank_You_Text__c = 'empty';
        insert mySurvey;

        ViewShareSurveyComponentController vss = new ViewShareSurveyComponentController();
        vss.surveyId = mySurvey.Id;

        vss.selectedURLType = 'Chatter';
        System.assertEquals(vss.getVFUrl(), vss.surveyURLBase);
        System.assertEquals('id=' + mySurvey.Id + '&cId=none&caId=none', vss.surveyURL);

        vss.selectedURLType = 'Email Link, Anonymous';
        System.assertEquals(vss.getVFUrl(), vss.surveyURLBase);
        System.assertEquals('id=' + mySurvey.Id + '&cId=none&caId=none', vss.surveyURL);


        vss.selectedURLType = 'Email Link w/ Contact Merge';
        System.assertEquals('id=' + mySurvey.Id + '&cId={!Contact.Id}&caId=none', vss.surveyURL);

        vss.selectedURLType = 'Email Link w/ Contact & Case Merge';
        System.assertEquals('id=' + mySurvey.Id +  '&cId={!Contact.Id}&caId={!Case.id}', vss.surveyURL);

        System.assert(vss.sitesPicklist.size()>=1);

    }
}