When /^(?:|I )fill in "([^"]*)" with "([^"]*)" within "(.*?)"$/ do |field, value, parent|
  within(parent) do
    fill_in(field, :with => value)
  end
end

When /^(?:|I )check "([^"]*)" within "(.*?)"$/ do |field, parent|
  within(parent) do
    check(field)
  end
end

When(/^I select "(.*?)" from "(.*?)" within "(.*?)"$/) do |value, field, parent|
  within(parent) do
    select(value, :from => field)
  end
end

When /^I wait for the ajax request to finish$/ do
  start_time = Time.now
  page.evaluate_script('jQuery.isReady&&jQuery.active==0').class.should_not eql(String) until page.evaluate_script('jQuery.isReady&&jQuery.active==0') or (start_time + 5.seconds) < Time.now do
    sleep 1
  end
end

When /^I press "([^\"]*)" within(?: the (first|last))? "([^\"]*)"$/ do |selector, position, scope_selector|
  within_scope(get_scope(position, scope_selector)) {
    click_button(selector)
  }
end

When /^I enter "([^\"]*)" into "([^\"]*)" within(?: the (first|last))? "([^\"]*)"$/ do |value, selector, position, scope_selector|
  within_scope(get_scope(position, scope_selector)) {
    all(selector).should_not be_empty
    all(selector, :visible => true).each{ |e| e.set(value) }
  }
end

When /^I uncheck "([^\"]*)" within(?: the (first|last))? "([^\"]*)"$/ do |selector, position, scope_selector|
  within_scope(get_scope(position, scope_selector)) {
    all(selector).should_not be_empty
    all(selector, :visible => true).each{ |e| e.click }
  }
end

When /^I check "([^\"]*)" within(?: the (first|last))? "([^\"]*)"$/ do |selector, position, scope_selector|
  within_scope(get_scope(position, scope_selector)) {
    all(selector).should_not be_empty
    all(selector, :visible => true).each{ |e| e.click }
  }
end

When /^I focus|click on "([^\"]*)" within(?: the (first|last))? "([^\"]*)"$/ do |selector, position, scope_selector|
  within_scope(get_scope(position, scope_selector)) {
    all(selector).should_not be_empty
    all(selector, :visible => true).each{ |e| e.click }
  }
  steps %Q{
    When I wait 2 seconds
  }
end

When /^I follow "([^\"]*)" within(?: the (first|last))? "([^\"]*)"$/ do |selector, position, scope_selector|
  within_scope(get_scope(position, scope_selector)) {
    steps %Q{
      When I follow "#{selector}"
    }
  }
end

When /^I fill in "([^\"]*)" autocompleter within(?: the (first|last))? "([^\"]*)" with "([^\"]*)"$/ do |selector, position, scope_selector, value|
  within_scope(get_scope(position, scope_selector)) {
    all(selector).should_not be_empty
    all(selector).each{|e| e.set(value)}
    menuitem = '.ui-menu-item a:contains(\"' + value + '\")'
    page.execute_script " $('#{menuitem}').trigger(\"mouseenter\").click();"
  }
end

When /^I select "([^\"]*)" from "([^\"]*)" in(?: the (first|last))? "([^\"]*)"$/ do |value, selector, position, scope_selector|
  within_scope(get_scope(position, scope_selector)) {
    find(selector, :visible => true).should_not be_blank
    find(selector, :visible => true).select(value)
  }
end

When /^I confirm link "([^"]*)"(?: in the(?: (first|last)?) "([^\"]*)")?$/ do |selector, position, scope_selector|
  within_scope(get_scope(position, scope_selector)) {
    page.evaluate_script('window.confirm = function() { return true; }')
    steps %Q{
      When I follow "#{selector}"
    }
  }
end

When /^I confirm "([^"]*)"$/ do |selector|
  page.evaluate_script('window.confirm = function() { return true; }')
  steps %Q{
    When I press "#{selector}"
  }
end

When /^I wait (\d+) seconds$/ do |wait_seconds|
  sleep(wait_seconds.to_i)
end

When /^(?:|I )click within "([^"]*)" \(XPath\)$/ do |selector|
  find(:xpath, selector).click
end

When /^(?:|I )click within first "([^"]*)"$/ do |selector|
  first(selector).click
