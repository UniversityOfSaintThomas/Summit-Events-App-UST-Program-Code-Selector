/**
 * Created by Thaddaeus Dahlberg, Software Engineer, University of St. Thomas on 4/3/2023.
 */


@IsTest
private class SummitEventsUSTProgramLookup_TEST {

    @TestSetup
    public static void setup() {
        List<Program__c> programs_to_insert = new List<Program__c>();
        Id recruitment_program_id = Schema.SObjectType.Program__c.getRecordTypeInfosByDeveloperName().get('Recruitment_Program').getRecordTypeId();
        Program__c program1 = new Program__c(
                Name = 'Sociology',
                RecordTypeId = recruitment_program_id,
                Active__c = true,
                Degree__c = 'Bachelor of Arts',
                Program_Display__c = 'RFI',
                Academic_Level__c = 'U',
                Associated_Schools__c = 'Undergraduate',
                Program_Type__c = 'Major'

        );

        programs_to_insert.add(program1);
        Program__c program2 = new Program__c(
                Name = 'JD',
                RecordTypeId = recruitment_program_id,
                Active__c = true,
                Degree__c = 'Juris Doctor',
                Program_Display__c = 'RFI',
                Academic_Level__c = 'G',
                Associated_Schools__c = 'School of Law',
                Banner_Program_Code__c = 'LW_JD',
                Major_Code__c = 'JD',
                Concentration_Code__c = 'JD2'
        );
        programs_to_insert.add(program2);
        insert programs_to_insert;

        List<Account> accounts_to_insert = new List<Account>();
        Id administrative_id = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('University_Department').getRecordTypeId();
        Account college_account1 = new Account(
                Name = 'School of Law',
                RecordTypeId = administrative_id,
                Banner_Key__c = 'STVCOLL-LAW'
        );
        accounts_to_insert.add(college_account1);
        Account college_account2 = new Account(
                Name = 'Undergraduate',
                RecordTypeId = administrative_id,
                Banner_Key__c = 'STVCOLL-UG'
        );
        accounts_to_insert.add(college_account2);
        insert accounts_to_insert;

    }

    @IsTest
    static void testSchoolLookup() {
        Map<Id, Account> schools = SummitEventsUSTProgramLookup.getStThomasSchools();
        Test.startTest();
        System.assertEquals(2, schools.size());
        Test.stopTest();
    }

    @IsTest
    static void testProgramLookup() {
        Map<Id, Program__C> program = SummitEventsUSTProgramLookup.getPrograms('School of Law', '');
        Map<Id, Program__C> program2 = SummitEventsUSTProgramLookup.getPrograms('Undergraduate', '');

        Test.startTest();
        System.assertEquals(1, program.size());
        System.assertEquals(1, program2.size());
        Test.stopTest();
    }
}