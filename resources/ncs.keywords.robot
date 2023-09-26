*** Settings ***
Library    OperatingSystem
Library    XML
*** Variables ***
${NCS_CONF_PATH}    /etc/ncs/ncs.conf 
*** Keywords ***

Run Command and Verify Ouptput Contains String
    [Arguments]    ${command}    ${expected_output}
    ${output}    Run    ${command}
    Should Contain    ${output}    ${expected_output}

Run Command and Verify Ouptput does not Contain String
    [Arguments]    ${command}    ${expected_output}
    ${output}    Run    ${command}
    Should Not Contain    ${output}    ${expected_output}

Check NCS Config Against String Value
    [Arguments]    ${xpath}    ${expected_output}
    ${xml}    Get Element Text    ${NCS_CONF_PATH}       ${xpath}
    Should Contain    ${xml}    ${expected_output}

Check RPM Package is Installed
    [Arguments]    ${rpm_package}
    ${rpm_cmd}    Set Variable    rpm -qa
    ${command}    Evaluate    ${rpm_cmd} + " " + ${rpm_package}
    Log    ${command}
    ${output}    Run    ${command}
    Should Not Contain    ${output}    not installed

Check NCS_CONFIG XPATH Against String Value
    [Arguments]    ${xpath}    ${expected_output}
    ${ncs_file_path}    Set Variable    ncs.conf
    ${xml}    Get Element Text    ${ncs_file_path}        ${xpath}
    Should Contain    ${xml}    ${expected_output}