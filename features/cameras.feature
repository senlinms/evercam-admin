Feature: Index cameras
  In order to display cameras
  As an admin
  I want to be able to access admin section and index cameras

  Scenario: Index cameras
    Given I am logged in as admin
    And I am on admin panel
    When I visit camera section
    Then I should see all cameras