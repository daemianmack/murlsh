require 'murlsh'

describe Murlsh::SearchGrammar do
  subject { parser }
  let(:parser) { Murlsh::SearchGrammarParser.new }

  context 'when query is the empty string' do
    specify { parser.parse('').content.should == [] }
  end

  context 'when query is a single term' do
    specify { parser.parse('foo').content.should == %w{foo} }
  end

  context 'when query is multiple terms' do
    specify { parser.parse('foo bar').content.should == %w{foo bar} }
  end

  context 'when query has extra whitespace' do
    specify { parser.parse('   foo  bar ').content.should == %w{foo bar} }
  end

  context 'when query has quotes' do
    specify { parser.parse('"foo bar"').content.should == ['foo bar'] }
  end

  context 'when query has quotes and multiple terms' do
    specify {
      parser.parse('"foo bar" derp').content.should == ['foo bar', 'derp']
    }
  end

end
