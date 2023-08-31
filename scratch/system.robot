*** Settings ***
Library  XML
Library    Collections
Library  BuiltIn
Library  String
Library  OperatingSystem
Resource    keywords.robot

*** Variables ***
@{package_list}    ant    java-11-openjdk    python3    openssl    pam    python3-setuptools
@{utility_list}    tar    gzip    find    ssh-keygen
@{dns_servers}    192.168.1.1    8.8.8.8    8.8.4.4
@{ntp_servers}    ntp1.trans-ix.nl    leontp2.office.panq.nl
@{nso_fw_ports}   2022    2024    8080    8888
@{pam_modules}    with-faillock    without-nullok    # spam-lock

*** Test Cases ***

Verify dependancy packages are installed
    [Documentation]    Checks that all the necessary packages are installed
    [Tags]    prereqs    nso 
    FOR    ${package}    IN    @{package_list}
           Check RPM PAckage is Installed    ${package}
           Log    ${package} Installed
	   Log	Some Text:
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
    Should Not Be Equal As Strings    ${output}    robot-dev-00

Verify DNS servers are Configured
    [Documentation]    DNS Servers should be Configured
    [Tags]    nso 
    ${output}    Run    more /etc/resolv.conf
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
    [Tags]    nso    security
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
    ${output}    Run    authselect list
    Should Contain    ${output}    sssd-vf 


Verify Expected Authselect Profile is Active
    ${output}    Run    authselect current -r
    # This runs the command "authselect current -r" and returns the current active profile
    # The test checks that this matches the expected value of custom/sssd-vf
    ${profile}    Set Variable    custom/sssd-vf
    IF    '${profile}' in '${output}'    Pass Execution    Current Profile is correct - sssd-vf    ELSE    Fail    Incorrect, or No, Profile active


Verify that the required PAM Modules are enabled 2
    [Documentation]    This test will verify that without-nullok and with-faillock modules are activated
    [Tags]    security    nso
    ${output}    Run    authselect current
    Log    ${output}
    FOR    ${module}    IN    @{pam_modules}
        Should Match Regexp    ${output}    ${module}
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

Verify that /etc/security/faillock.conf has been modifed
    [Documentation]    Secuirty requirement require us to modify the fail_interval to be 1800 seconds
    [Tags]    security
    ${faillock_conf}    Get File    /etc/security/faillock.conf
    # Log    ${faillock_conf}
    ${all_matches}    Get Regexp Matches  ${faillock_conf}   (?m)^\\s?fail_interval\\s?\=\\s?(\\d+)   1
    ${list_len}    Get Length    ${all_matches}
    IF    ${list_len} > 1    Fail    Configuration Error in file, Too many values returned
    ${faillock_interval}    Get From List    ${all_matches}    0
    IF    ${faillock_interval} < 1800    Fail    Failock interval is set to value < 1800

