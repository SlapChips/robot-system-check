*** Settings ***
Library    OperatingSystem
Library    String
Library    Collections

*** Variables ***

*** Test Cases ***

Check the syste-auth file has been updated
    [Documentation]    Read the /etc/authselect/custom/sssd-vf/system-auth file
    ...    and check that the values have been modified the check takes a dict with
    ...    the module search string and the expected configuration as a k,v Pairs
    ...    the check then searches the file for the key and evaluates the value
    ...
    ${check_dict}    Create Dictionary   auth.*pam_unix.so={if not "without-nullok":nullok} try_first_pass    password.*pam_pwquality.so=try_first_pass local_users_only enforce-for-root retry=3 remember=12   password.*pam_unix.so sha512 shadow={if not "without-nullok":nullok} try_first_pass use_authtok remember=12    dummy=dummy
    ${password_auth}    Get File    /etc/authselect/custom/sssd-vf/system-auth
    ${error_list}    Create List
    FOR    ${key}    ${value}    IN    &{check_dict}
        Log    ${key} : ${value}
        ${matches}    Get Regexp Matches    ${password_auth}    \\s?${key}\\s?(.*)    1
        ${len}   Get Length    ${matches}
        IF    ${len} > 0
            Log    Match Found match ${key} : ${matches}
            Log    ${matches[0]}
            IF    '${value}' == '${matches[0]}'
                Log    ${key} Configured as expected
            ELSE
                Log    ${key} Not configured as expected
                Append To List    ${error_list}    ${key}
            END
        ELSE
            Log    No Match found for : ${key}
            Append To List    ${error_list}    ${key}
        END

    END
    Log    ${error_list}
    Should Be Empty    ${error_list}    Errors found in the following modules ${error_list}
