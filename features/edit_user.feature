Feature: Edit user
  In order to modify users
  As an admin
  I want to be able to edit user's fields and modify permissions

  Background:
    Given I am logged in as admin
    And I am on admin dashboard
    And there is one regular user

  Scenario: Grant admin rights
    Given I am on user's page
    When I try to grant admin rights
    Then the user should become admin