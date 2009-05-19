Feature:
  In order that an app can be deployed
  A user
  Should be able to interact with the home page

  Scenario: The home page should be displayed
    Given I am on the home page
    Then I should see "BIVOUAC"
