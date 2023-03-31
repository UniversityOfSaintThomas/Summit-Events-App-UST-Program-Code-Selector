/**
 * Created by Thaddaeus Dahlberg, Software Engineer, University of St. Thomas on 3/27/2023.
 */

import {LightningElement, api, track, wire} from 'lwc';
import {getRecord, getFieldValue} from 'lightning/uiRecordApi';
import {updateRecord} from "lightning/uiRecordApi";

import getStThomasSchools from '@salesforce/apex/SummitEventsUSTProgramLookup.getStThomasSchools';
import getPrograms from '@salesforce/apex/SummitEventsUSTProgramLookup.getPrograms';

import SEA_EVENT from '@salesforce/schema/summit__Summit_Events__c';
import SEA_ID from '@salesforce/schema/summit__Summit_Events__c.Id';
import SEA_ACCOUNT from '@salesforce/schema/summit__Summit_Events__c.summit__Account__c';
import SEA_PROGRAM1 from '@salesforce/schema/summit__Summit_Events__c.summit__Program_Filter__c';
import SEA_PROGRAM2 from '@salesforce/schema/summit__Summit_Events__c.summit__Program_Filter_2__c';
import SEA_PROGRAM3 from '@salesforce/schema/summit__Summit_Events__c.summit__Program_Filter_3__c';
import SEA_SCHOOL_BANNER_CODE from '@salesforce/schema/summit__Summit_Events__c.summit__Account__r.Banner_Code__c';
import SEA_SCHOOL_NAME from '@salesforce/schema/summit__Summit_Events__c.summit__Account__r.Name';
import SEA_PROGRAM_CODE from '@salesforce/schema/Program__c.Program_Major_Concentration__c';
import SEA_PROGRAM_NAME from '@salesforce/schema/Program__c.Program_Name_on_Application__c';

export default class SummitEventsUstProgramLookup extends LightningElement {
    @api recordId;
    @track st_thomas_school_picklist;
    @track st_thomas_school_picklist_value;
    @track st_thomas_program_picklist;
    @track st_thomas_program_picklist_value;
    @track school_name;
    seaEventRecord;
    school_banner_key_id = new Map();

    //Get the current page record
    @wire(getRecord, {
        recordId: '$recordId',
        fields: [
            SEA_ACCOUNT,
            SEA_PROGRAM1,
            SEA_PROGRAM2,
            SEA_PROGRAM3,
            SEA_SCHOOL_BANNER_CODE,
            SEA_SCHOOL_NAME
        ]
    })
    wiredRecord({data, error}) {
        if (data) {
            this.seaEventRecord = this.seaEventRecord;
            this.st_thomas_school_picklist_value = getFieldValue(data, SEA_SCHOOL_BANNER_CODE);
            this.school_name = getFieldValue(data, SEA_SCHOOL_NAME);
        }
    }


    @wire(getStThomasSchools)
    wiredSchools({data, error}) {
        if (data) {
            let values = [];
            values.push({label: 'All Colleges', value: ''});
            for (let key in data) {
                values.push(
                    {
                        label: data[key].Name,
                        value: data[key].Banner_Code__c
                    }
                )
                this.school_banner_key_id.set(data[key].Banner_Code__c, data[key].Id);
            }
            this.st_thomas_school_picklist = values;
        } else {
            console.log(error);
        }
    }


    @wire(getPrograms, {
        school_name: '$school_name'
    })
    wiredPrograms({data, error}) {
        if (data) {
            let values = [];
            for (let key in data) {
                let program_name = '';
                if (Boolean(data[key].Program_Name_on_Application__c)) {
                    program_name = data[key].Program_Name_on_Application__c;
                } else {
                    program_name = data[key].Name;
                }
                values.push(
                    {
                        label: program_name + ' (' + data[key].Program_Major_Concentration__c + ')',
                        value: data[key].Program_Major_Concentration__c
                    }
                )
            }
            this.st_thomas_program_picklist = values;
        } else if (error) {
            console.log(error);
        }
    }

    handleOnChange(event) {
        const fields = {};
        fields[SEA_ID.fieldApiName] = this.recordId;

        switch (event.target.label) {

            case 'St Thomas School':
                if (Boolean(event.detail.value)) {
                    fields[SEA_ACCOUNT.fieldApiName] = this.school_banner_key_id.get(event.detail.value);
                } else {
                    fields[SEA_ACCOUNT.fieldApiName] = null;
                }
                break;

            case 'Programs' :
                let programList = event.detail.value;
                let programList1 = '';
                let programList2 = '';
                let programList3 = '';
                programList.forEach(program => {
                    if ((programList1 + ';' + program).length < 255) {
                        programList1 += program + ';';
                    } else if ((programList2 + ';' + program).length < 255) {
                        programList2 += program + ';';
                    } else if ((programList3 + ';' + program).length < 255) {
                        programList3 += program + ';';
                    } else {
                        console.log('too many programs');
                    }
                });
                fields[SEA_PROGRAM1.fieldApiName] = programList1;
                fields[SEA_PROGRAM2.fieldApiName] = programList2;
                fields[SEA_PROGRAM3.fieldApiName] = programList3;
                break;
        }

        if (fields) {
            const recordInput = {
                fields: fields
            };
            updateRecord(recordInput).then((record) => {
                console.log(record);
            });
        }

    }

}

