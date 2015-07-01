Feature: Sign up
  In order to have access to evercam applications
  As a visitor
  I want to be able to create my account

  Scenario: Sign up as a regular user
    When I try to access admin dashboard
    Then I am redirected to login page
    When I try to sign up
    Then my user account should be created
    But I still have no access to admin dashboard