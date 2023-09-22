*** Settings ***
Resource    keywords.robot



*** Test Cases ***
Verify login.defs has been modifed
    [Documentation]    Password expiration values need to be modified in the /etc/login.defs file
    ${dict}    Create Dictionary    PASS_MAX_DAYS=90    PASS_MIN_DAYS=1    PASS_MIN_LEN=5    PASS_WARN_AGE=5    dummy=5
    ${file_path}    Set Variable    /etc/login.defs
    Get Regexp Matches For Key Value Pairs in File    ${dict}    ${file_path}

