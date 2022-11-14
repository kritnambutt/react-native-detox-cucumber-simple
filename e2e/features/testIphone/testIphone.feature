@iphone @AP00

Feature: Iphone - Initial Cucumber Test
    Try cucumber with detox

    Scenario: Iphone - Test Cucumber
        Given I am login as 'ULP_AGENT'

    @skip
    Scenario: Iphone - Test Cucumber - 2
        Given I should see the "welcome" element
        Then I should see the "Open up App.js to start working on your app!" text

    Scenario: Iphone - Test Cucumber - 3
        Given I should see the "welcome" element
        Then I should see the "Open up App.js to start working on your app!" text