end

When /^(?:|I )click within "([^"]*)"$/ do |selector|
  find(selector).click
end

When /^(?:|I )press the (?:Enter|Return) key in "([^"]*)"$/ do |field|
  keypress_script = "var e = $.Event('keydown', { keyCode: 13 }); $('##{field}').trigger(e);"
  page.driver.browser.execute_script(keypress_script)
end

# When /^(?:|I )press the (Enter|Return) key in "([^"]*)"$/ do |key, field|
#  find(field).native.send_keys :enter
# end

When /^(?:|I )follow element "([^"]*)"$/ do |path|
  page.find(:xpath, path).click
end

Then(/^I should see "(.*?)" within "(.*?)"$/) do |regexp, selector|
  regexp = Regexp.new(regexp)
  within(selector) do
    if page.respond_to? :should
      page.should have_xpath('//*', :text => regexp, :visible => true )
    else
      assert page.has_xpath?('//*', :text => regexp, :visible => :true)
    end
  end
end

Then(/^I should not see "(.*?)" within "(.*?)"$/) do |regexp, selector|
  regexp = Regexp.new(regexp)
  within(selector) do
    if page.respond_to? :should
      page.should have_no_xpath('//*', :text => regexp, :visible => true )
    else
      assert page.has_no_xpath?('//*', :text => regexp, :visible => true)
    end
  end
end

Then(/^I should see (\d+) "(.*?)" rows$/) do |count, selector|
  all(selector).size.should == count.to_i
end

Then /^the "([^"]*)" field(?: within (.*))? should contain "([^"]*)"$/ do |field, parent, value|
  with_scope(parent) do
    field = find_field(field)
    field.should_not be_blank
    field_value = (field.tag_name == 'textarea' && field.value.blank?) ? field.text : field.value
    if field_value.respond_to? :should
      field_value.should =~ /#{value}/
    else
      assert_match(/#{value}/, field_value)
    end
  end
end

Then /^the "([^"]*)" disabled field(?: within (.*))? should contain "([^"]*)"$/ do |field, parent, value|
  with_scope(parent) do
    field = page.all("#{field}", :visible => true).first
    field.should_not be_blank
    field_value = (field.tag_name == 'textarea' && field.value.blank?) ? field.text : field.value
    if field_value.respond_to? :should
      field_value.should =~ /#{value}/
    else
      assert_match(/#{value}/, field_value)
    end
  end
end

Then /^the "([^"]*)" disabled field(?: within (.*))? should not contain "([^"]*)"$/ do |field, parent, value|
  with_scope(parent) do
    field = page.all("#{field}", :visible => true).first
    field.should_not be_blank
    field_value = (field.tag_name == 'textarea') ? field.text : field.value
    if field_value.respond_to? :should_not
      field_value.should_not =~ /#{value}/
    else
      assert_no_match(/#{value}/, field_value)
    end
  end
end

Then /^the "([^"]*)" radio button(?: within (.*))? should be checked$/ do |label, parent|
  with_scope(parent) do
    field_checked = find_field(label)['checked']
    if field_checked.respond_to? :should
      field_checked.should be_true
    else
      assert field_checked
    end
  end
end

Then /^the "([^"]*)" radio button(?: within (.*))? should not be checked$/ do |label, parent|
  with_scope(parent) do
    field_checked = find_field(label)['checked']
    if field_checked.respond_to? :should
      field_checked.should be_false
    else
      assert !field_checked
    end
  end
end

Then /^(?:|I )should be on (.+)$/ do |page_name|
  uri = URI.parse(current_url)
  current_path = uri.path
  current_path += "?#{uri.query}" unless uri.query.blank?
  if current_path.respond_to? :should
    current_path.gsub(/\?.*$/, '').should == path_to(page_name).gsub(/\?.*$/, '')
  else
    assert_equal path_to(page_name), current_path
  end
end

Then /the element "([^\"]*)" should be hidden$/ do |selector|
  page.evaluate_script("$('#{selector}').is(':hidden');").should be_true
end

Then /the element "([^\"]*)" should not be hidden$/ do |selector|
  page.evaluate_script("$('#{selector}').is(':not(:hidden)');").should be_true
end

Then /^"([^"]*)" should be selected for "([^"]*)"(?: within "([^\"]*)")?$/ do |value, field, selector|
  with_scope(selector) do
    field_labeled(field).find(:xpath, ".//option[@selected = 'selected'][text() = '#{value}']").should be_present
  end
end

Then /^I should see an? "([^"]*)" element$/ do |selector|
  find(selector).should be_present
