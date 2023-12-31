*** Settings ***
<<<<<<< HEAD
Resource    ../resources/keywords.robot 
Library    OperatingSystem
Library    String
Library    Collections
*** Variables ***
@{package_list}    ant    java-11-openjdk    python3    openssl    pam    python3-setuptools
${packages_dict}    Create Dictionary    ant=1.9.3    java-11-openjdk=1.1    python3=3.7    openssl=${None}    pam=1.3.1.8    python3-setuptools=${None}    
@{utility_list}    tar    gzip    find    ssh-keygen
@{dns_servers}    192.168.1.1    8.8.8.8    8.8.4.4
=======
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
>>>>>>> 6df037e29425fc157735f8446a00cc4b7004e57b
@{ntp_servers}    ntp1.trans-ix.nl    leontp2.office.panq.nl
@{nso_fw_ports}   2022    2024    8080    8888 
@{pam_modules}    with-faillock    without-nullok    spam-lock

<<<<<<< HEAD

=======
>>>>>>> 6df037e29425fc157735f8446a00cc4b7004e57b
*** Comments ***

*** Keywords ***

<<<<<<< HEAD
*** Test Cases ***

Verify dependency packages are installed
    [Documentation]    Check the installed packages using the "rpm -q" command against a list of expected
    ...    packages, add and remove packages form the list to modify the test case.
    ...    List included : ${package_list}
=======

*** Test Cases ***

Verify dependency packages are installed
    [Documentation]    As above without break on first failure
>>>>>>> 6df037e29425fc157735f8446a00cc4b7004e57b
    [Tags]    os    packages
    ${command}    Set Variable    rpm -q
    ${check_string}    Set Variable    not installed
    Iterate Over List and Run Command    ${package_list}    ${command}    ${check_string}

<<<<<<< HEAD
Verify required package are and package versions
    [Documentation]    Check the versions of the packages installed meets the neccessary minimum values
    ...    the test calls the packages_dict dictionary which should be populated with k,v pairs representing 
    ...    the required package and the minimum supported value
    ...    

    FOR   ${key}    ${value}    IN    &{packages_dict}
        Log    ${key}:${value}    DEBUG
        ${package}    Run    rpm -q ${key}
        ${installed_version}    Get Regexp Matches    ${package}    ${key}-(.*)-.*    1
        ${required_version}    Get From Dictionary    ${packages_dict}    ${key}
        

    END



Check library availability
    [Documentation]    Cisco NSO requires that the operating system has specific libraries installed 
    ...    the test verifies that the "ldconfig -p" output includes each of the libraries mentioned in the 
    ...    documentation. To adapt modify the list 
    ${libraries}     Create List    libpam.so.0    libexpat.so.1    libz.so.1
    ${system_libraries}    Run    ldconfig -p
    ${error_list}    Create List
    FOR    ${library}    IN    @{libraries}
        ${status}    ${status_message}    Run Keyword And Ignore Error    Should Contain    ${system_libraries}    ${library}
        IF    '${status}' == 'PASS'
            Log    ${library} found
        ELSE
            Append To List    ${error_list}    ${library}
        END
    END
    Should Be Empty    ${error_list}    Following Libraries are missing ${error_list}

Check libz library version
    [Documentation]    Cisco NSO requires a minimimum version of 1.2.7.1 for the libz library
    ...    this test will verify that the verison installed satisfies this requirement.
    ${desired_major_version}    Set Variable    1.2
    ${desired_minor_version}    Set Variable    7.1
    ${libz_version}   Run    python3 -c "import zlib; print (zlib.ZLIB_VERSION)"
    ${found_major_version}    Get Regexp Matches    ${libz_version}    ^(\\d+\\.\\d+)\\.(.*)    1
    ${found_minor_version}    Get Regexp Matches    ${libz_version}    ^(\\d+\\.\\d+)\\.(.*)    2
    IF    ${found_major_version[0]} == ${desired_major_version}
        Log To Console    Going to evaluate : ${found_minor_version[0]} > ${desired_minor_version}
        ${log}    Evaluate    ${found_minor_version[0]} > ${desired_minor_version}
        Log To Console    ${log}
        IF    ${found_minor_version[0]} >= ${desired_minor_version}
            Log    Found ${found_major_version[0]}.${found_minor_version[0]} is greater than minimum
            Pass Execution    Major meets requirements, and Minor is greater or equal ${found_major_version[0]}.${found_minor_version[0]}
        ELSE
            Log    Found ${found_major_version[0]}.${found_minor_version[0]} this is lower than expected
            Fail    Unsupported version of Libz found ${found_major_version[0]}.${found_minor_version[0]}
        END
    ELSE IF    ${found_major_version[0]} > ${desired_major_version}
        Log    Found ${found_major_version} is greater than minimum, skipping minor check
        Pass Execution    Major version is greater that required , skipping minor check. 
    ELSE
        Fail    Unsupported version of Libz found ${found_major_version[0]}.${found_minor_version[0]}
    END

=======
>>>>>>> 6df037e29425fc157735f8446a00cc4b7004e57b
Verify required utilities are available
    [Documentation]    Cisco NSO requires some utilities, this test verfies these binaries exist
    [Tags]    os    packages
    ${command}    Set Variable    which
    ${check_string}    Set Variable    /usr/bin/which: no
    Iterate Over List and Run Command    ${utility_list}    ${command}    ${check_string}

<<<<<<< HEAD
Verify correct version of Python is activates
    [Documentation]    We require a python verison > 3.7 this test will validatre the 
    ...    active python environmnet meets this requirement 
    ...    
    [Tags]    os    packages
    ${python_version}    Run    python --version
    ${python_major_version}    Get Regexp Matches    ${python_version}    Python (\\d+\.\\d+)
    ${desired_version}    Set Variable    3.8
    ${status}    Evaluate    ${python_major_version[0]} >= ${desired_version} 
    Run Keyword If    ${status} == 'PASS'
    ...    Pass Execution    Active Version of Python meets the minimum requirements
    ...    ELSE    Fail    Active Python verison doesnt meet the requirements, review your alternatives-config to see if 
    ...    correct version is active, or install the correct verison.

=======
>>>>>>> 6df037e29425fc157735f8446a00cc4b7004e57b
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

<<<<<<< HEAD
=======

>>>>>>> 6df037e29425fc157735f8446a00cc4b7004e57b
