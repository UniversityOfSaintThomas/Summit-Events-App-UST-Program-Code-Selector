/**
 * Created by Thaddaeus Dahlberg, Software Engineer, University of St. Thomas on 3/27/2023.
 */


public with sharing class SummitEventsUSTProgramLookup {

    @AuraEnabled(Cacheable=true)
    public static Map<Id, Account> getStThomasSchools() {
        Map<Id, Account> schoolMapId = new Map<Id, Account>([
                SELECT Id, Banner_Code__c, Name
                FROM Account
                WHERE RecordType.DeveloperName = 'University_Department'
                AND Banner_Key__c LIKE 'STVCOLL-%'
                AND Name != 'other'
                AND (NOT Name LIKE 'Not %')
                ORDER BY Name
        ]);
        return schoolMapId;
    }

    @AuraEnabled(Cacheable=true)
    public static Map<Id, Program__c> getPrograms(String school_name, String programs_selected) {
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
        if (school_name.equalsIgnoreCase('Undergraduate') || school_name.equalsIgnoreCase('Dougherty Family College')  || school_name.equalsIgnoreCase('No College Designated')) {
            query_string += ' AND (Academic_Level__c = \'Undergraduate\' OR Academic_Level__c = \'U\') ';
            query_string += ' AND (Program_Type__c INCLUDES (\'Major\') OR Program_Type__c INCLUDES (\'Pre-Professional\') OR Program_Major_Concentration__c IN :programListCodes) ';
        } else {
            query_string += ' AND (Academic_Level__c = \'Graduate\' OR Academic_Level__c = \'G\')  ';
                query_string += ' AND ( Associated_Schools__c INCLUDES (\'' + school_name + '\') OR Program_Major_Concentration__c IN :programListCodes ) ';
            if (school_name == 'School of Law') {
                query_string += ' AND Banner_Program_Code__c LIKE \'LW_%\'';
            }
        }
        query_string += ' ORDER BY Program_Name_on_Application__c';

        List<Program__c> programs = Database.query(query_string);
        return new Map<Id, Program__c>(programs);

    }

}