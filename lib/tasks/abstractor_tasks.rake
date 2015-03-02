require 'open-uri'
require 'zip'
require 'fileutils'

namespace :abstractor do
  namespace :setup do
    desc 'Load abstractor system tables'
    task :system => :environment do
      Abstractor::Setup.system
    end

    desc "Setup Stanford CoreNLP library in lib/stanford-corenlp-full-2014-06-16/ directory"
    task :stanford_core_nlp => :environment do
      puts 'Please be patient...This could take a while.'
      file = "#{Rails.root}/lib/stanford-corenlp-full-2014-06-16.zip"
      open(file, 'wb') do |fo|
        fo.print open('http://nlp.stanford.edu/software/stanford-corenlp-full-2014-06-16.zip').read
      end

      file = "#{Rails.root}/lib/stanford-corenlp-full-2014-06-16.zip"
      destination = "#{Rails.root}/lib/"
      puts 'Unzipping...'
      unzip_file(file, destination)

      file = "#{Rails.root}/lib/stanford-corenlp-full-2014-06-16/bridge.jar"
      open(file, 'wb') do |fo|
        fo.print open('https://github.com/louismullie/stanford-core-nlp/blob/master/bin/bridge.jar?raw=true').read
      end
    end

    desc "Custom NLP provider"
    task(custom_nlp_provider: :environment) do
      FileUtils.mkdir_p 'config/abstractor'

template = <<EOS
# Add the actual name of your custom nlp provider.
# Specify the sugestion endpoint per environemnt.
custom_nlp_provider_name:
  suggestion_endpoint:
      development: http://custom-nlp-provider.dev/suggest
      test: http://custom-nlp-provider.test/suggest
      staging: http://custom-nlp-provider-staging.org/suggest
      production: http://custom-nlp-provider.org/suggest
EOS

      if !File.exist?('config/abstractor/custom_nlp_providers.yml')
        File.open('config/abstractor/custom_nlp_providers.yml', 'w+'){ |f|
          f << template
        }
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