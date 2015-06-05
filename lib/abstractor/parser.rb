require 'stanford-core-nlp'
module Abstractor
  class Parser
    attr_accessor :sentences, :abstractor_text

    def initialize(abstractor_text, options = {})
      options = { new_line_is_sentence_break: true }.merge(options)
      @abstractor_text = abstractor_text

      if options[:new_line_is_sentence_break]
        StanfordCoreNLP.custom_properties['ssplit.newlineIsSentenceBreak'] = 'always'
      else
        StanfordCoreNLP.custom_properties['ssplit.newlineIsSentenceBreak'] = 'two'
      end

      pipeline =  StanfordCoreNLP.load(:tokenize, :ssplit)
      t = StanfordCoreNLP::Annotation.new(@abstractor_text)
      pipeline.annotate(t)
      if @abstractor_text
        @sentences = t.get(:sentences).to_a.map do |s|
          {
            :range => s.get(:character_offset_begin).to_s.to_i..s.get(:character_offset_end).to_s.to_i,
            :begin_position  => s.get(:character_offset_begin).to_s.to_i,
            :end_position => s.get(:character_offset_end).to_s.to_i,
            :sentence => @abstractor_text[s.get(:character_offset_begin).to_s.to_i..s.get(:character_offset_end).to_s.to_i].downcase
          }
        end
      end
    end

     def scan(token, options = {})
      options[:word_boundary] = true  if options[:word_boundary].nil?
      regular_expression = prepare_token(token, options)
      at = prepare_abstractor_text
      if (regular_expression.nil? || at.nil?)
        []
      else
        at.scan(regular_expression)
      end
    end

    def sentence_scan(sentence, token, options = {})
      options[:word_boundary] = true  if options[:word_boundary].nil?
      regular_expression = prepare_token(token, options)
      if (regular_expression.nil? || sentence.nil?)
        []
      else
        sentence.scan(regular_expression)
      end
    end

    def sentence_match_scan(sentence, token, options = {})
      options[:word_boundary] = true  if options[:word_boundary].nil?
      regular_expression = prepare_token(token, options)
      if (regular_expression.nil? || sentence.nil?)
        []
      else
        # http://stackoverflow.com/questions/6804557/how-do-i-get-the-match-data-for-all-occurrences-of-a-ruby-regular-expression-in
        sentence.to_enum(:scan,regular_expression).map{ Regexp.last_match }
      end
    end

    def match(token)
      regular_expression = prepare_token(token)
      prepare_abstractor_text.match(regular_expression) unless regular_expression.nil?
    end

    def range_all(token, options = {})
      options[:word_boundary] = true  if options[:word_boundary].nil?
      regular_expression = prepare_token(token, options)
      prepare_abstractor_text.range_all(regular_expression) unless regular_expression.nil?
    end

    def match_position(match)
      match.pre_match.size
    end

    def match_sentence(sentence, token)
      regular_expression = prepare_token(token)
      sentence.match(prepare_token(token)) unless regular_expression.nil?
    end

    def find_sentence(range)
      @sentences.detect { |sentence| sentence[:range].include?(range) }
    end

    private
      def prepare_abstractor_text
        @abstractor_text.downcase unless @abstractor_text.nil?
      end

      def prepare_token(token, options = {})
        options[:word_boundary] = true if options[:word_boundary].nil?
        begin
          if options[:word_boundary]
            Regexp.new('\b' + token.downcase + '\b')
          else
            Regexp.new(token.downcase)
          end
        rescue
          nil
        end
      end
  end
end