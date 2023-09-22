*** Settings ***
Library    Collections

*** Variables ***
# ${actual_version}=    1.1.1
# ${expected_version}=    2.2.3

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
        # Log    ${i}    console=${True}
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

    
    

# Compare Package Versions
#     [Arguments]    ${actual_version}    ${operator}    ${expected_version}
#     ${actual_segments}    Evaluate    "${actual_version}".split('.')
#     ${expected_segments}    Evaluate    "${expected_version}".split('.')
    
#     # Compare each segment until a difference is found
#     ${min_length}    Set    ${len(actual_segments)}
#     ${exp_length}    Set    ${len(expected_segments)}
#     Run Keyword If    ${exp_length} < ${min_length}    Set    ${min_length}    ${exp_length}
    
#     :FOR    ${i}    IN RANGE    ${min_length}
#     \    ${actual_segment}    Get From List    ${actual_segments}    ${i}
#     \    ${expected_segment}    Get From List    ${expected_segments}    ${i}
#     \    ${actual_segment}    Convert To Integer    ${actual_segment}    default=0
#     \    ${expected_segment}    Convert To Integer    ${expected_segment}    default=0
#     \    ${comparison}    Evaluate    ${actual_segment} - ${expected_segment}
    
#     \    Run Keyword If    "${operator}" == ">"    Run Keyword If    ${comparison} <= 0    Return From Keyword    False
#     \    Run Keyword If    "${operator}" == ">="    Run Keyword If    ${comparison} < 0    Return From Keyword    False
#     \    Run Keyword If    "${operator}" == "<"    Run Keyword If    ${comparison} >= 0    Return From Keyword    False
#     \    Run Keyword If    "${operator}" == "<="    Run Keyword If    ${comparison} > 0    Return From Keyword    False
#     \    Run Keyword If    "${operator}" == "=="    Run Keyword If    ${comparison} != 0    Return From Keyword    False

#     # All segments are equal up to the minimum length, check if remaining segments are zero
#     Run Keyword If    ${len(actual_segments)} > ${min_length}    Run Keyword If    ${actual_segments}[${min_length}:] != ['0'] * (${len(actual_segments)} - ${min_length})    Return From Keyword    False
#     Run Keyword If    ${len(expected_segments)} > ${min_length}    Run Keyword If    ${expected_segments}[${min_length}:] != ['0'] * (${len(expected_segments)} - ${min_length})    Return From Keyword    False
    
#     [Return]    True


*** Test Cases ***
Compare Package Versions
    ${operator}     Set Variable    >
    ${actual_version}=    Set Variable    9.1.1.1
    ${expected_version}=    Set Variable    2.2.3
    # Split the package versions inst iterable segments
    ${actual_segments}    Evaluate    "${actual_version}".split('.')
    ${expected_segments}    Evaluate    "${expected_version}".split('.')  
    # Identify how many values are stored in the dotted notation  
    ${min_length}    Get Match Count    ${actual_segments}    *    # naming this min as we will use this to loop over
    ${exp_length}    Get Match Count    ${expected_segments}    *
    # We evaluate if the expected length (exp_length) of package verison is greater 
    # than the actual length (min_length} of the found apckage version if exp_length
    # is greater than min_length we overwrite the min_length value with the value of 
    # exp_length
    ${min_length}     Set Variable If    ${exp_length} < ${min_length}   ${exp_length}
    FOR    ${i}    IN RANGE    ${min_length}
        Log    ${i}    console=${True}
        ${actual_segment}    Get From List    ${actual_segments}    ${i}
        ${expected_segment}    Get From List    ${expected_segments}    ${i}
        ${actual_segment}    Convert To Integer    ${actual_segment}
        ${expected_segment}    Convert To Integer    ${expected_segment}
        ${comparison}    Evaluate    ${actual_segment} - ${expected_segment}
        Run Keyword If    "${operator}" == ">"    Run Keyword If    ${comparison} <= 0    Fail    Package Version is not gt          # Log To Console    1    # Return From Keyword    False
        Run Keyword If    "${operator}" == ">="    Run Keyword If    ${comparison} < 0    Fail    Package Version is not gt or eq    # Log To Console    2    # Return From Keyword    False
        Run Keyword If    "${operator}" == "<"    Run Keyword If    ${comparison} >= 0    Fail    Package Version is not lt          # Log To Console    3    # Return From Keyword    False
        Run Keyword If    "${operator}" == "<="    Run Keyword If    ${comparison} > 0    Fail    Package Version is not lt or eq    # Log To Console    4    # Return From Keyword    False
        Run Keyword If    "${operator}" == "=="    Run Keyword If    ${comparison} != 0   Fail    Package Version is not eq          # Log To Console    5    # Return From Keyword    False
        Log    Missed all evals
    END
    Pass Execution    Package Version Passes

    
