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