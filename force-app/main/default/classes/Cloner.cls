/*
    Developer:  Jim Hyland <jon@shippconsulting.com>
    
    Description:
       Generic Cloner class
*/
public without sharing class Cloner {

    /* Variables */
    
    private String cloneQuery;
    private Schema.DescribeSObjectResult sobjectType;
    private List<SubstitutionRule> substitutionRules 
        = new List<SubstitutionRule>();

    /* Constructor */
    
    public Cloner(Schema.DescribeSObjectResult sobjectType) {
        this.sobjectType = sobjectType;
    }
    
    /* Instance Methods */

    // substitute value for specified field
    public void addSubstitutionRule(String fieldName, String newValue) {
        substitutionRules.add(new SubstitutionRule(fieldName, newValue));
    }

    // clone a list of objects
    public Map<Id, SObject> doClone(Set<Id> sourceObjectIds) {
        Map<Id, SObject> cloneBySourceIdMap = new Map<Id, SObject>();
    
        // initial clone
        for(SObject sourceObject : Database.query(buildCloneQuery())) {
            cloneBySourceIdMap.put(sourceObject.id, 
                                   sourceObject.clone(false, true));
        }
    
        // process substitution rules
        for(SObject sourceObject : cloneBySourceIdMap.values()) {
            for(SubstitutionRule substitutionRule : substitutionRules) {
                sourceObject.put(substitutionRule.fieldName, 
                                 substitutionRule.newValue);        
            }   
        }
        return cloneBySourceIdMap;
    }

    // clone a single object
    public SObject doClone(Id sourceObjectId) {
        Set<Id> sourceObjectIds = new Set<Id>();
        sourceObjectIds.add(sourceObjectId);
        Map<Id,SObject> cloneBySourceIdMap = doClone(sourceObjectIds);
        return cloneBySourceIdMap.values().get(0);
    }

    // returns query string of creatable fields
    private String buildCloneQuery() {
        if(null == cloneQuery) {
            cloneQuery = 'select id, ';
            for(String fieldName : 
                    getCreateableFieldNamesForSObject(sobjectType)) {
                cloneQuery += fieldName + ', ';
            }
            cloneQuery = cloneQuery.subString(0, cloneQuery.length() - 2);
            cloneQuery += ' from ' + sobjectType.getName() 
                + ' where id in :sourceObjectIds';
        }
        return cloneQuery;
    }

    // returns field names of creatable fields
    private List<String> getCreateableFieldNamesForSObject(
            Schema.DescribeSObjectResult s) {
        Map<String, Schema.SObjectField> objectFields = s.fields.getMap();
        List<String> createableFieldNames = new List<String>();
    
        for (String fieldName : objectFields.keySet())  {
            // skip opportunityLineItem totalPrice to avoid a field integrity
            // exception when both unitPrice and totalPrice are specified
            if(!(sobjectType == Schema.SObjectType.OpportunityLineItem 
                    && fieldName.equalsIgnoreCase('totalPrice')) 
                    && objectFields.get(fieldName).getDescribe().isCreateable())
                createableFieldNames.add(fieldName);
        }
        return createableFieldNames;
    }

    /* Inner Class */

    // associate field with new value
    private class SubstitutionRule {
        public String fieldName { get; set; }
        public String newValue { get; set; }
    
        public SubstitutionRule(String fieldName, String newValue) {
            this.fieldName = fieldName;
            this.newValue = newValue;
        }
    }
}