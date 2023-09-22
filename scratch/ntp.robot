*** Settings ***
Library    OperatingSystem
Resource    keywords.robot

*** Variables ***
${NTP}  ntp1
${System_Time_Zone}  Europe/Amsterdam


*** Test Cases ***
Is the Correct System Time-Zone defined
    [Documentation]    Validate that the System Time-Zone ${System_Time_Zone} is Correctly Configured
    [Tags]    ntp  system  linux 
    ${command}    Set Variable    timedatectl show | grep -Po '(?<=Timezone=)[^,]+'
    ${expected_output}    Set Variable    ${System_Time_Zone}
    Run Command and Verify Ouptput Against String    ${command}    ${expected_output}

Is Chrony Installed
    [Documentation]  Validate that the Chrony RPM's are installed
    [Tags]  ntp system linux
    ${command}  Set Variable  rpm -qa chrony*
    ${output}  Run  ${command}
    Should Contain   ${output}   chrony-4.3-1.el9.x86_64

Is NTP Configured
    [Documentation]  Validate if the NTPD service is running
    [Tags]  ntp system linux
    ${command}  Set Variable  chronyc sources
    ${output}  Run  ${command}
    Should Contain    ${output}    ${NTP}

Is The 'timedatectl' showing NTPSynchronised=yes
    [Documentation]    Verify that timedatectl shows autoatic time synchrnisation is enabled
    Run Command and Verify Ouptput Against String  timedatectl show | grep -Po '(?<=NTPSynchronized=)[^,]+'  es
