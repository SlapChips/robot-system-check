*** Settings ***
Documentation    This set of tests validates the system envionment changes have been made for 
...    the Cisco NSO application and the T-SDN Core Function Pack 
...    
Library    OperatingSystem
Library    Collections
Library    String
Resource    ../resources/keywords.robot

*** Variables ***

*** Test Cases ***
Verify that the overcommit_memmory value has been updated
    [Documentation]    The default os value is pre-configured to 0, this needs to be modified
    ...    to "2". This can be changed at run-time by "echo 2 > /proc/sys/vm/overcommit_memmory"
    ...    however it should be persistently added to the /etc/sysctl.d/ncs.conf 
    ...    this test will check both locations
    ...    

    ${run_time_overcommit}    Run    cat /proc/sys/vm/overcommit_memory 
    ${sysctl_d_ncs_conf}    Get File    /etc/sysctl.d/ncs.conf
    ${error_list}   Create List
    IF   ${run_time_overcommit} == 2
        Log    /proc/sys/vm/overcommit_memory is configured correctly
    ELSE
        Append To List    ${error_list}    overcommit_memory not set to expected value
    END
    ${matches}    Get Regexp Matches    ${sysctl_d_ncs_conf}    vm.overcommit_memory\\s?=\\s?(.*)    1
    Log    ${matches}
    Log    ${matches[0]}
    IF    ${matches[0]} == 2
        Log    vm.overcommit_memory assigned to correct values
    ELSE
        Append To List    ${error_list}    vm.overcommit_memory not assigned correct values
    END
    Should Be Empty    ${error_list}    Errors encountered with values for ${error_list}

Verify the T-SDN system limits have been configured
    [Documentation]    The T-SDN Core Function Pack requires system limit changes to be made 
    ...    the test will check the /etc/security/limnits.d/ncs.conf file exists and that the expected values 
    ...    have been provided. The expected values are stored in a dict k,v arrangement and can be extended
    ...    if needed
    ...  
    ${file}    Set Variable    /etc/security/limits.d/ncs.conf   
    Should Exist    ${file}
    ${limits_dict}    Create Dictionary    \n\\*\s+soft nproc=65535    \n\\*\s+hard nproc=65535    \n\\*\s+soft nofile=65535    \n\\*\s+hard memlock=65536    \n\\*\s+soft memlock=65536
    Get Regexp Matches For Key Value Pairs in File    ${limits_dict}  ${file}
