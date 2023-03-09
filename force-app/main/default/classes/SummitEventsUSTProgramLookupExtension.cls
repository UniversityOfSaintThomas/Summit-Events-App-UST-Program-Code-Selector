/**
 * Created by Thaddaeus Dahlberg, Software Engineer, University of St. Thomas on 3/8/2023.
 */


public with sharing class SummitEventsUSTProgramLookupExtension {


    public summit__Summit_Events__c USTEvt;
    public List<SelectOption> SelectedPrograms { get; set; }
    public String selectedProgramsString { get; set; }
    public String selectedSchoolId { get; set; }
    public String selectedSchoolName { get; set; }
    public List<SelectOption> Programs { get; set; }

    public SummitEventsUSTProgramLookupExtension(ApexPages.StandardController stdController) {
        USTEvt = (summit__Summit_Events__c) stdController.getRecord();
        //currentSelectedPrograms();
        //Programs = allPrograms(USTEvt.summit__Account__c, USTEvt.summit__Account__c.Name);
    }

    /*public void refreshPrograms() {
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
            List<Account> selectedProgramList = [
                    SELECT Prog_Major_Conc_Code__c, Major_Display_Name__c
                    FROM Program__c
                    WHERE Status__c = 'Active'
                    AND Prog_Major_Conc_Code__c IN :bigProgramArray
                    ORDER BY Major_Display_Name__c
            ];

            //Sort like they were initially selected
            List<Major__c> majorIdListSort = new List<Major__c>();
            for (String code : bigProgramArray) {
                for (Major__c mj : selectedProgramList) {
                    if (mj.Prog_Major_Conc_Code__c.equals(code)) {
                        majorIdListSort.add(mj);
                    }
                }
            }
            selectedProgramList = majorIdListSort;

            String programName = '';
            for (Major__c program : selectedProgramList) {
                programName = formattedProgramName(program.Major_Display_Name__c, program.Prog_Major_Conc_Code__c);
                if (String.isNotEmpty(programName)) {
                    selectedPrograms.add(new SelectOption(programName, programName));
                }
            }
        }

    }*/

}