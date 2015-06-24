Feature: Index cameras
  In order to display cameras
  As an admin
  I want to be able to access admin section and index cameras

  Background:
    Given I am logged in as admin
    And I am on admin dashboard

  Scenario: Index cameras
    When I visit camera section
    Then I should see all cameras

  Scenario: Show camera
    When I visit camera section
    And I choose a camera
    Then I should see camera details