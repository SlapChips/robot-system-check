*** Settings ***
Library  XML
Library  BuiltIn
Library  OperatingSystem
Library    String
Library    Collections
Resource    keywords.robot


*** Test Case ***

Verify that pwquality.conf has been modified
    [Documentation]    We are required to modify the pwquality.conf to ensure only complex passwords are allowed
    ${pwquality_dict}    Create Dictionary    minlen=8    dcredit=-1    ucredit=-1    lcredit=-1    ocredit=-1    dummy=1
    ${pwquality_conf}    Get File    /etc/security/pwquality.conf
    ${errors_list}    Create List
    FOR    ${param}    IN    @{pwquality_dict}
        ${match}    Get Regexp Matches    ${pwquality_conf}    (?m)^\\s?${param}\\s?\=\\s?(-?\\d+)    1
        ${expected_value}    Get From Dictionary    ${pwquality_dict}    ${param}
        ${status}    ${status_message}     Run Keyword And Ignore Error    Should Contain    ${match}    ${expected_value}
        IF    '${status}' != 'PASS'   Append to List    ${errors_list}    ${param}
    END
    Log    ${errors_list}
    Should Be Empty    ${errors_list}    Errors found in values for ${errors_list}

Verify Password Expiration Values Have Been Updatedi 2
    [Documentation]    We need to modify the default password aging values in /etc/login.defs
    ${login_defs}    Get File    /etc/login.defs
    &{login_defs_dict}    Create Dictionary    PASS_MAX_DAYS=90    PASS_MIN_DAYS=1    PASS_MIN_LEN=5    PASS_WARN_AGE=5    dummy=5

    ${errors_list}    Create List

    FOR    ${param}    ${expected_value}    IN    &{login_defs_dict}
        ${match}    Get Regexp Matches    ${login_defs}    (?m)^\\s?${param}\\s*(\\d+)    1
        ${number_of_results}    Get Length    ${match}
        # IF    ${number_of_results} > 0
        IF    'Get Length    ${match}' > 0
            ${match_val}    Set Variable If    ${match[0]}    ${match[0]}
            ${status}    ${status_message}=    Run Keyword And Ignore Error    Should Be Equal As Integers    ${match_val}    ${expected_value}
            Run Keyword If    '${status}' != 'PASS'    Append To List    ${errors_list}    ${param}
        ELSE
            Append To List    ${errors_list}    ${param}
        END
        # ${match_val}    Set Variable If    ${match[0]}    ${match[0]}
        # ${status}    ${status_message}=    Run Keyword And Ignore Error    Should Be Equal As Integers    ${match_val}    ${expected_value}
        # Run Keyword If    '${status}' != 'PASS'    Append To List    ${errors_list}    ${param}
    END

    Log List    ${errors_list}
    Should Be Empty    ${errors_list}    Errors found in values for ${errors_list}


Verify password expiration values have been updated
    [Documentation]    We need to modify the default password aging values in /etc/login.defs
    ${login_defs}    Get File    /etc/login.defs 
    ${login_defs_dict}    Create Dictionary    PASS_MAX_DAYS=90    PASS_MIN_DAYS=1    PASS_MIN_LEN=5    PASS_WARN_AGE=5    dummy=5
    ${errors_list}    Create List
    FOR    ${param}    IN    @{login_defs_dict}
        ${match}    Get Regexp Matches    ${login_defs}    (?m)^\\s?${param}\\s*(\\d+)    1
        ${expected_value}    Get From Dictionary    ${login_defs_dict}    ${param}
        ${status}    ${status_message}     Run Keyword And Ignore Error    Should Contain    ${match}    ${expected_value}
        IF    '${status}' != 'PASS'   Append to List    ${errors_list}    ${param}
    END
    Log    ${errors_list}
    Should Be Empty    ${errors_list}    Errors found in values for ${errors_list}

Verify the user account inavtive days value has been modified
    [Documentation]    The default value of INACTIVE in /etc/defaults/useradd needs to be changed from -1 to 90
        ${useradd_conf}    Get File    /etc/default/useradd 
        ${match}    Get Regexp Matches    ${useradd_conf}    (?m)^\\s?INACTIVE\\s?\=\\s?(-?\\d+)    1
        ${match_val}    Get From List    ${match}    0
        IF    ${match_val} != 90    Fail    INACTIVE not set to expected value 

Check MaxAuthTries Value in sshd_config File
    ${useradd_conf}=    Get File    /etc/ssh/sshd_config
    ${match}=    Get Regexp Matches    ${useradd_conf}    (?m)^\\s?MaxAuthTries\\s?(\\d+)    1
    ${match_val}    Set Variable If    ${match}    ${match[0]}    None
    
    Should Be Equal As Strings    ${match_val}    5    MaxAuthTries not set to expected value
