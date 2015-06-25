Feature: Dashboard
  In order to have general overview
  As an admin
  I want to be able to access dashboard and see basic stats

  Background:
    Given I am logged in as admin

  Scenario: One user with one camera
    Given there is one new user
    And the user has one camera
    When I am on admin dashboard
    Then I should see indicators
    And I should see kpi
    And I should see new cameras
    And I should see new users
