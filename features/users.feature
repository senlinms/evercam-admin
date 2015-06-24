Feature: Index users
  In order to display users
  As an admin
  I want to be able to access admin section and index users

  Background:
    Given I am logged in as admin
    And I am on admin dashboard
    And there is one regular user

  Scenario: Index users
    When I visit users section
    Then I should see all users

  Scenario: Show user with one camera
    Given that user has one camera
    When I visit users section
    And I choose the user
    Then I should see user details
    And I should see user's cameras