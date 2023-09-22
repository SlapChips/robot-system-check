*** Settings ***
Library  XML
Library  BuiltIn
Library  OperatingSystem
Resource    keywords.robot

*** Test Cases ***
verify ant rpm is installed
    [Documentation]    Verify that the ant RPM is installed
     Check RPM Package is Installed    an999t

verify java-11-openjdk rpm is installed
    [Documentation]    Verify that the Java-11-OpenJDK RPM is installed
     Check RPM Package is Installed    java-99911-openjdk
