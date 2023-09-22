*** Settings ***
Library  XML
Library  BuiltIn
Library  OperatingSystem
Library    String
Library    Collections
Resource    keywords.robot

*** Variables ***
@{package_list}    ant    java-11-openjdk    python3    openssl    pam    python3-setuptools
@{utility_list}    tar    gzip    find    ssh-keygen
@{dns_servers}    192.168.1.1    8.8.8.8    8.8.4.4
@{ntp_servers}    ntp1.trans-ix.nl    leontp2.office.panq.nl
@{nso_fw_ports}   2022    2024    8080    8888 
@{pam_modules}    with-faillock    without-nullok    spam-lock

*** Test Cases ***

Verify dependancy packages are installed
    [Documentation]    Checks that all the necessary packages are installed
    [Tags]    prereqs    nso
    FOR    ${package}    IN    @{package_list}
           Check RPM PAckage is Installed    ${package}
           Log    ${package} Installed
           Log  Some Text:
    END

Verify required utilities are available
    [Documentation]    Cisco NSO requires some utilities, this test verfies these binaries exist
    [Tags]    prereqs    nso
    FOR    ${utility}    IN    @{utility_list}
        Check Utility in Path    ${utility}
        Log    ${utility}

    END

Verify Hostname is not set to localhost
    [Documentation]    Hostname Should not be localhost
    [Tags]    nso 
    ${output}    Run    hostnamectl hostname
    Should Not Be Equal As Strings    ${output}    localhost

Verify DNS servers are Configured
    [Documentation]    DNS Servers should be Configured
    [Tags]    nso 
    ${output}    Run    more /etc/resolve.conf
    FOR    ${dns_server}    IN    @{dns_servers}
        Should Contain    ${output}    ${dns_server}    
    END

Verify NTP servers are Configured
    [Documentation]    NTP Servers should be Configured
    [Tags]    nso 
    ${output}    Run    chronyc sources
    FOR    ${ntp_server}    IN    @{ntp_servers}
        Should Contain    ${output}    ${ntp_server}    
    END

Verify NTP service is active
    [Documentation]    Check that the NTP service is active
    [Tags]    nso 
    ${output}    Run    timedatectl show | grep -Po '(?<=NTPSynchronized=)[^,]+'
    Should Be Equal As Strings    ${output}    yes

Verify Firewalld service is enabled
    [Documentation]    The firewall service should not be disabled on reboot
    [Tags]    os    security
    ${output}    Run    systemctl is-enabled firewalld
    Should Be Equal As Strings    ${output}    enabled

Verify NSO ports are configured in the firewalld 
    [Documentation]    Check that the neccesary tcp/udp ports are open for nso 
    [Tags]    security    nso
    ${output}    Run    sudo firewall-cmd --list-all
    FOR    ${port}    IN    @{nso_fw_ports}
        Should Contain    ${output}    ${port}
        Log    ${port}
    END

Verify Autheselect profile sssd-vf is created
    [Documentation]    Verify that a custom sssd profile has been created
    [Tags]    security   nso
    ${output}    Run    autheselect list
    Should Contain    ${output}    sssd-vf 

Verify Expected Authselect Profile is Active
    ${output}    Run    authselect current -r
    # This runs the command "authselect current -r" and returns the current active profile
    # The test checks that this matches the expected value of custom/sssd-vf
    ${profile}    Set Variable    custom/sssd-vf
    IF    '${profile}' in '${output}'    Pass Execution    Current Profile is correct - sssd-vf    ELSE    Fail    Incorrect, or No, Profile active

Verify that the required PAM Modules are enabled 1
    [Documentation]    This test will verify that without-nullok and with-faillock modules are activated
    [Tags]    security    nso
    ${output}    Run    authselect current
    ${pam_modules}    Create List    with-faillock    without-nullok
    FOR    ${module}    IN    @{pam_modules}
        Log    ${module}
        IF    '${module}' in '${output}'    Log    ${module} is activated    ELSE    Log    ${module} is not installed
    END


Verify that the required PAM Modules are enabled 2
    [Documentation]    This test will verify that without-nullok and with-faillock modules are activated
    [Tags]    security    nso
    ${output}    Run    authselect current
    ${module_status_list}    Create List   
    Log    ${output}
    FOR    ${module}    IN    @{pam_modules}
        ${output}=    Run Keyword And Ignore Error    Should Match Regexp    ${output}    ${module}   Some Text
        Append To List    ${module_status_list}    ${module}    ${output}
        Log    ${module_status_list}
    END


Verify that the required PAM Modules are enabled 3
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




Verify Password Expiration Values Have Been Updatedi 2
    [Documentation]    We need to modify the default password aging values in /etc/login.defs
    ${login_defs}    Get File    /etc/login.defs
    &{login_defs_dict}    Create Dictionary    PASS_MAX_DAYS=90    PASS_MIN_DAYS=1    PASS_MIN_LEN=5    PASS_WARN_AGE=5    dummy=5

    ${errors_list}    Create List

    FOR    ${param}    ${expected_value}    IN    &{login_defs_dict}
        ${match}    Get Regexp Matches    ${login_defs}    (?m)^\\s?${param}\\s*(\\d+)    1
        ${number_of_results}    Get Length    ${match}
        IF    ${number_of_results} > 0
            ${match_val}    Set Variable If    ${match[0]}    ${match[0]}
            ${status}    ${status_message}=    Run Keyword And Ignore Error    Should Be Equal As Integers    ${match_val}    ${expected_value}
            Run Keyword If    '${status}' != 'PASS'    Append To List    ${errors_list}    ${param}
        ELSE
            Append To List    ${errors_list}    ${param}
        END
    END

    Log List    ${errors_list}
    Should Be Empty    ${errors_list}    Errors found in values for ${errors_list}



Verify the user account inavtive days value has been modified
    [Documentation]    The default value of INACTIVE in /etc/defaults/useradd needs to be changed from -1 to 90
        ${useradd_conf}    Get File    /etc/default/useradd
        ${match}    Get Regexp Matches    ${useradd_conf}    (?m)^\\s?INACTIVE\\s?\=\\s?(-?\\d+)    1
        ${match_val}    Get From List    ${match}    0
        IF    ${match_val} != 90    Fail    INACTIVE not set to expected value


Verify sshd MaxAuthTries has been modified
    [Documentation]    Customer has requested we modify the MaxAuthTries value from 6 to 5
    ${sshd_conf}    Get File    /etc/ssh/sshd_config
    ${match}    Get Regexp Matches    ${sshd_conf}    (?m)^\\s?MaxAuthTries\\s?(\\d+)    1

Check INACTIVE Value in File
    ${useradd_conf}=    Get File    /etc/default/useradd
    ${match}=    Get Regexp Matches    ${useradd_conf}    (?m)^\\s?INACTIVE\\s?\=\\s?(-?\\d+)    1
    ${match_val}    Set Variable If    ${match}    ${match[0]}    None
    
    Should Be Equal As Strings    ${match_val}    90    INACTIVE not set to expected value

Check MaxAuthTries Value in sshd_config File
    ${useradd_conf}=    Get File    /etc/ssh/sshd_config
    ${match}=    Get Regexp Matches    ${useradd_conf}    (?m)^\\s?MaxAuthTries\\s?(\\d+)    1
    ${match_val}    Set Variable If    ${match}    ${match[0]}    None

    Should Be Equal As Strings    ${match_val}    5    MaxAuthTries not set to expected value

