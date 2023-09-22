*** Settings ***
Library    OperatingSystem


*** Variables ***
${NTP}  set Variable  ntp1.trans-ix.nl 


*** Test Cases ***
Is NTP Configured
    [Documentation]  Validate if the NTPD service is running
    [Tags]  services linux
    ${command}  Set Variable  chronyc sources
    ${output}  Run  ${command}
    Should Contain    ${output}    ${NTP}