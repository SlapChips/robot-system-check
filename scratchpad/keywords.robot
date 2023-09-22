*** Settings ***
Library    OperatingSystem
Library    XML
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
    ${ncs_file_path}    Set Variable    ncs.conf
    ${xml}    Get Element Text    ${ncs_file_path}        ${xpath}
    Should Contain    ${xml}    ${expected_output}

Check RPM Package is Installed
    [Arguments]    ${rpm_package}
    ${rpm_cmd}    rpm -qa
    ${command}    Evaluate    ${rpm -q} + " " + ${rpm_package}
    Log    ${command}
    ${output}    Run    ${command}
    Should Not Contain    ${output}    not installed

Check Utility in Path
    [Arguments]    ${utility}
    ${utility_cmd}    Set Variable    which 
    ${command}    Evaluate    ${utility_cmd} + " " + ${utility}
    ${output}    Run    ${command}
    Should Not Contain    ${output}    /usr/bin/which: no
