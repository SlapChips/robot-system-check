*** Settings ***

Library     OperatingSystem
Resource    ../resources/keywords.robot
Resource    ../resources/ncs.keywords.robot

*** Variables ***
${NCS_CONF}

*** Keywords ***

Check NCS_CONFIG XPATH Against String Value
    [Arguments]    ${xpath}    ${expected_output}
    ${ncs_file_path}    Set Variable    ncs.conf
    ${xml}    Get Element Text    ${ncs_file_path}        ${xpath}
    Should Contain    ${xml}    ${expected_output}

Search XPATH against NCS_CONF
    [Documentation]    Searches through the NCS_CONF Suite variable for a given 
    ...    xpath and returns the result(s) as a list.
    ...    
    [Arguments]    ${xpath} 
    ${response}    Get Elements Texts    ${NCS_CONF}    ${xpath}
    RETURN    ${response}
 
*** Test Cases ***
Is the NSO Service (NCS) Running
    [Documentation]    We need to verify that the service is running 
    ...    this test will run the command 'systemctl is-active ncs' and parse the response
    ...    test passes if the response is 'actve' any other response will fail
    ...    if the test fails, enable the service using the 'systemctl start ncs' command
    ${status}    Run    systemctl is-active ncs
    ${expected_output}    Set Variable    active
    Should Be Equal    ${status}    ${expected_output}

Is the NSO service (NCS) enabled on boot
    [Documentation]    Insatlling NSO doesn't automatically enable the service to persistantly start on reboot
    ...    one the system has been deployed we need to ensure that the service will auto restart if the servers is 
    ...    rebooted. The test will verify using the 'systemct is-enabled ncs' command if the repsonse includes the string
    ...    'enabled' the test passes, if the match is not fouund the test will fail.
    ...    
    ...    If the test fails enable the service using the command 'systemctl enable ncs' and re-run the test 
    ...    
    ${status}    Run    systemctl is-enabled ncs
    ${expected_output}    Set Variable    enabled
    Should Contain    ${status}    ${expected_output}

Extract the NSO Application Config
    [Documentation]    The NSO application config will be extarcted to a local file 
    ...    and the subsequent test will be executed against this file.
    ...    If the test is unable to retrieve the configuration run the command 
    ...    "show running-config | display xml | save ncs_config.xml" and move the file
    ...    the test folder, the script will attempt to load a file if the extarction fails
    ...    as a fallback, make sure the file is recent
    ...    
    ...    The test will also validate that the test user has the neccesary group 
    ...    permissions needed to execute the test, if it fails add the ncsadmin group 
    ...    to the user 'usermod -a -G ncsadmin test_user'
    ...    
    ${user}    Run    whoami
    ${groups}    Run    groups
    Should Contain    ${groups}    ncsadmin
    ${ncs_conf_file}    Run    ncs_cli -C -u ncsadmin <<< "show running-config | display xml"
    Set Suite Variable    ${NCS_CONF}    ${ncs_conf_file}
    ${xpath}    Set Variable    devices/global-settings/
    # ${response}    Get Elements Texts    ${NCS_CONF}    ${xpath}
    ${response}    Search XPATH against NCS_CONF    ${xpath}
    Should Not Be Empty    ${response}
    Log   Successfully Imported NCS_CONF 


Test 2
    ${xpath}    Set Variable    devices/global-settings/
    # ${response}    Get Elements Texts    ${NCS_CONF}    ${xpath}
    ${response}    Search XPATH against NCS_CONF    ${xpath}
    Should Not Be Empty    ${response}
    Log   Successfully Imported NCS_CONF 