/*
*********************************************************
*   Apex Class Name    : CheckBusinessHours
*   Created Date       : July 24, 2024
*   @description       : Business hours checking like in business & non business hours.
*
*   @author            : CoreFlex
*/

global class CheckBusinessHours {
    
    /*
    *********************************************************
    @description    : method to is used to check business hours
    @param          : String business hours id
    @return         : Boolean
    ********************************************************
    */
	global static Boolean checkBusinessHoursById(String businessHoursId)
    {
		Boolean isWithin = false;
		if (businessHoursId != null)
		{		
		    isWithin = BusinessHours.isWithin(businessHoursId, System.now());
		}

		return isWithin;
    }

    /*
    *********************************************************
    @description    : Invocable method to is used to call from bot
    @param          : List String business hours name
    @return         : Boolean
    ********************************************************
    */
    @InvocableMethod(label='Check Now is within Business Hours by Name')
	global static List<Boolean> checkBusinessHoursByName(List<String> businessHoursName)
    {
		List<Boolean> results = new List<Boolean>();
        try {
            for(String name : businessHoursName) {
                // Look up the Business hours by name to find the ID
                List<BusinessHours> businessHours = [SELECT Id FROM BusinessHours where Name =:name AND IsActive = true];
                if (businessHours.size() == 1) {
                    // Call method to check if now is within business hours based on the found hours
                    results.add(CheckBusinessHours.checkBusinessHoursById(businessHours[0].Id));
                }
                else
                {
                    // If name didn't match an active business hours then return false.
                    results.add(false);
                }
            }
            
        } catch(Exception e) {
            // Call method of fault mail service class
            String faultMail =  FaultMailService.callFaultMailFlow('CheckBusinessHours Apex class error', 'Error: ' + e.getMessage(), 'checkBusinessHoursByName method');
			System.debug(faultMail);

            System.debug('Exception is : ' + e.getMessage());
            results.add(false);
        }
		return results;
    }

}