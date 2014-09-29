require 'spec_helper'
describe Abstractor::Parser do
  it "parses each new line as a new sentence by default", focus: false do
    text = "Test: 80
            Test2: 90"
    parser = Abstractor::Parser.new(text)
    expect(parser.sentences.size).to eq(2)
  end

  it "can be instructed to parse each new line as a new sentence", focus: false do
    text = "Test: 80
            Test2: 90"
    parser = Abstractor::Parser.new(text, new_line_is_sentence_break: true)
    expect(parser.sentences.size).to eq(2)
  end

  it "can be instructed to not parse each new line as a new sentence", focus: false do
    text = "Test: 80
            Test2: 90"
    parser = Abstractor::Parser.new(text, new_line_is_sentence_break: false)
    expect(parser.sentences.size).to eq(1)
  end
end