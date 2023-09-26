*** Comments ***
The following utilities are for general system checks to support the testcases

*** Settings ***
Library    OperatingSystem
Library  BuiltIn
Library  String
Library    Collections

*** Keywords ***

Pad Version
    [Arguments]    ${version}    ${length}
    ${segments}    Split String    ${version}    .
    ${segments_length}    Get Length    ${segments}
    ${pad_count}    Evaluate    ${length} - ${segments_length}
    FOR    ${i}    IN RANGE    0    ${pad_count}
        Append To List    ${segments}    0
    END
    ${padded_version}    Catenate    SEPARATOR=.    @{segments}
    [Return]    ${padded_version}

Compare Package Versions
    [Arguments]    ${installed_version}    ${evaluator}    ${required_version}
    [Documentation]    Support all evaluators except single "=""
    @{installed_segments}    Split String    ${installed_version}    .
    @{required_segments}    Split String    ${required_version}    .
    ${installed_length}    Get Length    ${installed_segments}
    ${required_length}    Get Length    ${required_segments}

    # Pad the shorter version with zeros
    ${max_length}    Set Variable    ${installed_length}
    IF    ${required_length} > ${installed_length}
        # Set Variable    ${max_length}    ${required_length}
        ${max_length}    Set Variable    ${required_length}
    END

    ${installed_version}    Pad Version    ${installed_version}    ${max_length}
    ${required_version}    Pad Version    ${required_version}    ${max_length}
    # Need to re-split modifed Pad output:
    @{installed_segments}    Split String    ${installed_version}    .
    @{required_segments}    Split String    ${required_version}    .
    ${iterator}    Set Variable    0
    FOR    ${i}    IN RANGE    0     ${max_length} 
        ${result}    Evaluate    ${installed_segments[${i}]} ${evaluator}= ${required_segments[${i}]}
        IF    "${evaluator}" != "=="
            Exit For Loop If    "${result}" == "False"
            Run Keyword If    "${evaluator}" == ">"    Exit For Loop If    ${installed_segments[${i}]} ${evaluator} ${required_segments[${i}]}    
            Run Keyword If    "${evaluator}" == "<"    Exit For Loop If    ${installed_segments[${i}]} ${evaluator} ${required_segments[${i}]}    
        END
    END
    RETURN    ${result}

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

Iterate Over List and Run Command
    [Documentation]    Iterates through list and runs the provided command, checking that the error string is not in the response
    [Arguments]    ${list}    ${command}    ${check_string}
    Log    ${list}    DEBUG
    ${errors_list}    Create List    # Create empty list to append errors
    FOR    ${item}    IN    @{list}
        ${run_cmd}    Catenate    ${command}    ${item}
        Log    ${run_cmd}
        ${output}    Run    ${run_cmd}
        ${status}    ${status_message}    Run Keyword And Ignore Error    Should Not Contain    ${output}    ${check_string}
        Run Keyword If    '${status}' != 'PASS'    Append To List    ${errors_list}    ${item}
    END
    Should Be Empty    ${errors_list}    Item(S) Not Found : ${errors_list}