Compare Package Versions-2
    ${operator}             Set Variable    >
    ${actual_version}       Set Variable    2.3.1.1
    ${expected_version}     Set Variable    2.2.3

    # Split the package versions into iterable segments
    ${actual_segments}      Evaluate    "${actual_version}".split('.')
    ${expected_segments}    Evaluate    "${expected_version}".split('.')  

    # Identify how many values are stored in the dotted notation  
    ${min_length}           Get Length    ${actual_segments}
    ${exp_length}           Get Length    ${expected_segments}

    # Determine the minimum length between actual and expected versions
    ${min_length}           Set Variable If    ${exp_length} < ${min_length}   ${exp_length}

    FOR    ${i}    IN RANGE    ${min_length}
       ${actual_segment}      Set Variable    ${actual_segments}[${i}]
       ${expected_segment}    Set Variable    ${expected_segments}[${i}]
       ${comparison}          Evaluate    "${actual_segment}" < "${expected_segment}" and -1 or "${actual_segment}" > "${expected_segment}" and 1 or 0

       Run Keyword If    "${operator}" == ">"    Run Keyword If    ${comparison} <= 0    Fail    Package Version is not greater
       Run Keyword If    "${operator}" == ">="    Run Keyword If    ${comparison} < 0    Fail    Package Version is not greater or equal
       Run Keyword If    "${operator}" == "<"    Run Keyword If    ${comparison} >= 0    Fail    Package Version is not less
       Run Keyword If    "${operator}" == "<="    Run Keyword If    ${comparison} > 0    Fail    Package Version is not less or equal
       Run Keyword If    "${operator}" == "=="    Run Keyword If    ${comparison} != 0   Fail    Package Version is not equal

    # If we've reached this point, all segments were equal
       Run Keyword If    ${comparison} != 0    Exit For Loop
    END

    Log    Missed all evals
    
    Pass Execution    Package Version Passes

*** Keywords ***

Compare Package Versions-3
    [Documentation]    Takes dotted decimal package versions and comparies them with a provided operator 
    [Arguments]    ${actual_version}    ${operator}    ${expected_version}
    # ${operator}             Set Variable    >
    # ${actual_version}       Set Variable    9.1
    # ${expected_version}     Set Variable    2.2.3

    # Compare the entire version strings
    ${comparison}    Evaluate    "${actual_version}" < "${expected_version}" and -1 or "${actual_version}" > "${expected_version}" and 1 or 0

    Run Keyword If    "${operator}" == ">"    Run Keyword If    ${comparison} <= 0    Return From Keyword    Package Version is not greater
    Run Keyword If    "${operator}" == ">="    Run Keyword If    ${comparison} < 0    Return From Keyword    Package Version is not greater or equal
    Run Keyword If    "${operator}" == "<"    Run Keyword If    ${comparison} >= 0    Return From Keyword    Package Version is not less
    Run Keyword If    "${operator}" == "<="    Run Keyword If    ${comparison} > 0    Return From Keyword    Package Version is not less or equal
    Run Keyword If    "${operator}" == "=="    Run Keyword If    ${comparison} != 0   Return From Keyword    Package Version is not equal

    Log    Package version comparison passed
    # Pass Execution    Package Version Passes
    Return From Keyword    Package Version Passes
