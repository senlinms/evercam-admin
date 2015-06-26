Feature: Add vendor

  Background:
    Given I am logged in as admin
    And I am on admin dashboard

  Scenario: Add successfully
    Given I am on vendors page
    When I try to add new vendor
    Then the new vendor should be added