@android

Feature: Android - Initial Cucumber Test
    Try cucumber with detox

    Scenario: Android - Test Cucumber
        Given I am login as 'ULP_AGENT'

    Scenario: Android - Test Cucumber - 2
        Given I should see the "welcome" element
        Then I should see the "Open up App.js to start working on your app!" text