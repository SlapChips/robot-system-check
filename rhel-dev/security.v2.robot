*** Settings ***
Name    NSO Operating System (RHEL) Security Features Validation
Documentation    The following tests verify the security configuration that are expected to be implemented
...    on the redhat servers that will host the Cisco NSO application
...    - firewall Service Configrations
...    - autheselect custome profile creation and modifications
...    - PAM Configrations
...    - Password quality modifications 
...    Refer to the SCDP documentation to address any failed tests.
...    

Resource    ../resources/keywords.robot
Library    OperatingSystem
Library    String
Library    Collections
*** Variables ***
@{nso_fw_ports}   2022    2024    8080    8888 
@{pam_modules}    with-faillock    without-nullok    spam-locks

*** Test Cases ***

Verify firewalld service is enabled
    [Documentation]    The firewall service should not be disabled on reboot
    [Tags]    security
    ${output}    Run    systemctl is-enabled firewalld
    Should Be Equal As Strings    ${output}    enabled

Verify NSO ports are configured in the firewalld 
    [Documentation]    Check that the neccesary tcp/udp ports are open for nso the 
    ...    ports are listed in the list "nso_fw_ports" defined in the global Variables
    ...    List includes the following : @{nso_fw_ports} 
    [Tags]    security
    ${output}    Run    sudo firewall-cmd --list-all
    FOR    ${port}    IN    @{nso_fw_ports}
        Should Contain    ${output}    ${port}
        Log    ${port}
    END

Verify authselect profile sssd-vf is created
    [Documentation]    Verify that a custom sssd profile has been created
    [Tags]    security
    ${output}    Run    authselect list
    Should Contain    ${output}    sssd-vf 

Verify expected authselect profile is active
    ${output}    Run    authselect current -r
    [Documentation]    This runs the command "authselect current -r" and returns the current active profile
    ...    the test checks that this matches the expected value of custom/sssd-vf
    ${profile}    Set Variable    custom/sssd-vf
    IF    '${profile}' in '${output}'    Pass Execution    Current Profile is correct - sssd-vf    ELSE    Fail    Incorrect, or No, Profile active

Verify that the required PAM Modules are enabled
    [Documentation]    This test will verify that without-nullok and with-faillock modules are activated 
    ...    the test will run the command "autheselect current" which returns the enabled features in the 
    ...    format:
    ...    
    ...    Profile ID: custom/sssd-vf
    ...    Enabled features:
    ...    - with-faillock
    ...    - without-nullok
    ...    
    ...    Checks made against the following features: @{pam_modules}

    [Tags]    security
    ${output}    Run    authselect current
    ${module_status_dict}    Create Dictionary
    Log    ${output}
    FOR    ${module}    IN    @{pam_modules}
        ${regex_result}    ${regex_message}=    Run Keyword And Ignore Error    Should Match Regexp    ${output}    ${module}
        Set To Dictionary    ${module_status_dict}     ${module}    ${regex_result}
    END
    Log    ${module_status_dict}
    ${status}    ${status_message}    Run Keyword And Ignore Error    Dictionary Should Not Contain Value   ${module_status_dict}    FAIL
    Log    ${status}
    IF     'FAIL' in '${status}'    Fail    Expected PAM enabled-feature not found

Check the password-auth file has been updated
    [Documentation]    Read the /etc/authselect/custom/sssd-vf/password-auth file
    ...    and check that the values have been modified the check takes a dict with
    ...    the module search string and the expected configuration as a k,v Pairs
    ...    the check then searches the file for the key and evaluates the value
    ...
    ${check_dict}    Create Dictionary   auth.*pam_unix.so={if not "without-nullok":nullok} try_first_pass    password.*pam_pwquality.so=try_first_pass local_users_only   password.*pam_unix.so sha512 shadow={if not "without-nullok":nullok} try_first_pass use_authtok    dummy=dummy
    ${password_auth}    Get File    /etc/authselect/custom/sssd-vf/password-auth
    ${error_list}    Create List
    FOR    ${key}    ${value}    IN    &{check_dict}
        Log    ${key} : ${value}
        ${matches}    Get Regexp Matches    ${password_auth}    \\s?${key}\\s?(.*)    1
        ${len}   Get Length    ${matches}
        IF    ${len} > 0
            Log    Match Found match ${key} : ${matches}
            Log    ${matches[0]}
            IF    '${value}' == '${matches[0]}'
                Log    '${key}' Configured as expected
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




Check the system-auth file has been updated
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

Verify that faillock.conf has been modifed
    [Documentation]    We are required to modify the fail_interval to be = 1800 seconds
    [Tags]    security
    ${dict}    Create Dictionary    fail_interval=1800
    ${file_path}    Set Variable    /etc/security/faillock.conf
    Get Regexp Matches For Key Value Pairs in File    ${dict}    ${file_path}

Verify that pwquality.conf has been modified
    [Documentation]    We are required to modify the /etc/security/pwquality.conf 
    ...    to ensure only complex passwords are allowed following values should be used:
    ...    - minlen  =  8
    ...    - dcredit = -1
    ...    - ucredit = -1
    ...    - lcredit = -1
    ...    - ocredit = -1
    [Tags]    security
    ${dict}    Create Dictionary    minlen=8    dcredit=-1    ucredit=-1    lcredit=-1    ocredit=-1    dummy=1
    ${file_path}    Set Variable    /etc/security/pwquality.conf
    Get Regexp Matches For Key Value Pairs in File    ${dict}    ${file_path}

Verify login.defs has been modifed
    [Documentation]    Password expiration values need to be modified in the /etc/login.defs file the 
    ...    default values need to be modified to meet the following requirements:
    ...    - PASS_MIN_LEN    5
    ...    - PASS_MAX_DAYS   90
    ...    - PASS_MIN_DAYS   1
    ...    - PASS_WARN_AGE   5

    [Tags]    security
    ${dict}    Create Dictionary    PASS_MAX_DAYS=90    PASS_MIN_DAYS=1    PASS_MIN_LEN=5    PASS_WARN_AGE=5    dummy=5
    ${file_path}    Set Variable    /etc/login.defs
    Get Regexp Matches For Key Value Pairs in File    ${dict}    ${file_path}

Verify the user account inavtive days value has been modified
    [Documentation]    The default value of INACTIVE in /etc/defaults/useradd is set to -1 which 
    ...    equates to no inactvity time out for user. We need to change this value to 90 as per
    ...    request from Customer
    [Tags]    security
    ${useradd_conf}    Get File    /etc/default/useradd
    ${match}    Get Regexp Matches    ${useradd_conf}    (?m)^\\s?INACTIVE\\s?\=\\s?(-?\\d+)    1
    ${match_val}    Get From List    ${match}    0
    IF    ${match_val} != 90    Fail    INACTIVE not set to expected value
