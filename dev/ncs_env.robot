*** Settings ***
Documentation    This set of tests validates the system envionment changes have been made for
...    the Cisco NSO application and the T-SDN Core Function Pack the changes relate to:
...    - overcommit_memory disabled across reboots
...    - system limits configured as per T-SDN package documentation
...

Library    OperatingSystem
Library    Collections
Library    String
Resource   ../resources/keywords.robot


*** Variables ***

*** Test Cases ***
Verify that the overcommit_memory value has been updated
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
    ...    To handle the Regex * issue we need to preface each key with \n\\*\s+ should be handled in
    ...    the KEywork but thats for the future
    ...

    ${file}    Get File    /etc/security/limits.d/ncs.conf
    ${clean_file}    Replace String Using Regexp    ${file}    \\s{2}    ${SPACE}    # This fixes some whitepsace issues that i found in the files
    ${limits_dict}    Create Dictionary    soft nproc=65535    hard nproc=65535    soft nofile=65535    hard memlock=65536    soft memlock=65536
    ${error_list}    Create List
    FOR    ${key}    ${value}    IN    &{limits_dict}
        
        ${matches}    Get Regexp Matches    ${clean_file}    (?<!#)\\s+\\*\\s+${key}\\s?(\\d+)    1

        ${len}    Get Length    ${matches}
        IF    ${len} > 0
            IF    ${matches[0]} == ${value}
                Log    ${key} value found, and set to the expected value : ${value}
            ELSE
                Append To List    ${error_list}    ${key}
            END
        ELSE
            Log    ${key} not found in ${file}
            Append To List    ${error_list}    ${key}
        END
    END
    Should Be Empty    ${error_list}    Errors found in the following paramaters : ${error_list}

Verify that the limit changes are applied to the system
    [Documentation]    This test checks that the variables applied to the /etc/security/limits.d/ncs.conf
    ...    have been applied. This typically requires a user to disconnect and reconnect to the servers
    ...

    ${ulimit_settings}    Run    ulimit -a
    ${ulimit_dict}    Create Dictionary    max locked memory=65536    open files=65535    max user processes=65535
    ${error_list}    Create List
    FOR    ${ulimit}    ${ulimit_value}    IN    &{ulimit_dict}
        Log    ${ulimit}:${ulimit_value}
        ${matches}    Get Regexp Matches    ${ulimit_settings}    ${ulimit}.*\\)\\s(.*)    1
        ${len}    Get Length    ${matches}
        IF    ${len} > 0
            IF    ${matches[0]} == ${ulimit_value}
                Log    ${ulimit} value found, and set to the expected value : ${ulimit_value}
            ELSE
                Append To List    ${error_list}    ${ulimit}
            END
        ELSE
            Log    ${ulimit} not found in output
            Append To List    ${error_list}    ${ulimit}
        END

    END
    Should Be Empty    ${error_list}    Errors found in the following paramaters : ${error_list}