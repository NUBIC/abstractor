## shameless steal from forem git://github.com/radar/forem.git
namespace :abstractor do
  namespace :test do
    desc "Generates a dummy app for testing and runs migrations"
    task :dummy_app => [:setup_dummy_app, :generate_dummy_abstractor]

    desc "Setup dummy app"
    task :setup_dummy_app do
      puts "Setting up dummy application ........."
      require 'rails'
      require File.expand_path('../../generators/abstractor/dummy_generator', __FILE__)

      Abstractor::DummyGenerator.start %w(--quiet)
      migration_task  = %Q{bundle exec rake db:migrate}
      system migration_task
    end

    task :generate_dummy_abstractor do
      Dir.chdir('test/dummy') if File.exists?("test/dummy")

      abstractor_generator_task  = %Q{rails generate abstractor:install}
      migration_task  = %Q{bundle exec rake db:migrate}
      abstractor_setup_system_task  = %Q{bundle exec rake abstractor:setup:system}
      task_params = [%Q{ bundle exec rake -f test/dummy/Rakefile db:test:prepare }]

      puts "Setting up Abstractor ........."
      system abstractor_generator_task

      puts "Migrating dummy ........."
      system migration_task

      puts "Setting up Abstractor system ........."
      system migration_task

      # puts "Setting up dictionaries ........."
      # system dictionary_generator_task

      puts "Setting up test database ........."
      system task_params.join(' ')
    end

    desc "Destroy dummy app"
    task :destroy_dummy_app do
      FileUtils.rm_rf "test/dummy" if File.exists?("test/dummy")
    end
  end
end
