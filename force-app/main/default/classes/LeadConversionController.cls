public class LeadConversionController {

    @InvocableMethod(label='Convert Lead' description='Converts a Lead to an Account, Contact, and Opportunity based on the provided inputs.')
    public static void convertLead(List<LeadConversionRequest> requests) {
        for (LeadConversionRequest request : requests) {
            try {
                // Debug input values
                System.debug('Input Values: ' + request);

                // Validate Lead ID
                if (String.isEmpty(request.leadId) || !isValidId(request.leadId)) {
                    throw new StringException('Invalid Lead ID: ' + request.leadId);
                }

                // Retrieve Lead for conversion
                Lead leadToConvert = [
                    SELECT Id, Status
                    FROM Lead
                    WHERE Id = :request.leadId AND IsConverted = false
                    LIMIT 1
                ];

                if (leadToConvert == null) {
                    throw new StringException('No eligible lead found for conversion.');
                }

                // Retrieve the converted status
                String convertedStatus = [
                    SELECT MasterLabel 
                    FROM LeadStatus 
                    WHERE IsConverted = true 
                    LIMIT 1
                ].MasterLabel;

                // Create LeadConvert object
                Database.LeadConvert leadConvert = new Database.LeadConvert();
                leadConvert.setLeadId(leadToConvert.Id);
                leadConvert.setConvertedStatus(convertedStatus);
                leadConvert.setDoNotCreateOpportunity(request.doNotCreateOpportunity);

                // Validate and set Account and Contact IDs
                if (!String.isEmpty(request.accountId) && isValidId(request.accountId)) {
                    leadConvert.setAccountId(request.accountId);
                }

                if (!String.isEmpty(request.contactId) && isValidId(request.contactId)) {
                    leadConvert.setContactId(request.contactId);
                }

                // Handle Opportunity ID
                if (!request.doNotCreateOpportunity) {
                    System.debug('Processing Opportunity ID...');
                    if (String.isEmpty(request.opportunityId) || !isValidId(request.opportunityId)) {
                        throw new StringException('Invalid or missing Opportunity ID when Do Not Create Opportunity is false.');
                    }

                    // Check if the Opportunity is linked to an Account
                    Opportunity opp = [
                        SELECT Id, AccountId, ContactId 
                        FROM Opportunity 
                        WHERE Id = :request.opportunityId 
                        LIMIT 1
                    ];

                    // If Opportunity doesn't have an Account, associate it with the provided Account
                    if (opp.AccountId == null && !String.isEmpty(request.accountId) && isValidId(request.accountId)) {
                        opp.AccountId = request.accountId;
                        update opp; // Update the Opportunity with the new AccountId
                        System.debug('Opportunity has been associated with Account: ' + request.accountId);
                    } else if (opp.AccountId != request.accountId) {
                        // If the Opportunity is linked to another Account, link it to the selected Account
                        opp.AccountId = request.accountId;
                        update opp;
                        System.debug('Opportunity updated with Account: ' + request.accountId);
                    }

                    // If Opportunity already has a Contact, do not change it but also link the selected Contact
                    if (!String.isEmpty(request.contactId) && opp.ContactId != request.contactId) {
                        // Add the selected Contact to the Opportunity (assuming a custom junction object or similar relation)
                        OpportunityContactRole oppContactRole = new OpportunityContactRole(
                            OpportunityId = opp.Id,
                            ContactId = request.contactId,
                            Role = 'Decision Maker'  // You can adjust the Role as needed
                        );
                        insert oppContactRole;
                        System.debug('Selected Contact linked to Opportunity: ' + request.contactId);
                    }

                    leadConvert.setOpportunityId(request.opportunityId);
                } else {
                    System.debug('Skipping Opportunity ID as Do Not Create Opportunity is true.');
                    leadConvert.setOpportunityId(null); // Explicitly set to null
                }

                // Perform Lead Conversion
                Database.LeadConvertResult result = Database.convertLead(leadConvert);

                if (!result.isSuccess()) {
                    throw new StringException('Lead conversion failed: ' + result.getErrors());
                }
                System.debug('Lead converted successfully: ' + leadToConvert.Id);

            } catch (Exception e) {
                System.debug('Error in Lead Conversion: ' + e.getMessage());
                //throw new AuraHandledException('Error: ' + e.getMessage()); // For screen flows, return a readable error.
            }
        }
    }

    // Utility method to validate Salesforce IDs
    private static Boolean isValidId(String id) {
        // ID must be non-null and 15 or 18 characters long
        return id != null && (id.length() == 15 || id.length() == 18);
    }

    // Input object for the flow
    public class LeadConversionRequest {
        @InvocableVariable(label='Lead Id' description='The Id of the Lead to convert.')
        public Id leadId;

        @InvocableVariable(label='Do Not Create Opportunity' description='Flag to indicate whether to create an Opportunity or not.')
        public Boolean doNotCreateOpportunity;

        @InvocableVariable(label='Account Id' description='The Account Id to associate with the converted Lead.')
        public Id accountId;

        @InvocableVariable(label='Contact Id' description='The Contact Id to associate with the converted Lead.')
        public Id contactId;

        @InvocableVariable(label='Opportunity Id' description='The Opportunity Id to associate with the converted Lead (used only if Do Not Create Opportunity is false).')
        public Id opportunityId;
    }
}