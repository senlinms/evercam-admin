Feature: Index vendors
  In order to display vendors
  As an admin
  I want to be able to access admin section and index vendors

  Background:
    Given I am logged in as admin
    And I am on admin dashboard

  Scenario: Index vendors
    When I visit vendors section
    Then I should see all vendors