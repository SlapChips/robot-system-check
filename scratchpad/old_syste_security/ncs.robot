*** Settings ***
Library  XML
Library  BuiltIn
Library  OperatingSystem
Resource    keywords.robot

*** Variables ***
${NCS_CONF_PATH}    Set Variable    ncs.conf 

*** Test Cases ***
verify that ANT is installed
    [Documentation]    ANT is a pre-requisite for NSO
    [Tags]    nso 
    ${command}    Set Variable    ant -version
    Run Command and Verify Ouptput Against String    ${command}    Apache


verify ant rpm is installed
    [Documentation]    Verify that the ant RPM is installed
     Check RPM Package is Installed    ant

verify java-11-openjdk rpm is installed
    [Documentation]    Verify that the Java-11-OpenJDK RPM is installed
     Check RPM Package is Installed    java-11-openjdk


Check RPM Package is Installed
    ${rpm_package}    java-11-openjdk
    ${rpm_cmd}    rpm -qa
    ${command}    Evaluate    ${rpm -qa} + " " + ${rpm_package}
    Log    ${command}
    ${output}    Run    ${command}
    Should Not Contain    ${output}    Not Installed

Verify ncs-ipc-access-check is enabled
    [Documentation]    Verify that ncs-ipc-access-check is enabled
    [Tags]    nso 
    Check NCS Config Against String Value    ncs-ipc-access-check/enabled    true

Verify External Authentication Is enabled
    [Documentation]    External Authentication should be enabled to authenticate users
    [Tags]    nso 
    ${status}    Run Keyword And Return Status    Check NCS Config Against String Value    aaa/external-authentication/enabled    true
    Run Keyword If  '${status}' == 'PASS'  Verify External Authentication Script Exists

Verify External Authentication Script Exists
    [Documentation]    If External Auth is enabled check the script called Exists
    [Tags]    nso 
    ${ncs_file_path}    Set Variable    ncs.conf
    ${xpath}    Set Variable    aaa/external-authentication/executable
    ${auth_file}    Get Element Text    ${ncs_file_path}        ${xpath}
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