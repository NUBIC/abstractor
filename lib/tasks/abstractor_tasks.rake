# desc "Explaining what the task does"
# task :abstractor do
#   # Task goes here
# end

namespace :abstractor do
  namespace :setup do
    desc 'Load abstraction schemas (specify file to parse with FILE=myfile.yml) '
    task :abstraction_schemas => :environment do
      file = ENV["FILE"]
      raise "File name has to be provided" if file.blank?
      raise "File does not exist: #{file}" unless FileTest.exists?(file)
      puts 'Little my says not done yet!  Get to work!'
    end

    desc 'Load '
    task :system => :environment do
      # raise "File does not exist: #{file}" unless FileTest.exists?(file)
      Abstractor::Setup.system
    end
  end
end
