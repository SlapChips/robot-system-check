*** Settings ***
Resource    keywords.robot

*** Variables ***
@{package_list}    ant    java-11-openjdk    python3    openssl    pam    python3-setuptools
@{utility_list}    tar    gzip    find    ssh-keygen
@{dns_servers}    192.168.1.1    8.8.8.8    8.8.4.4
@{ntp_servers}    ntp1.trans-ix.nl    leontp2.office.panq.nl
@{nso_fw_ports}   2022    2024    8080    8888 
@{pam_modules}    with-faillock    without-nullok    spam-locks


*** Test Cases ***
Verify Autheselect profile sssd-vf is created
    [Documentation]    Verify that a custom sssd profile has been created
    [Tags]    security   nso
    ${output}    Run    authselect list
    Should Contain    ${output}    sssd-vf 

Verify Expected Authselect Profile is Active
    ${output}    Run    authselect current -r
    # This runs the command "authselect current -r" and returns the current active profile
    # The test checks that this matches the expected value of custom/sssd-vf
    ${profile}    Set Variable    custom/sssd-vf
    IF    '${profile}' in '${output}'    Pass Execution    Current Profile is correct - sssd-vf    ELSE    Fail    Incorrect, or No, Profile active

Verify that the required PAM Modules are enabled
    [Documentation]    This test will verify that without-nullok and with-faillock modules are activated
    [Tags]    security    nso
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

Verify that password-auth file has been modifed
    [Documentation]    The fie /etc/authselect/custom/sssd-vf needs to be modified
    [Tags]    security
    Pass Execution    Need to come up with a way to check modifications

Verify that system-auth file has been modifed
    [Documentation]    The fie /etc/authselect/custom/sssd-vf needs to be modified
    [Tags]    security
    Pass Execution    Need to come up with a way to check modifications

Verify that faillock.conf has been modifed
    [Documentation]    We are required to modify the fail_interval to be >= 1800 seconds
    [Tags]    security
    ${faillock_conf}    Get File    /etc/security/faillock.conf
    # Log    ${faillock_conf}
    ${all_matches}    Get Regexp Matches  ${faillock_conf}   (?m)^\\s?fail_interval\\s?\=\\s?(\\d+)   1
    ${list_len}    Get Length    ${all_matches}
    IF    ${list_len} > 1    Fail    Configuration Error in file, Too many values returned
    ${faillock_interval}    Get From List    ${all_matches}    0
    IF    ${faillock_interval} < 1800    Fail    Failock interval is set to value < 1800

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

Verify that pwquality.conf has been modified -2
    [Documentation]    We are required to modify the pwquality.conf to ensure only complex passwords are allowed
    ${dict}    Create Dictionary    minlen=8    dcredit=-1    ucredit=-1    lcredit=-1    ocredit=-1    dummy=1
    ${file_path}    Set Variable    /etc/security/pwquality.conf
    Get Regexp Matches For Key Value Pairs in File    ${dict}    ${file_path}

Verify login.defs has been modifed
    [Documentation]    Password expiration values need to be modified in the /etc/login.defs file
    ${dict}    Create Dictionary    PASS_MAX_DAYS=90    PASS_MIN_DAYS=1    PASS_MIN_LEN=5    PASS_WARN_AGE=5    dummy=5
    ${file_path}    Set Variable    /etc/login.defs
    Get Regexp Matches For Key Value Pairs in File    ${dict}    ${file_path}

Verify that faillock.conf has been modifed -2
    [Documentation]    We are required to modify the fail_interval to be = 1800 seconds
    ${dict}    Create Dictionary    fail_interval=1800
    ${file_path}    Set Variable    /etc/security/faillock.conf
    Get Regexp Matches For Key Value Pairs in File    ${dict}    ${file_path}
