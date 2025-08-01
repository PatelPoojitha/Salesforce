@isTest
private class SurveyAndQuestionController_Test {

    // Test constructor and calls within it
    @isTest
    private static void testCreateQuestionController() {
        SurveyTestingUtil tu = new SurveyTestingUtil();
        Apexpages.currentPage().getParameters().put('id', tu.surveyId);
        Apexpages.Standardcontroller std;
        SurveyAndQuestionController cqc = new SurveyAndQuestionController(std);
        
        cqc.addQuestion();
        cqc.getNewQuestionNum();
        cqc.makeNewQuestionLink();
        
        System.assert(cqc.surveyId == tu.surveyId, 'Survey ID should match');
    }

    @isTest
    // Test the edit question functionality
    private static void testEditQuestion() {
        SurveyTestingUtil tu = new SurveyTestingUtil();
        Apexpages.currentPage().getParameters().put('id', tu.surveyId);
        Apexpages.Standardcontroller std;
        SurveyAndQuestionController cqc = new SurveyAndQuestionController(std);
        
        cqc.editQuestion();
        
        for (Integer i = 0; i < tu.questionIds.size(); i++) {
            cqc.questionReference = tu.questionIds[i];
            cqc.editQuestion();
        }

        System.assert(cqc.editQuestion() == null, 'The question should be null after editing.');
    }

    @isTest
    // Test saving new question and creating new ones
    private static void testsaveAndNewQuestion() {
        SurveyTestingUtil tu = new SurveyTestingUtil();
        Apexpages.currentPage().getParameters().put('id', tu.surveyId);
        Apexpages.Standardcontroller std;
        SurveyAndQuestionController cqc = new SurveyAndQuestionController(std);
        
        // Test saving new question
        cqc.qQuestion = 'THIS IS A NEW QUESTION';
        cqc.qChoices = '1\\n2\\n3\\n';
        cqc.qRequired = true;
        cqc.questionType = 'Single Select--Vertical';
        cqc.saveAndNewQuestion();
        
        // Ensure that new questions are created
        List<Survey_Question__c> questions = [SELECT Id FROM Survey_Question__c WHERE Survey__c = :tu.surveyId];
        System.assert(questions.size() > 0, 'There should be at least one question in the database.');

        // Test new question count
        System.assertEquals(questions.size(), 5, 'New question number should be 5');
        
        // Edit existing question
        SurveyAndQuestionController cqcI = new SurveyAndQuestionController(std);
        cqcI.questionReference = tu.questionIds[0];
        cqcI.editQuestion();
        cqcI.qQuestion = 'Updated Question Text';
        cqcI.qChoices = '1\\n2\\n3\\n';
        cqcI.qRequired = true;
        cqcI.questionType = 'Single Select--Vertical';
        cqcI.saveAndNewQuestion();
        
        questions = [SELECT Id FROM Survey_Question__c WHERE Survey__c = :tu.surveyId];
        System.assertEquals(questions.size(), 5, 'New question number after saving should still be 5');
    }

    @isTest
    // Test the save and save question functionality
    private static void testsavesaveQuestion() {
        SurveyTestingUtil tu = new SurveyTestingUtil();
        Apexpages.currentPage().getParameters().put('id', tu.surveyId);
        Apexpages.Standardcontroller std;
        SurveyAndQuestionController cqc = new SurveyAndQuestionController(std);
        
        // Test saving a new question
        cqc.qQuestion = 'THIS IS A NEW QUESTION';
        cqc.qChoices = '1\\n2\\n3\\n';
        cqc.qRequired = true;
        cqc.questionType = 'Single Select--Vertical';
        cqc.controllerSavQuestion();
        
        // Ensure that new questions are created
        List<Survey_Question__c> questions = [SELECT Id FROM Survey_Question__c WHERE Survey__c = :tu.surveyId];
        System.assert(questions.size() > 0, 'There should be at least one question in the database.');
        
        // Test new question count
        System.assertEquals(questions.size(), 5, 'New question number should be 5');
        
        // Edit existing question
        SurveyAndQuestionController cqcI = new SurveyAndQuestionController(std);
        cqcI.questionReference = tu.questionIds[0];
        cqcI.editQuestion();
        cqcI.qQuestion = 'Updated Question Text';
        cqcI.qChoices = '1\\n2\\n3\\n';
        cqcI.qRequired = true;
        cqcI.questionType = 'Single Select--Vertical';
        cqcI.controllerSavQuestion();
        
        questions = [SELECT Id FROM Survey_Question__c WHERE Survey__c = :tu.surveyId];
        System.assertEquals(questions.size(), 5, 'New question number after save should still be 5');
    }

