*** Settings ***
Library    OperatingSystem
Library  BuiltIn
Library  String
Library    Collections

*** Keywords ***

Get Regexp Matches For Key Value Pairs in File
    [Documentation]    Iterates through Dict and searches for Key,Value pairs in file
    [Arguments]    ${dict}     ${file_path}
    Log    ${dict}
    Log    ${file_path}
    ${file}    Get File    ${file_path}    # Read in the supplied file
    ${errors_list}    Create List    # Create empty list to append errors
    FOR    ${key}    ${value}    IN    &{dict}
        ${match}    Get Regexp Matches    ${file}    (?m)^\\s?${key}\\s*=?\\s?(-?\\d+)    1
        ${number_of_results}    Get Length    ${match}
        IF    ${number_of_results} > 0
            ${match_val}    Set Variable If    ${match[0]}    ${match[0]}
            ${status}    ${status_message}=    Run Keyword And Ignore Error    Should Be Equal As Integers    ${match_val}    ${value}
            Run Keyword If    '${status}' != 'PASS'    Append To List    ${errors_list}    ${key}
        ELSE
            Append To List    ${errors_list}    ${key}
        END
    END
    Should Be Empty    ${errors_list}    Errors found in values for ${errors_list}
