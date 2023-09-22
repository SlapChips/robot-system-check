*** Settings ***
Library    OperatingSystem
Library    Collections
Library    String
Resource   ../resources/keywords.robot

*** Variables ***

*** Test Cases ***
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
