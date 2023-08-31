*** Settings ***
Documentation    The following tests verify the operating system configuration & dependency packages
...    are present in preperation for the Cisco NSO application testing. The checks include:
...    - dependent packages are available
...    - required utilities are present
...    - hostname has been changed
...    - DNS and NTP serviecs are configured and active
...     
...    Refer to the SCDP documentation to address any failed tests.
...    

Resource    ../resources/keywords.robot 

*** Variables ***
@{package_list}    ant    java-11-openjdk    python3    openssl    pam    python3-setuptools
@{utility_list}    tar    gzip    find    ssh-keygen
@{dns_servers}    192.168.1.1    8.8.8.8
@{ntp_servers}    ntp1.trans-ix.nl    leontp2.office.panq.nl
@{nso_fw_ports}   2022    2024    8080    8888 
@{pam_modules}    with-faillock    without-nullok    spam-lock

*** Comments ***

*** Keywords ***


*** Test Cases ***

Verify dependency packages are installed
    [Documentation]    As above without break on first failure
    [Tags]    os    packages
    ${command}    Set Variable    rpm -q
    ${check_string}    Set Variable    not installed
    Iterate Over List and Run Command    ${package_list}    ${command}    ${check_string}

Verify required utilities are available
    [Documentation]    Cisco NSO requires some utilities, this test verfies these binaries exist
    [Tags]    os    packages
    ${command}    Set Variable    which
    ${check_string}    Set Variable    /usr/bin/which: no
    Iterate Over List and Run Command    ${utility_list}    ${command}    ${check_string}

Verify Hostname is not set to localhost
    [Documentation]    Hostname Should not be localhost
    [Tags]    os    dns 
    ${output}    Run    hostnamectl hostname
    Should Not Be Equal As Strings    ${output}    localhost

Verify DNS servers are Configured
    [Documentation]    DNS Servers should be Configured
    [Tags]    os    dns
    ${output}    Run    more /etc/resolv.conf
    FOR    ${dns_server}    IN    @{dns_servers}
        Should Contain    ${output}    ${dns_server}    
    END

Verify NTP servers are Configured
    [Documentation]    NTP Servers should be Configured
    [Tags]    os    ntp 
    ${output}    Run    chronyc sources
    FOR    ${ntp_server}    IN    @{ntp_servers}
        Should Contain    ${output}    ${ntp_server}    
    END

Verify NTP service is active
    [Documentation]    Check that the NTP service is active
    [Tags]    os    ntp 
    ${output}    Run    timedatectl show | grep -Po '(?<=NTPSynchronized=)[^,]+'
    Should Be Equal As Strings    ${output}    yes


