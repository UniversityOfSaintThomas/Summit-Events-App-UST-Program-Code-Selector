/**
 * Created by Thaddaeus Dahlberg, Software Engineer, University of St. Thomas on 3/27/2023.
 */


public with sharing class SummitEventsUSTProgramLookup {

    @AuraEnabled(Cacheable=true)
    public static Map<Id, Account> getStThomasSchools() {
        // This method is used to create the school picklist at the top of the LWC
        // Schools are all accounts
        Map<Id, Account> schoolMapId = new Map<Id, Account>([
                SELECT Id, Banner_Code__c, Name, School_College_Name__c
                FROM Account
                WHERE RecordType.DeveloperName = 'University_Department'
                AND Banner_Key__c LIKE 'STVCOLL-%'
                AND Name != 'other'
                AND (NOT Name LIKE 'Not %')
                AND School_College_Name__c != NULL
                ORDER BY Name
        ]);
        return schoolMapId;
    }

    @AuraEnabled(Cacheable=true)
    public static Map<Id, Program__c> getPrograms(String school_name, String programs_selected) {
        //This method is used to find schools related to the selected school account.
        // In order to preserve the previous selected schools we want to include those program codes in our query.
        List<String> programListCodes = programs_selected.unescapeHtml4().split(';');
        String query_string =
                'SELECT ' +
                        'Id, ' +
                        'Name, ' +
                        'Program_Name_on_Application__c, ' +
                        'Student_Type__c, ' +
                        'Degree__c, ' +
                        'Program_Major_Concentration__c ' +
                        'FROM Program__c ' +
                        'WHERE RecordType.DeveloperName = \'Recruitment_Program\' ' +
                        'AND Program_Display__c INCLUDES (\'RFI\') ' +
                        'AND Active__c = true';
        if (school_name.equalsIgnoreCase('Undergraduate') || school_name.equalsIgnoreCase('Dougherty Family College') || school_name.equalsIgnoreCase('No College Designated')) {
            query_string += ' AND (' +
                    'Program_Type__c INCLUDES (\'Major\') ' +
                    'OR Program_Type__c INCLUDES (\'Pre-Professional\') ' +
                    'OR Program_Type__c INCLUDES (\'Major Concentration\') ' +
                    'OR Program_Type__c INCLUDES (\'Co-Major\')' +
                    'OR Program_Major_Concentration__c IN :programListCodes) ';
        } else {
            query_string += ' AND ( Associated_Schools__c INCLUDES (\'' + school_name + '\') OR Program_Major_Concentration__c IN :programListCodes ) ';
        }
        query_string += ' ORDER BY Program_Name_on_Application__c';

        List<Program__c> programs = Database.query(query_string);
        return new Map<Id, Program__c>(programs);

    }

}