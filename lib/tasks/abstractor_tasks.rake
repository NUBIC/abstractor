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
      puts 'Please be patient...This could take a while.'
      file = "#{Rails.root}/lib/stanford-corenlp-full-2014-01-04.zip"
      open(file, 'wb') do |fo|
        fo.print open('http://nlp.stanford.edu/software/stanford-corenlp-full-2014-01-04.zip').read
      end

      file = "#{Rails.root}/lib/stanford-corenlp-full-2014-01-04.zip"
      destination = "#{Rails.root}/lib/"
      puts 'Unzipping...'
      unzip_file(file, destination)

      file = "#{Rails.root}/lib/stanford-corenlp-full-2014-01-04/bridge.jar"
      open(file, 'wb') do |fo|
        fo.print open('https://github.com/louismullie/stanford-core-nlp/blob/master/bin/bridge.jar').read
      end
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