*** Settings ***
Library    CiscoNso.py

*** Test Cases ***
Test Load merge
    ${load_xml_file}    Set Variable    test
    ${status}    ${message}    ${output}    Load Merge Xml File And Return Output    ${load_xml_file}
    Log    Output ${output}
    Log    Status ${status}
    Log    Message ${message}
    IF    ${status} == True 
        Pass Execution    Validation Successful for file : ${load_xml_file}
    ELSE
        Fail    Validation unsuccesful for file : ${load_xml_file}
    END

