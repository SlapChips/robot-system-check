*** Settings ***
Name    NSO Configuration (Running Config) Validation
Library    OperatingSystem
Library    ../resources/CiscoNso.py
Resource   ../resources/keywords.robot
Resource   ../resources/ncs.keywords.robot

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



Verify High-Availability is operational
    [Documentation]    Verify that High-Availability is operational by running the
    ...    command 'show ncs-state ha' and 'show high-availbility' if the state 
    ...    returns errors the high-availbility is not configured correctly and 
    ...    needs to be modified and re-verified.
    [Tags]    nso 
    Skip    TODO Create Test 

Verify that the T-SDN Packages are installed in NSO
    [Tags]    t-sdn
    [Documentation]    The CNC integration with NSO requires that the T-SDN Core 
    ...    Function Pack (CFP) is installed and present. These packages should be 
    ...    uploaded to the /var/opt/ncs/packages/ folder and then linked to the 
    ...    /opt/ncs/packages/ directory where the system will load them on application
    ...    startup. This test validates the core packages only, add additional test 
    ...    cases for custom packages validation. If the packages are not found the 
    ...    test fails. To fix, download the neccesary packages bundle and follow the 
    ...    CFP install instructions.
    ...    
    Skip    TODO Create Test 

Verify that the T-SDN startup configurations are loaded
    [Tags]    t-sdn
    [Documentation]    In addtion to the T-SDN Core Function Pack packages being 
    ...    installed the system needs start-up configuration to be loaded into the
    ...    system to  operate. These files are provided as XML files in the CFP bundle in the 
    ...    'config/' folder. Loading these files is achived by using the 'load merge filename.xml'
    ...    command
    Skip    TODO Create Test 

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

