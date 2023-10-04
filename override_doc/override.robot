*** Settings ***
Library    XML

*** Keywords ***



Add Step 2
    [Arguments]    ${documentation}
    ${step}    Set Variable    ${documentation}

Step. ${message}
    [Documentation]    Simple Keyword to store text which will be added to 
    ...    test case Docx as instruction/guidance steps to inform reader in the
    ...    tets procesdures
    ...    
    Log    ${message}

*** Test Cases ***

Create and Store Dynamic XML
    [Documentation]    Some documentation
    Step. Step 1
    Step. Step 2
    Step. Step 3