end

Then /^I should not see an? "([^"]*)" element$/ do |selector|
  page.evaluate_script("$('#{selector}');").should be_empty
end

Then /^the element "([^\"]*)"(?: in the(?: (first|last)?) "([^\"]*)")? should(?: (not))? be visible$/ do |selector, position, scope_selector, negation|
  within_scope(get_scope(position, scope_selector)) {
    if negation.blank?
      all(selector).should_not be_empty
      find(selector).should be_visible
    else
      all(selector, :visible => true).length.should == 0
    end
  }
end

Then /^"([^\"]*)"(?: in the(?: (first|last)?) "([^\"]*)")? should(?: (not))? contain "([^\"]*)"$/ do |selector, position, scope_selector, negation, value|
  within_scope(get_scope(position, scope_selector)) {
    all(selector).should_not be_empty
    if negation.blank?
      all(selector, :visible => true).each{ |e| e.value.should == value}
    else
      all(selector, :visible => true).each{ |e| e.value.should_not == value}
    end
  }
end

Then /^"([^\"]*)"(?: in the(?: (first|last)?) "([^\"]*)")? should(?: (not))? contain selector "([^\"]*)"$/ do |selector, position, scope_selector, negation, inner_selector|
  within_scope(get_scope(position, scope_selector)) {
    if negation.blank?
      all("#{selector} #{inner_selector}").should_not be_empty
    else
      all("#{selector} #{inner_selector}").should be_empty
    end
  }
end

Then /^"([^\"]*)"(?: in the(?: (first|last)?) "([^\"]*)")? should(?: (not))? have "([^\"]*)" selected$/ do |selector, position, scope_selector, negation, value|
  within_scope(get_scope(position, scope_selector)) {
    selector = "#{selector} option[selected='selected']"
    all(selector).should_not be_empty
    if negation.blank?
      all(selector, :visible => true).each{ |e| e.text.should == value }
    else
      all(selector, :visible => true).each{ |e| e.text.should_not == value }
    end
  }
end


Then /^"([^\"]*)"(?: in the(?: (first|last)?) "([^\"]*)")? should(?: (not))? be checked$/ do |selector, position, scope_selector, negation|
  within_scope(get_scope(position, scope_selector)) {
    selector = "#{selector}[checked='checked']"
    if negation.blank?
      all(selector, :visible => true).should_not be_empty
    else
      all(selector, :visible => true).should be_empty
    end
  }
end

Then /^"([^\"]*)"(?: in the (first|last) "([^\"]*)")? should(?: (not))? have options "([^\"]*)"$/ do |selector, position, scope_selector, negation, options|
  within_scope(get_scope(position, scope_selector)) {
    elements = all(selector)
    elements.should_not be_empty
    options.split(', ').each do |o|
      if negation.blank?
        all(selector).each{ |e| e.find(:xpath, ".//option[text()[contains(.,'#{o}')]]").should be_present }
      else
        elements.each{ |e| expect{e.find(:xpath, ".//option[text()[contains(.,'#{o}')]]")}.to raise_error }
      end
    end
  }
end

Then /^"([^\"]*)"(?: in the(?: (first|last)?) "([^\"]*)")? should(?: (not))? contain text "([^\"]*)"$/ do |selector, position, scope_selector, negation, value|
  within_scope(get_scope(position, scope_selector)) {
    all(selector).should_not be_empty
    if negation.blank?
      all(selector, :visible => true).each{ |e| e.should have_content(value) }
    else
      all(selector, :visible => true).each{ |e| e.should_not have_content(value) }
    end
  }
end

def within_scope(locator)
  locator ? within(locator) { yield } : yield
end

def get_scope(position, scope_selector)
  return unless scope_selector
  items = page.all("#{scope_selector}")
  case position
  when 'first'
    item = items.first
  when 'last'
    item = items.last
  else
    item = items.last
  end
  item
end
