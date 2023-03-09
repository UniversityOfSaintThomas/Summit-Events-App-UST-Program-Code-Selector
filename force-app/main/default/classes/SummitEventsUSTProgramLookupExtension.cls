/**
 * Created by Thaddaeus Dahlberg, Software Engineer, University of St. Thomas on 3/8/2023.
 */


public with sharing class SummitEventsUSTProgramLookupExtension {


    public summit__Summit_Events__c summitEvent;
    public List<SelectOption> SelectedPrograms { get; set; }
    public String selectedProgramsString { get; set; }
    public String selectedSchoolId { get; set; }
    public String selectedSchoolName { get; set; }
    public List<SelectOption> Programs { get; set; }

    public SummitEventsUSTProgramLookupExtension(ApexPages.StandardController stdController) {
        summitEvent = (summit__Summit_Events__c) stdController.getRecord();
        currentSelectedPrograms();
        Programs = allPrograms(summitEvent.summit__Account__c, summitEvent.summit__Account__r.Name);
    }

    public void refreshPrograms() {
        updateProgramRecords(selectedProgramsString);
        currentSelectedPrograms();
        Programs = allPrograms(selectedSchoolId, selectedSchoolName);
    }

    public void currentSelectedPrograms() {
        String bigProgramList = concatenatedProgramFilter();
        List<String> bigProgramArray = new List<String>();
        SelectedPrograms = new List<SelectOption>();
        if (String.isNotBlank(bigProgramList)) {
            bigProgramArray = bigProgramList.split(';');
            List<Program__c> selectedProgramList = [
                    SELECT Program_Major_Concentration__c, Name
                    FROM Program__c
                    WHERE Active__c = TRUE
                    AND Program_Major_Concentration__c IN :bigProgramArray
                    ORDER BY Name
            ];

            //Sort like they were initially selected
            List<Program__c> majorIdListSort = new List<Program__c>();
            for (String code : bigProgramArray) {
                for (Program__c mj : selectedProgramList) {
                    if (mj.Program_Major_Concentration__c.equals(code)) {
                        majorIdListSort.add(mj);
                    }
                }
            }
            selectedProgramList = majorIdListSort;

            String programName = '';
            for (Program__c program : selectedProgramList) {
                programName = formattedProgramName(program.Name, program.Program_Major_Concentration__c);
                if (String.isNotEmpty(programName)) {
                    SelectedPrograms.add(new SelectOption(programName, programName));
                }
            }
        }

    }

    public String concatenatedProgramFilter() {
        String bigProgramList = '';
        if (String.isNotBlank(summitEvent.summit__Program_Filter__c)) {
            bigProgramList += summitEvent.summit__Program_Filter__c;
        }
        if (String.isNotBlank(summitEvent.summit__Program_Filter_2__c)) {
            bigProgramList += summitEvent.summit__Program_Filter_2__c;
        }
        if (String.isNotBlank(summitEvent.summit__Program_Filter_3__c)) {
            bigProgramList += summitEvent.summit__Program_Filter_3__c;
        }
        return bigProgramList;
    }

    public String formattedProgramName(String programName, String programCode) {
        return programName + ' (' + programCode + ')';
    }

    public List<SelectOption> allPrograms(String schoolId, String schoolName) {
        // Get a list of programs
        List<SelectOption> programs = new List<SelectOption>();
        List<Program__c> schoolPrograms = new List<Program__c>();
        if (String.isNotBlank(schoolId)) {
            if (String.isNotBlank(schoolName) && schoolName.equals('Undergraduate')) {
                schoolPrograms = [
                        SELECT Program_Major_Concentration__c, Name
                        FROM Program__c
                        WHERE Active__c = TRUE
                        AND Program_Major_Concentration__c != NULL
                        AND Name != 'Undeclared BA'
                        AND Name != 'Undecided'
                        AND Program_Display__c INCLUDES ('RFI')
                        ORDER BY Name
                ];
            } else {
                schoolPrograms = [
                        SELECT Program_Major_Concentration__c, Name, Associated_Schools__c
                        FROM Program__c
                        WHERE Active__c = TRUE
                        AND Program_Major_Concentration__c != NULL
                        AND Associated_Schools__c = :schoolId
                        AND Program_Display__c INCLUDES ('RFI')
                        ORDER BY Name
                ];
            }
        } else {
            schoolPrograms = [
                    SELECT Name, Program_Major_Concentration__c
                    FROM Program__c
                    WHERE Active__c = TRUE
                    AND Program_Major_Concentration__c != NULL
                    AND Program_Display__c INCLUDES ('RFI')
                    ORDER BY Name
            ];
        }
        for (Program__c program : schoolPrograms) {
            String programDisplay = formattedProgramName(program.Name, program.Program_Major_Concentration__c);
            String selectedProgramCodes = concatenatedProgramFilter();
            if (selectedProgramCodes.indexOf(program.Program_Major_Concentration__c) == -1) {
                programs.add(new SelectOption(programDisplay, programDisplay));
            }
        }
        return programs;
    }

    public void save() {
        String selectString = '';
        if (SelectedPrograms != null) {
            for (SelectOption p : SelectedPrograms) {
                selectString += p.getValue() + ';';
            }
            updateProgramRecords(selectString);
        }
    }

    private void updateProgramRecords(String selectString) {
        String programCodeString1 = '';
        String programCodeString2 = '';
        String programCodeString3 = '';
        if (!String.isBlank(selectString)) {
            Pattern TAG_REGEX = Pattern.compile('\\(([^\\)]+)\\)');
            Matcher matcher = TAG_REGEX.matcher(selectString);
            //loop through found hocks and add only unique
            String programCode = '';
            while (matcher.find()) {
                programCode = matcher.group(1);
                if (programCodeString1.length() + programCode.length() >= 255) {
                    if (programCodeString2.length() + programCode.length() >= 255) {
                        programCodeString3 += programCode + ';';
                    } else {
                        programCodeString2 += programCode + ';';
                    }
                } else {
                    programCodeString1 += programCode + ';';
                }
            }
        }
        summitEvent.summit__Program_Filter__c = programCodeString1;
        summitEvent.summit__Program_Filter_2__c = programCodeString2;
        summitEvent.summit__Program_Filter_3__c = programCodeString3;

        update summitEvent;
    }

    public List<SelectOption> getSchools() {
        List<Account> allSchools = [
                SELECT Id, Name
                FROM Account
                WHERE RecordType.Name = 'University Department' AND Inactive_School__c = FALSE AND Name != 'No College Designated'
                LIMIT 100
        ];
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('', '-- select -- '));
        for (Account school : allSchools) {
            options.add(new SelectOption(school.Id, school.Name));
        }
        return options;
    }

}