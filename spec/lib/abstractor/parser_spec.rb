require 'spec_helper'
describe Abstractor::Parser do
  it "parses each new line as a new sentence by default", focus: false do
    text = "Test: 80
            Test2: 90"
    parser = Abstractor::Parser.new(text)
    parser.sentences.size.should == 2
  end

  it "can be instructed to parse each new line as a new sentence", focus: false do
    text = "Test: 80
            Test2: 90"
    parser = Abstractor::Parser.new(text, new_line_is_sentence_break: true)
    parser.sentences.size.should == 2
  end

  it "can be instructed to not parse each new line as a new sentence", focus: false do
    text = "Test: 80
            Test2: 90"
    parser = Abstractor::Parser.new(text, new_line_is_sentence_break: false)
    parser.sentences.size.should == 1
  end
end