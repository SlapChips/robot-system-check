*** Settings ***
Name    NSO Configuration (ncs.conf) Validations
Documentation    The following tests validate that the /etc/ncs/ncs.conf file has 
...    been correctly configured with the required values. The faile can be viewed 
...    by accessing the server and simply using the commands:
...    - cat /etc/ncs/ncs.conf
...    - more /etc/ncs/ncs.conf
...


Library  XML
Library  BuiltIn
Library  OperatingSystem
Resource    ../resources/ncs.keywords.robot
Resource    ../resources/keywords.robot

*** Variables ***
${NCS_CONF_PATH}    /etc/ncs/ncs.conf 

*** Test Cases ***

Verify ncs-ipc-access-check is enabled
    [Documentation]    Verify that ncs-ipc-access-check is enabled
    [Tags]    nso 
    Check NCS Config Against String Value    ncs-ipc-access-check/enabled    true

Verify External Authentication Is enabled
    [Documentation]    External Authentication should be enabled to authenticate users
    [Tags]    nso 
    Check NCS Config Against String Value    aaa/external-authentication/enabled    true
    

Verify External Authentication Script Exists
    [Documentation]    If External Auth is enabled check the script called Exists
    [Tags]    nso 
    ${xpath}    Set Variable    aaa/external-authentication/executable
    ${auth_file}    Get Element Text    ${NCS_CONF_PATH}        ${xpath}
    Should Exist    ${auth_file}

Verify netconf-north-bound (GLOBAL) is enabled
    [Documentation]    Netconf North Bound interface should be enabled
    [Tags]    nso
    Check NCS Config Against String Value    netconf-north-bound/enabled    true

Verify netconf-north-bound (SSH) is enabled
    [Documentation]    Netconf North Bound interface should be enabled
    [Tags]    nso
    Check NCS Config Against String Value    netconf-north-bound/transport/ssh/enabled    true

Verify netconf-north-bound is (TELNET) is disabled
    [Documentation]    Netconf North Bound interface should be enabled
    [Tags]    nso
    Check NCS Config Against String Value    netconf-north-bound/transport/tcp/enabled    false 

Verify High-Availability Is Enabled in ncs.conf 
    [Documentation]    Verify that High-Availability is enabled in the ncs.conf file 
    [Tags]    nso 
    Check NCS Config Against String Value    ha/enabled    true

