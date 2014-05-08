require 'open-uri'
require 'zip'

namespace :abstractor do
  namespace :setup do
    desc 'Load abstractor system tables'
    task :system => :environment do
      Abstractor::Setup.system
    end

    desc "Setup Stanford CoreNLP library in lib/stanford-core-nlp directory"
    task :stanford_core_nlp => :environment do
      directory = "#{Rails.root}/lib/stanford-core-nlp/"
      Dir.mkdir(directory) unless File.exists?(directory)
      puts 'Please be patient...This could take a while.'
      file = "#{Rails.root}/lib/stanford-core-nlp/stanford-core-nlp-minimal.zip"
      open(file, 'wb') do |fo|
        fo.print open('http://louismullie.com/treat/stanford-core-nlp-minimal.zip').read
      end

      file = "#{Rails.root}/lib/stanford-core-nlp/stanford-core-nlp-minimal.zip"
      destination = "#{Rails.root}/lib/stanford-core-nlp/"
      puts 'Unzipping...'
      unzip_file(file, destination)
    end
  end

  private
    def unzip_file (file, destination)
      Zip::File.open(file) { |zip_file|
       zip_file.each { |f|
         f_path=File.join(destination, f.name)
         FileUtils.mkdir_p(File.dirname(f_path))
         zip_file.extract(f, f_path) unless File.exist?(f_path)
       }
      }
    end
end
