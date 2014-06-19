#!/usr/bin/env rake
begin
  require 'bundler/setup'
  require 'cucumber/rake/task'
  require 'rspec/core/rake_task'
  require 'rubygems/package_task'
end

gemspec = eval(File.read('abstractor.gemspec'), binding, 'abstractor.gemspec')
Gem::PackageTask.new(gemspec).define
APP_RAKEFILE = File.expand_path("../test/dummy/Rakefile", __FILE__)
$:.unshift File.join(File.dirname(__FILE__), 'spec','support')
load 'rails/tasks/engine.rake' if File.exists?(APP_RAKEFILE)
load 'lib/tasks/abstractor_tasks.rake'
load 'test/lib/tasks/abstractor_test_tasks.rake'
RSpec::Core::RakeTask.new(:spec)
task :default => :spec

namespace :cucumber do
  Cucumber::Rake::Task.new(:wip, 'Run features that are being worked on') do |t|
    t.profile = 'wip'
  end

  Cucumber::Rake::Task.new(:features) do |t|
    t.cucumber_opts = "features --format pretty"
  end
end

task :cucumber => 'cucumber:features'