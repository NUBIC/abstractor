require "abstractor/engine"
require 'abstractor/core_ext/string'
ENV['CLASSPATH'] = "$CLASSPATH:#{File.expand_path('../..', __FILE__)}/lib/lingscope/dist/lingscope.jar:#{File.expand_path('../..', __FILE__)}/lib/lingscope/dist/lib/abner.jar"

module Abstractor
end
