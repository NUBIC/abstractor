## another shameless steal from forem git://github.com/radar/forem.git
# and https://github.com/spree/spree/blob/master/core/lib/generators/spree/dummy/dummy_generator.rb

require 'rails/generators'
require 'rails/generators/rails/app/app_generator'
require 'active_support/core_ext/hash'

module Abstractor
  class DummyGenerator < Rails::Generators::Base
    desc "Creates blank Rails application and mounts Abstractor"

    def self.source_paths
      paths = self.superclass.source_paths
      paths << File.expand_path('../templates', __FILE__)
      paths << File.expand_path('../templates/environments', __FILE__)
      paths.flatten
    end

    PASSTHROUGH_OPTIONS = [
      :skip_active_record, :skip_javascript, :database, :javascript, :quiet, :pretend, :force, :skip
    ]

    def generate_test_dummy
      opts = (options || {}).slice(*PASSTHROUGH_OPTIONS)
      opts[:database] = 'sqlite3' if opts[:database].blank?
      opts[:force] = true
      opts[:skip_bundle] = true
      opts[:old_style_hash] = true

      puts "Generating dummy Rails application..."
      invoke Rails::Generators::AppGenerator, [ File.expand_path(dummy_path, destination_root) ], opts
    end

    def test_dummy_config
      copy_file "application.html.erb", "#{dummy_path}/app/views/layouts/application.html.erb", :force => true
      template "boot.rb", "#{dummy_path}/config/boot.rb", :force => true
      template "application.rb", "#{dummy_path}/config/application.rb", :force => true
      template "environments/development.rb", "#{dummy_path}/config/environments/development.rb", :force => true
      template "environments/test.rb", "#{dummy_path}/config/environments/test.rb", :force => true
      directory 'setup', "#{dummy_path}/lib/setup"
      copy_file "application.html.erb", "#{dummy_path}/app/views/layouts/application.html.erb", :force => true
      insert_into_file("#{dummy_path}/config/routes.rb", :after => /routes.draw.do\n/) do
        %Q{  resources :moomins, :only => :edit\n}
      end
      insert_into_file("#{dummy_path}/config/routes.rb", :after => /routes.draw.do\n/) do
        %Q{  resources :imaging_exams, :only => :edit\n}
      end
      insert_into_file("#{dummy_path}/config/routes.rb", :after => /routes.draw.do\n/) do
        %Q{  resources :surgeries, :only => :edit\n}
      end
      insert_into_file("#{dummy_path}/config/routes.rb", :after => /routes.draw.do\n/) do
        %Q{  resources :pathology_cases, :only => :edit\n}
      end
      insert_into_file("#{dummy_path}/config/routes.rb", :after => /routes.draw.do\n/) do
        %Q{  resources :encounter_notes, :only => :edit\n}
      end
      insert_into_file("#{dummy_path}/config/routes.rb", :after => /routes.draw.do\n/) do
        %Q{  resources :radiation_therapy_prescriptions, :only => :edit\n}
      end
    end

    def test_dummy_models
      copy_file "article.rb", "#{dummy_path}/app/models/article.rb", :force => true
      copy_file "create_articles.rb", "#{dummy_path}/db/migrate/#{17.hours.ago.utc.strftime("%Y%m%d%H%M%S")}_create_articles.rb", :force => true
      copy_file "moomin.rb", "#{dummy_path}/app/models/moomin.rb", :force => true
      copy_file "create_moomins.rb", "#{dummy_path}/db/migrate/#{16.hours.ago.utc.strftime("%Y%m%d%H%M%S")}_create_moomins.rb", :force => true
      copy_file "surgical_procedure.rb", "#{dummy_path}/app/models/surgical_procedure.rb", :force => true
      copy_file "create_surgical_procedures.rb", "#{dummy_path}/db/migrate/#{15.hours.ago.utc.strftime("%Y%m%d%H%M%S")}_create_surgical_procedures.rb", :force => true
      copy_file "surgical_procedure_report.rb", "#{dummy_path}/app/models/surgical_procedure_report.rb", :force => true
      copy_file "create_surgical_procedure_reports.rb", "#{dummy_path}/db/migrate/#{14.hours.ago.utc.strftime("%Y%m%d%H%M%S")}_create_surgical_procedure_reports.rb", :force => true
      copy_file "imaging_exam.rb", "#{dummy_path}/app/models/imaging_exam.rb", :force => true
      copy_file "create_imaging_exams.rb", "#{dummy_path}/db/migrate/#{13.hours.ago.utc.strftime("%Y%m%d%H%M%S")}_create_imaging_exams.rb", :force => true
      copy_file "surgery.rb", "#{dummy_path}/app/models/surgery.rb", :force => true
      copy_file "create_surgeries.rb", "#{dummy_path}/db/migrate/#{12.hours.ago.utc.strftime("%Y%m%d%H%M%S")}_create_surgeries.rb", :force => true
      copy_file "pathology_case.rb", "#{dummy_path}/app/models/pathology_case.rb", :force => true
      copy_file "create_pathology_cases.rb", "#{dummy_path}/db/migrate/#{11.hours.ago.utc.strftime("%Y%m%d%H%M%S")}_create_pathology_cases.rb", :force => true
      copy_file "encounter_note.rb", "#{dummy_path}/app/models/encounter_note.rb", :force => true
      copy_file "create_encounter_notes.rb", "#{dummy_path}/db/migrate/#{10.hours.ago.utc.strftime("%Y%m%d%H%M%S")}_create_encounter_notes.rb", :force => true
      copy_file "radiation_therapy_prescription.rb", "#{dummy_path}/app/models/radiation_therapy_prescription.rb", :force => true
      copy_file "create_radiation_therapy_prescriptions.rb", "#{dummy_path}/db/migrate/#{1.hour.ago.utc.strftime("%Y%m%d%H%M%S")}_create_radiation_therapy_prescriptions.rb", :force => true
      copy_file "site.rb", "#{dummy_path}/app/models/site.rb", :force => true
      copy_file "create_sites.rb", "#{dummy_path}/db/migrate/#{9.hours.ago.utc.strftime("%Y%m%d%H%M%S")}_create_sites.rb", :force => true
      copy_file "site_category.rb", "#{dummy_path}/app/models/site_category.rb", :force => true
      copy_file "create_site_categories.rb", "#{dummy_path}/db/migrate/#{8.hours.ago.utc.strftime("%Y%m%d%H%M%S")}_create_site_categories.rb", :force => true
      copy_file "create_versions.rb", "#{dummy_path}/db/migrate/#{7.hours.ago.utc.strftime("%Y%m%d%H%M%S")}_create_versions.rb", :force => true
    end

    def test_dummy_controllers
      template "moomins_controller.rb", "#{dummy_path}/app/controllers/moomins_controller.rb", :force => true
      template "imaging_exams_controller.rb", "#{dummy_path}/app/controllers/imaging_exams_controller.rb", :force => true
      template "surgeries_controller.rb", "#{dummy_path}/app/controllers/surgeries_controller.rb", :force => true
      template "pathology_cases_controller.rb", "#{dummy_path}/app/controllers/pathology_cases_controller.rb", :force => true
      template "encounter_notes_controller.rb", "#{dummy_path}/app/controllers/encounter_notes_controller.rb", :force => true
      template "radiation_therapy_prescriptions_controller.rb", "#{dummy_path}/app/controllers/radiation_therapy_prescriptions_controller.rb", :force => true
    end

    def test_dummy_views
      template "views/moomins/edit.html.haml", "#{dummy_path}/app/views/moomins/edit.html.haml", :force => true
      template "views/imaging_exams/edit.html.haml", "#{dummy_path}/app/views/imaging_exams/edit.html.haml", :force => true
      template "views/surgeries/edit.html.haml", "#{dummy_path}/app/views/surgeries/edit.html.haml", :force => true
      template "views/pathology_cases/edit.html.haml", "#{dummy_path}/app/views/pathology_cases/edit.html.haml", :force => true
      template "views/encounter_notes/edit.html.haml", "#{dummy_path}/app/views/encounter_notes/edit.html.haml", :force => true
      template "views/radiation_therapy_prescriptions/edit.html.haml", "#{dummy_path}/app/views/radiation_therapy_prescriptions/edit.html.haml", :force => true
    end

    def test_dummy_assets
      template "application.js", "#{dummy_path}/app/assets/javascripts/application.js", :force => true
    end

    def test_dummy_clean
      inside dummy_path do
        remove_file ".gitignore"
        remove_file "doc"
        remove_file "Gemfile"
        remove_file "lib/tasks"
        remove_file "app/assets/images/rails.png"
        remove_file "public/index.html"
        remove_file "public/robots.txt"
        remove_file "README"
        remove_file "test"
        remove_file "vendor"
        remove_file "spec"
      end
    end

    protected
      def dummy_path
        'test/dummy'
      end

      def lib_name
        'abstractor'
      end

      def module_name
        'Dummy'
      end

      def application_definition
        @application_definition ||= begin
          dummy_application_path = File.expand_path("#{dummy_path}/config/application.rb", destination_root)
          unless options[:pretend] || !File.exists?(dummy_application_path)
            contents = File.read(dummy_application_path)
            contents[(contents.index("module #{module_name}"))..-1]
          end
        end
      end
      alias :store_application_definition! :application_definition

      def gemfile_path
        '../../Gemfile'
      end

      def remove_directory_if_exists(path)
        remove_dir(path) if File.directory?(path)
      end
  end
end