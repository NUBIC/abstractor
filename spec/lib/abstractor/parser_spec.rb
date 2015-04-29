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

  it 'detects all ranges' do
    abstractor_text = 'family hx: mother - died from chf, dementia in later years; dad - pancreatic cancer , dm 2 sisters with dm, 1 of those with schizophrenia. dad and sister with parkinsonism. dm, mi in siblings.\nher father had a tremor and was diagnosed with parkinsonism. he was not treated for it. she also has a sister who lives in nursing home that has asymmetric tremor and suspected parkinsonism, but is not being treated either. of note, she also has a hx of schizophrenia that is being treated with ap.'
    parser = Abstractor::Parser.new(abstractor_text)
    expect(parser.range_all(Regexp.escape('parkinsonism')).length).to eq 3
  end
end