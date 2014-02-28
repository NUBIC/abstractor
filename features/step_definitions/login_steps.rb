Given /^I log out/ do
  steps %Q{
    Given I follow "Logout"
  }
end

Given /^I log in as "([^"]*)"$/ do |username|
  steps %Q{
    When I go to the login page
    And I wait 1 seconds
    And I fill in "username" with "#{username}"
    And I fill in "password" with "#{username}"
    And I press "Log in"
  }
end

When /^user "([^"]*)" is deactivated$/ do |username|
  person = Person.find_by_username(username)
  person.deleted_at = Time.now
  person.save!
end
