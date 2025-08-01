/* Controller associated with pages rendering the survey.
* Used by SurveyPage, ResultsPage, TakeSurvey
*/
global virtual with sharing class ViewSurveyController {
    public String  qQuestion                      {get; set;}
    public Boolean qRequired                      {get; set;}
    public String  qChoices                       {get; set;}
    public String surveyName                        {get; set;}
    public String surveyHeader                {get; set;}
    public String surveyId                          {get;
        set{
            this.surveyId = value;
            init();
        }
    }
    public String renderSurveyPreview           {get; set;}
    public String questionName                    {get; set;}
    public String questionType                    {get; set;}
    public Boolean questionRequired             {get; set;}
    public List<SelectOption> singleOptions   {get; set;}
    public List<SFQuestion> allQuestions        {get; set;}
    public List<String> responses                   {get; set;}
    public Integer allQuestionsSize               {get; set;}
    //public String  templateURL                {get; set;}
    public String  surveyThankYouText         {get; set;}
    public String surveyContainerCss {get; set;}
    public String  surveyThankYouURL          {get; set;}
    public String  caseId                     {get; set;}
    public String contactId {get;set;}
    public String anonymousAnswer {get;set;}
    public List<SelectOption> anonymousOrUser {get;set;}
    public Boolean isInternal {get;set;}
    public String baseURL {get;set;}

    public String userId{get;set;}
    public String userName{get;set;}
    public String surveyTakerId {get;set;}
    public Boolean thankYouRendered{get;set;}
    public List<String> newOrder {get;set;}
    private Survey__c mySurvey;

    /* Retrieves the list of questions, the survey name, after retrieving the
    necessary parameters from the url.
    */
    //------------------------------------------------------------------------------//
    public ViewSurveyController(ApexPages.StandardController stdController) {
        // Get url parameters
        mySurvey = (Survey__c)stdController.getRecord();

        surveyId = Apexpages.currentPage().getParameters().get('id');
        caseId   = Apexpages.currentPage().getParameters().get('caId');
        contactId = Apexpages.currentPage().getParameters().get('cId');

        if(caseId == null || caseId.length()<15){
            caseId = 'none';
        }
        if(contactId == null || contactId.length()<15){
            contactId = 'none';
        }
        surveyId = String.escapeSingleQuotes(surveyId);
        caseId = String.escapeSingleQuotes(caseId);
        contactId = String.escapeSingleQuotes(contactId);
        // By default the preview is not showing up
        renderSurveyPreview = 'false';

        init();
    }

    public ViewSurveyController(ViewShareSurveyComponentController controller)
    {
        surveyId = Apexpages.currentPage().getParameters().get('id');
        mySurvey = [SELECT Id, Thank_You_Link__c FROM Survey__c WHERE Id = :surveyId WITH SECURITY_ENFORCED LIMIT 1];

        caseId   = Apexpages.currentPage().getParameters().get('caId');
        contactId = Apexpages.currentPage().getParameters().get('cId');
        if(caseId == null || caseId.length()<15){
            caseId = 'none';
        }
        if(contactId == null || contactId.length()<15){
            contactId = 'none';
        }
        surveyId = String.escapeSingleQuotes(surveyId);
        caseId = String.escapeSingleQuotes(caseId);
        contactId = String.escapeSingleQuotes(contactId);
        // By default the preview is not showing up
        renderSurveyPreview = 'false';
        init();
    }


    public void init()
    {
        if (surveyId != null){
            // Retrieve all necessary information to be displayed on the page
            allQuestions = new List<SFQuestion>();
            setupQuestionList();
            setSurveyNameAndThankYou(surveyId);
            anonymousOrUser = new List<SelectOption>();
            anonymousOrUser.add(new SelectOption('Anonymous', System.Label.LABS_SF_Anonymous));
            anonymousOrUser.add(new SelectOption('User','User ' + UserInfo.getFirstName() + ' ' + UserInfo.getLastName()));
            anonymousAnswer =  (userInfo.getUserType() == 'Guest')?'Anonymous':'';
            isInternal = (userInfo.getUserType() == 'Guest') ? false : true;
            newOrder = new List<String>();
            String urlBase = URL.getSalesforceBaseUrl().toExternalForm();
            baseURL = urlBase;

            userId = UserInfo.getUserId();
            userName = UserInfo.getName();

            thankYouRendered=false;


        }
    }





    //----------------------------------------------------------------------------//

    /* Called during the setup of the page.
    Retrieve questions and responses from DB and inserts them in 2 lists. */
    public Integer setupQuestionList(){

        getAQuestion();
        return allQuestions.size();
    }


    /** Sets the survey name variable
    *  param: sID   The survey ID as specified in the DB
    */
    public void setSurveyNameAndThankYou(String sId){
        mysurvey = new Survey__c();
        try {
            List<Schema.SobjectField> fields = new List<Schema.SobjectField>{
                Schema.Survey__c.fields.Thank_You_Text__c,
                Schema.Survey__c.fields.Thank_You_Text__c,Schema.Survey__c.fields.Thank_You_Link__c,
                Schema.Survey__c.fields.Survey_Header__c,Schema.Survey__c.fields.Survey_Container_CSS__c
            };
            SurveyForceUtil.AccessController.assertAuthorizedToView(Schema.Survey__c.getSobjectType(), fields);
            mysurvey = [SELECT Name, Id, Thank_You_Text__c, Thank_You_Link__c, Survey_Header__c, Survey_Container_CSS__c FROM Survey__c WHERE Id =:sId];
            surveyName = mysurvey.Name;
            surveyHeader = mysurvey.Survey_Header__c;
            surveyThankYouText = mysurvey.Thank_You_Text__c;
            if (surveyThankYouText == null) {
                surveyThankYouText = System.Label.LABS_SF_Survey_Submitted_Thank_you;
            }
            surveyThankYouURL = mysurvey.Thank_You_Link__c;
            surveyContainerCss = mysurvey.Survey_Container_CSS__c;
        } catch (SFDCAccessControlException e){
            SurveyForceUtil.log('ViewSurveyController:setSurveyNameAndThankYou():SFDCAccessControlException' + e.getMessage());
        } catch (Exception e){
            SurveyForceUtil.log('ViewSurveyController:setSurveyNameAndThankYou():Exception:' + e.getMessage());
            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Survey not found: Maybe check user permission to this record'));
        }

    }

    //------------------------------------------------------------------------------//
    public Pagereference updateSurveyName(){
        mysurvey = new Survey__c();
        try{
            List<Schema.SobjectField> fields = new List<Schema.SobjectField>{
                Schema.Survey__c.fields.Thank_You_Link__c,
                Schema.Survey__c.fields.Thank_You_Text__c
            };
            SurveyForceUtil.AccessController.assertAuthorizedToUpdate(Schema.Survey__c.getSobjectType(), fields);

            mysurvey = [SELECT Name, Id, Thank_You_Text__c, Thank_You_Link__c FROM Survey__c WHERE Id =:surveyId];
            mysurvey.Name = surveyName;
            update mysurvey;
        }catch(SFDCAccessControlException e){ SurveyForceUtil.log('ViewSurveyController:updateSurveyName():SFDCAccessControlException' + e.getMessage());
    }catch(Exception e){Apexpages.addMessages(e);}
    return null;
}

//------------------------------------------------------------------------------//
public Pagereference updateSurveyThankYouAndLink(){
    mysurvey = new Survey__c();
    try{
        List<Schema.SobjectField> fields = new List<Schema.SobjectField>{
            Schema.Survey__c.fields.Thank_You_Link__c,
            Schema.Survey__c.fields.Thank_You_Text__c
        };
        SurveyForceUtil.AccessController.assertAuthorizedToUpdate(Schema.Survey__c.getSobjectType(), fields);

        mysurvey = [SELECT Name, Id, Thank_You_Text__c, Thank_You_Link__c FROM Survey__c WHERE Id =:surveyId];
        mysurvey.Thank_You_Text__c = surveyThankYouText;
        mysurvey.Thank_You_Link__c = surveyThankYouURL;

        update mysurvey;
    }catch(SFDCAccessControlException e){ SurveyForceUtil.log('ViewSurveyController:updateSurveyThankYouAndLink():SFDCAccessControlException' + e.getMessage());
}catch(Exception e){Apexpages.addMessages(e);}

return null;
}

//------------------------------------------------------------------------------//
/** When requested from the page - when the user clicks on 'Update Order' -
this function will reorganize the list so that it is displayed in the new order
*/
public Pagereference refreshQuestionList(){
    setupQuestionList();
    return null;
}



//------------------------------------------------------------------------------//

/**
*/
public List<String> getResponses() {
    List<SurveyQuestionResponse__c> qr = [SELECT Survey_Question__c, SurveyTaker__c, Response__c, Name From SurveyQuestionResponse__c limit 100];
    List<String> resp = new List<String>();
    for (SurveyQuestionResponse__c r : qr) {
        resp.add(r.Response__c);
    }

    return resp;
}



/** Fills up the List of questions to be displayed on the Visualforce page
*/
public List<SFQuestion> getAQuestion() {
    qQuestion = '';
    qChoices ='';
    List<Schema.SobjectField> fields = new List<Schema.SobjectField>{
        Schema.Survey_Question__c.fields.Type__c,Schema.Survey_Question__c.fields.Survey__c,
        Schema.Survey_Question__c.fields.Required__c,Schema.Survey_Question__c.fields.Question__c,
        Schema.Survey_Question__c.fields.OrderNumber__c,Schema.Survey_Question__c.fields.Choices__c
    };
    SurveyForceUtil.AccessController.assertAuthorizedToView(Schema.Survey_Question__c.getSobjectType(), fields);
    List<Survey_Question__c> allQuestionsObject =
    [SELECT Type__c, Id, Survey__c, Required__c, Question__c,
    OrderNumber__c, Name, Choices__c, Related_Question__c
    From Survey_Question__c
    WHERE Survey__c =: surveyId ORDER BY OrderNumber__c];
    allQuestions = new List<SFQuestion>();

    Double old_OrderNumber = 0;
    Double new_OrderNumber;
    Double difference = 0;
    /* Make sure that the order number follow each other (after deleting a question, orders might not do so) */
    for (Survey_Question__c q : allQuestionsObject){
        new_OrderNumber = q.OrderNumber__c;
        difference = new_OrderNumber - old_OrderNumber - 1;
        if (difference > 0) {
            Double dd = double.valueOf(difference);
            Integer newOrderInt = dd.intValue();
            q.OrderNumber__c -= Integer.valueOf(newOrderInt);
        }
        old_OrderNumber = q.OrderNumber__c;
        SFQuestion theQ = new SFQuestion(q);
        allQuestions.add(theQ);
    }
    allQuestionsSize = allQuestions.size();
    return allQuestions;
}

public PageReference submitResults()
{
    System.debug('anonymousAnswer::' + anonymousAnswer );

    Map<Id, SFQuestion> questionIdtoQuestion = new Map<Id, SFQuestion>();
    Map<Id, Id> questionIdtoRelatedQuestionId = new Map<Id, Id>();

    List <SurveyQuestionResponse__c> sqrList = new List<SurveyQuestionResponse__c>();
    try {

        List<Schema.SobjectField> fields = new List<Schema.SobjectField>{
            Schema.SurveyQuestionResponse__c.fields.Response__c,Schema.SurveyQuestionResponse__c.fields.Survey_Question__c,
            Schema.SurveyQuestionResponse__c.fields.SurveyTaker__c
        };
        SurveyForceUtil.AccessController.assertAuthorizedToCreate(Schema.SurveyQuestionResponse__c.getSobjectType(), fields);

        for (SFQuestion q : allQuestions) {
            SurveyQuestionResponse__c sqr = new SurveyQuestionResponse__c();
            if(!String.isBlank(q.relatedQuestion)) {
                questionIdtoQuestion.put(q.id, q);
                questionIdtoRelatedQuestionId.put(q.Id, q.relatedQuestion);
            }
            if (q.renderSelectRadio == 'true') {

                if (q.required && (q.selectedOption == null || q.selectedOption == '')) {
                    Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please fill out all required fields'));
                    return null;
                }

                if (q.selectedOption == null || q.selectedOption == '') {
                    sqr.Response__c = '';
                } else {
                    sqr.Response__c = q.singleOptions.get(Integer.valueOf(q.selectedOption)).getLabel();
                }
                sqr.Survey_Question__c = q.Id;
                sqrList.add(sqr);
            } else if (q.renderFreeText == 'true') {
                if (q.required && q.choices == '') {
                    Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please fill out all required fields'));
                    return null;
                }

                sqr.Response__c = q.choices;
                sqr.Survey_Question__c = q.Id;
                sqrList.add(sqr);
            } else if (q.renderSelectCheckboxes == 'true') {
                if (q.required && (q.selectedOptions == null || q.selectedOptions.size() == 0)) {
                    Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please fill out all required fields'));
                    return null;
                }

                for (String opt : q.selectedOptions) {
                    sqr = new SurveyQuestionResponse__c();
                    if (opt == '' || opt == null) {
                        sqr.Response__c = '';
                    } else {
                        sqr.Response__c = q.multiOptions.get(Integer.valueOf(opt)).getLabel();
                    }
                    sqr.Survey_Question__c = q.Id;
                    sqrList.add(sqr);
                }
            } else if (q.renderSelectRow == 'true') {
                if (q.required && (q.selectedOption == null || q.selectedOption == '')) {
                    Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please fill out all required fields'));
                    return null;
                }

                if (q.selectedOption == null || q.selectedOption == '') {
                    sqr.Response__c = '';
                } else {
                    sqr.Response__c = q.rowOptions.get(Integer.valueOf(q.selectedOption)).getLabel();
                }
                sqr.Survey_Question__c = q.Id;
                sqrList.add(sqr);
            }
        }

        Map<Id, SurveyQuestionResponse__c> questionIdToResponse = new Map<Id, SurveyQuestionResponse__c>();
        List<SurveyQuestionResponse__c> responsesToInsert = new List<SurveyQuestionResponse__c>();
        if(!questionIdtoQuestion.isEmpty()) {
            for (SurveyQuestionResponse__c sqr : sqrList)
            {
                questionIdToResponse.put(sqr.Survey_Question__c, sqr);                
            }

            for (SurveyQuestionResponse__c sqr : sqrList)
            {
                if(questionIdtoRelatedQuestionId.containsKey(sqr.Survey_Question__c) && questionIdToResponse.containsKey(questionIdtoRelatedQuestionId.get(sqr.Survey_Question__c))) {
                    sqr.Related_Question_Response_Value__c = questionIdToResponse.get(questionIdtoRelatedQuestionId.get(sqr.Survey_Question__c)).Response__c;
                }
            }
        }

        if(AddSurveyTaker())
        {
            for (SurveyQuestionResponse__c sqr : sqrList)
            {
                sqr.SurveyTaker__c = surveyTakerId;
            }
            System.debug('responsesToInsert: ' + responsesToInsert);
            ViewSurveyControllerWithoutSharing.createSurveyQuestionResponse(sqrList);
            thankYouRendered = true;
        }
    }catch(SFDCAccessControlException e){ SurveyForceUtil.log('ViewSurveyController:submitResults():SFDCAccessControlException' + e.getMessage()); Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Some error occured while saving response'));
    }catch(Exception e){ if(isInternal) { SurveyForceUtil.log(e.getMessage()); Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Some error occured while saving response'));            }
    }

    if(mysurvey.Thank_You_Link__c != null && mysurvey.Thank_You_Link__c != 'Undefined' && !String.isBlank(mysurvey.Thank_You_Link__c)){
        Pagereference pr = new Pagereference(mysurvey.Thank_You_Link__c);
        return pr;
    } else {
        return null;
    }
}


private Boolean AddSurveyTaker()
{
    Boolean retVal = false;
    String userId;

    if (surveyId == null) { return false;        }
    if(caseId!= null && (caseId.toUpperCase() == 'NONE'|| caseId.length()<15)){
        caseId = null;
    }
    if(contactId != null && (contactId.toUpperCase() == 'NONE'|| contactId.length()<15)){
        contactId = null;
    }
    if (anonymousAnswer != 'Anonymous'){ userId = UserInfo.getUserId(); }  else{ userId = null; }


    SurveyTaker__c st = new SurveyTaker__c();

    try {
        List<Schema.SobjectField> fields = new List<Schema.SobjectField>{
            Schema.SurveyTaker__c.fields.Survey__c, Schema.SurveyTaker__c.fields.Taken__c, Schema.SurveyTaker__c.fields.User__c
        };
        SurveyForceUtil.AccessController.assertAuthorizedToView(Schema.SurveyTaker__c.getSobjectType(), fields);

        SurveyForceUtil.AccessController.assertAuthorizedToCreate(Schema.SurveyTaker__c.getSobjectType(), fields);

        if(anonymousAnswer != 'Anonymous')
        {
            //If survey is taken by Contact OR Case already then no need to take it again
            List<SurveyTaker__c> check = [SELECT Contact__c, Survey__c, Case__c, User__c From SurveyTaker__c Where Survey__c=:surveyId and
            ((Contact__c != null and Contact__c=:contactId) or (Case__c!= null and Case__c = :caseId)
            or (User__c!= null and User__c = :userId))];
            if(check != null && check.size()>0){
                Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.LABS_SF_You_have_already_taken_this_survey));

                return false;
            }
        }

        st.Contact__c  = (contactId == null)?null: String.escapeSingleQuotes(contactId);
        st.Survey__c = surveyId;
        st.Taken__c = 'true';
        st.Case__c = (caseId == null)?null: String.escapeSingleQuotes(caseId);
        st.User__c = userId;

        //insert st;
        ViewSurveyControllerWithoutSharing.createSurveyTaken(st);
        surveyTakerId = st.Id;
        retVal = true;
    }catch(SFDCAccessControlException e){ SurveyForceUtil.log('ViewSurveyController:AddSurveyTaker():SFDCAccessControlException' + e.getMessage());
}catch(Exception e){Apexpages.addMessages(e);}
return retVal;
}


}