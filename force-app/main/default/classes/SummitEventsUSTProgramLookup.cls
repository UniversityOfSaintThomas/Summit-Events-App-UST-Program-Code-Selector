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
                AND (NOT Name LIKE 'No %')
                AND (NOT Name LIKE 'Not %')
                ORDER BY Name
        ]);
        return schoolMapId;
    }

    @AuraEnabled(Cacheable=true)
    public static Map<Id, Program__c> getPrograms(String school_name) {
        Map<Id, Program__c> programs = new Map<Id, Program__c>([
                SELECT Id, Name, Program_Name_on_Application__c, Student_Type__c, Degree__c, Program_Major_Concentration__c, Associated_Schools__c
                FROM Program__c
                WHERE RecordType.DeveloperName = 'Recruitment_Program'
                AND Program_Display__c INCLUDES ('RFI')
                AND Associated_Schools__c INCLUDES (:school_name)
                AND Active__c = TRUE
        ]);
        return programs;
    }

    @AuraEnabled(Cacheable=true)
    public static Map<Id, Program__c> getSelectedPrograms(String programs_selected) {
        List<String> programListCodes = programs_selected.split(';');
        Map<Id, Program__c> programs = new Map<Id, Program__c>([
                SELECT Id, Name, Program_Name_on_Application__c, Student_Type__c, Degree__c, Program_Major_Concentration__c, Associated_Schools__c
                FROM Program__c
                WHERE RecordType.DeveloperName = 'Recruitment_Program'
                AND Program_Display__c INCLUDES ('RFI')
                AND Program_Major_Concentration__c IN :programListCodes
                AND Active__c = TRUE
        ]);
        return programs;
    }

}