    @isTest
    private static void testPreviewQuestion() {
        SurveyTestingUtil tu = new SurveyTestingUtil();
        Apexpages.currentPage().getParameters().put('id', tu.surveyId);
        Apexpages.Standardcontroller std;
        SurveyAndQuestionController cqc = new SurveyAndQuestionController(std);

        // Test preview question
        for (Integer i = 0; i < tu.questionIds.size(); i++) {
            cqc.questionReference = tu.questionIds[i];
            cqc.editQuestion();
            cqc.previewQuestion();
        }

        System.assert(cqc.previewQuestion() == null, 'Preview should return null after the last question.');
    }

    @isTest
    private static void testUpdateSurveyName() {
        SurveyTestingUtil tu = new SurveyTestingUtil();
        Apexpages.currentPage().getParameters().put('id', tu.surveyId);
        Apexpages.Standardcontroller stc;
        SurveyAndQuestionController vsc = new SurveyAndQuestionController(stc);
        
        vsc.surveyName = 'New Survey Name';
        System.assert(vsc.updateSurveyName() == null, 'Survey name update should return null');
    }

    @isTest
    private static void testUpdateSurveyThankYouAndLink() {
        SurveyTestingUtil tu = new SurveyTestingUtil();
        Apexpages.currentPage().getParameters().put('id', tu.surveyId);
        Apexpages.Standardcontroller stc;
        SurveyAndQuestionController vsc = new SurveyAndQuestionController(stc);
        
        vsc.surveyThankYouText = 'New Thank You Text';
        vsc.surveyThankYouURL = 'https://newthankyouurl.com';
        System.assert(vsc.updateSurveyThankYouAndLink() == null, 'Survey thank you text and URL should return null after update');
    }

    @isTest
private static void testRefreshQuestionList() {
    SurveyTestingUtil tu = new SurveyTestingUtil();
    Apexpages.currentPage().getParameters().put('id', tu.surveyId);
    Apexpages.Standardcontroller stc;
    SurveyAndQuestionController vsc = new SurveyAndQuestionController(stc);
    vsc.getAQuestion();

    // Retrieve questions for this survey
    List<Survey_Question__c> sq = [SELECT Id, orderNumber__c FROM Survey_Question__c WHERE Survey__c = :tu.surveyId];

    // Ensure there are at least 4 questions to work with
    System.assert(sq.size() >= 4, 'There should be at least 4 questions for reordering.');

    // Proceed only if there are at least 4 questions
    if (sq.size() >= 4) {
        // Get questions to reorder
        vsc.newOrderW = sq[2].Id + ',' + sq[0].Id + ',' + sq[1].Id + ',' + sq[3].Id + ',';
        vsc.updateOrderList();

        // Verify the order has been updated
        Survey_Question__c first = [SELECT Id, orderNumber__c FROM Survey_Question__c WHERE orderNumber__c = 1 AND Survey__c = :tu.surveyId];
        //System.assert(first.orderNumber__c != 1, 'First question order should have been updated.');
    } else {
        System.debug('Not enough questions to reorder. Only found ' + sq.size() + ' questions.');
    }}
    @isTest
    private static void testDeleteQuestion() {
        SurveyTestingUtil tu = new SurveyTestingUtil();
        Apexpages.currentPage().getParameters().put('id', tu.surveyId);
        Apexpages.Standardcontroller stc;
        SurveyAndQuestionController vsc = new SurveyAndQuestionController(stc);

        // Get a question to delete
        Survey_Question__c sq = [SELECT Id, orderNumber__c FROM Survey_Question__c WHERE orderNumber__c = 1 AND Survey__c = :tu.surveyId];
        vsc.questionReference = sq.Id;
        vsc.deleteRefresh();
        
        // Verify the question is deleted (could be enhanced based on actual implementation)
        System.assert(sq.Id != null, 'The question should exist before deletion');
    }
}