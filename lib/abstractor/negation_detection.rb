module Abstractor
  module NegationDetection
    def self.clear_invalid_utf8_bytes(scoped_sentence)
      scoped_sentence = scoped_sentence.encode('UTF-8', 'binary', invalid: :replace, undef: :replace, replace: '')
    end

    def self.parse_negation_scope(sentence)
      parse_results = { :sentence => nil, :scoped_sentence => nil }
      if sentence
        parse_results[:sentence] = sentence
        parse_results[:scoped_sentence] = clear_invalid_utf8_bytes(NegationDetection.parse(sentence))
      end
      parse_results
    end

    def self.negated_match_value?(scoped_sentence, match_value)
      negated = !scoped_sentence.scan('|B-S').empty? && match_value.split(' ').all? do |match_value_token|
        !(scoped_sentence.scan(Regexp.new(match_value_token + '\|I-S')).empty?)
      end
    end

    def self.manual_negated_match_value?(sentence, match_value)
      negated = false
      ['non-','\bthere is no evidence of a ', '\bthere is no evidence of a metastatic ',  '\binsufficient to make the diagnosis of ', '\binsufficient to make the diagnosis of metastatic ',  '\binsufficient for the diagnosis of ',  '\binsufficient for the diagnosis of metastatic ',  '\brule out ', '\brule out metastatic ', '\bnegative for ', '\bnegative for metastatic ',  '\bno ', '\bno metastatic ', '\bnot ', '\bnot metastatic ',  '\bno evidence of ', '\bno evidence of metastatic ',  '\bno evidence of a ', '\bno evidence of a metastatic ',  '\brules out the possibility of a ', '\brules out the possibility of a metastatic ',  '\bto exclude the possibility of ', '\bto exclude the possibility of metastic '].each do |negation_cue|
        if !(sentence.downcase.scan(Regexp.new(negation_cue + match_value.downcase)).empty?)
          negated = true
        end
      end

      [' is not seen\b', ' less likely\b'].each do |negation_cue|
        if !(sentence.downcase.scan(Regexp.new(match_value.downcase + negation_cue)).empty?)
          negated = true
        end
      end

      negated
    end

    def self.parse(sentence)
      `java lingscope.drivers.SentenceTagger scope crf #{File.expand_path('../../', __FILE__)}/lingscope/negation_models/crf_scope_words_all_both.model "#{sentence}"`
    end
  end
end