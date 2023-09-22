*** Settings ***
Library  XML
Library  BuiltIn
Library  OperatingSystem
Resource    keywords.robot
*** Test Cases ***

verify that ANT is installed
    [Documentation]    ANT is a pre-requisite for NSO
    [Tags]    nso 
    ${command}    Set Variable     ant -version
    Run Command and Verify Ouptput Against String    ${command}    Apache

verify java-11-openjdk rpm is installed
    [Documentation]    Verify that the Java-11-OpenJDK RPM is installed
    ${status}    Run Keyword and Return Status    Check RPM Package is Installed 2    java-11-openjdk
    Should Be Equal As Strings    True    ${status}

Verify ncs-ipc-access-check is enabled
    [Documentation]    Verify that ncs-ipc-access-check is enabled
    [Tags]    nso 
    Check NCS Config Against String Value    ncs-ipc-access-check/enabled    true

Verify External Authentication Is enabled
    [Documentation]    External Authentication should be enabled to authenticate users
    [Tags]    nso 
    Check NCS Config Against String Value    aaa/external-authentication/enabled   true

Verify External Authentication Script Exists
    [Documentation]    If External Auth is enabled check the script called Exists
    [Tags]    nso 
    ${ncs_file_path}    Set Variable    ncs.conf
    ${xpath}    Set Variable    aaa/external-authentication/executable
    ${auth_file}    Get Element Text    ${ncs_file_path}        ${xpath}
    Should Exist    ${auth_file}

Verify netconf-north-bound is enabled
    [Documentation]    Netconf North Bound interface should be enabled
    [Tags]    nso
    Check NCS Config Against String Value    netconf-north-bound/enabled    true    

Verify netconf-north-bound (SSH) is enabled
    [Documentation]    Netconf North Bound interface should be enabled
    [Tags]    nso
    Check NCS Config Against String Value    netconf-north-bound/transport/ssh/enabled    true

Verify netconf-north-bound (TELNET) is disabled
    [Documentation]    Netconf North Bound interface should be enabled
    [Tags]    nso
    Check NCS Config Against String Value    netconf-north-bound/transport/tcp/enabled    false

Verify High-Availability Is Enabled in ncs.conf 
    [Documentation]    Verify that High-Availability is enabled in the ncs.conf file 
    [Tags]    nso 
    Check NCS Config Against String Value    ha/enabled    true
