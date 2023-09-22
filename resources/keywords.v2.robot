*** Settings ***
Library    OperatingSystem
Library  BuiltIn
Library  String
Library    Collections

*** Keywords ***

*** Keywords ***
Compare Package Versions
    [Documentation]    Takes dotted decimal package versions and comparies them with a provided operator 
    [Arguments]    ${actual_version}    ${operator}    ${expected_version}
    # Split the package versions into iterable segments
    ${actual_segments}    Evaluate    "${actual_version}".split('.')
    ${expected_segments}    Evaluate    "${expected_version}".split('.')  
    # Identify how many values are stored in the dotted notation  
    ${min_length}    Get Match Count    ${actual_segments}    *    # naming this min as we will use this to loop over
    ${exp_length}    Get Match Count    ${expected_segments}    *
    # We evaluate if the expected length (exp_length) of package verison is greater 
    # than the actual length (min_length} of the found apckage version if exp_length
    # is greater than min_length we overwrite the min_length value with the value of 
    # exp_length
    IF   ${exp_length} < ${min_length}    Set Variable    ${min_length}     ${exp_length}
    # iterate over min_length and run comparison operation        
    FOR    ${i}    IN RANGE    ${min_length}
        Log    ${i}    console=${True}
        ${actual_segment}    Get From List    ${actual_segments}    ${i}
        ${expected_segment}    Get From List    ${expected_segments}    ${i}
        ${actual_segment}    Convert To Integer    ${actual_segment}
        ${expected_segment}    Convert To Integer    ${expected_segment}
        ${comparison}    Evaluate    ${actual_segment} - ${expected_segment}
        # Uncomment lines below to log errors and debug
        # Log To Console  Actual: ${actual_segment} Expected: ${expected_segment} Comparison ${comparison}
        # Log To Console   Operator selected: ${operator}
        Run Keyword If    "${operator}" == ">"    Run Keyword If    ${comparison} <= 0    Return From Keyword    False
        Run Keyword If    "${operator}" == ">="    Run Keyword If    ${comparison} < 0    Return From Keyword    False
        Run Keyword If    "${operator}" == "<"    Run Keyword If    ${comparison} >= 0    Return From Keyword    False
        Run Keyword If    "${operator}" == "<="    Run Keyword If    ${comparison} > 0    Return From Keyword    False
        Run Keyword If    "${operator}" == "=="    Run Keyword If    ${comparison} != 0    Return From Keyword    False
    END
    # If no failures from above, return positive response
    Return From Keyword    True

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
    FOR    ${item}    IN    ${list}
        ${run_cmd}    Catenate    ${command}    ${item}
        Log    ${run_cmd}
        ${output}    Run    ${run_cmd}
        ${status}    ${status_message}    Run Keyword And Ignore Error    Should Not Contain    ${output}    ${check_string}
        Run Keyword If    '${status}' != 'PASS'    Append To List    ${errors_list}    ${item}
    END
    Should Be Empty    ${errors_list}    Item(S) Not Found : ${errors_list}
