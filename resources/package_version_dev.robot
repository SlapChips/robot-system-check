*** Settings ***
Library    String
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
        Set Variable    ${max_length}    ${required_length}
    END
    ${installed_version}    Pad Version    ${installed_version}    ${max_length}
    ${required_version}    Pad Version    ${required_version}    ${max_length}
    # Need to re-split modifed Pad output:
    @{installed_segments}    Split String    ${installed_version}    .
    @{required_segments}    Split String    ${required_version}    .
    Log To Console    Comparing @{installed_segments} with @{required_segments}
    FOR    ${installed_segment}    ${required_segment}    IN    @{installed_segments}    @{required_segments}
       ${installed_segment}    Convert To Integer    ${installed_segment}
       ${required_segment}    Convert To Integer    ${required_segment}
       Log To Console    Evaluating if ${installed_segment} ${evaluator} ${required_segment}
       ${result}    Run Keyword And Return Status    Evaluate    ${installed_segment} ${evaluator} ${required_segment}
       Log To Console    ${result}
       Exit For Loop If    "${result}" == "True"
    END

    Run Keyword If    "${result}" == "True"    Pass Execution    Package version comparison passed
    ...    ELSE    Fail    Package version comparison failed