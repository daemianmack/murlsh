require 'murlsh'

describe Murlsh::SearchConditions do

  context 'when query is nil' do
    let(:search_conditions) { Murlsh::SearchConditions.new(nil) }
    subject { search_conditions }

    its(:conditions) { should == [] }
  end

  context 'when query is the empty string' do
    let(:search_conditions) { Murlsh::SearchConditions.new('') }
    subject { search_conditions }

    its(:conditions) { should == [] }
  end

  context 'when query is a single term' do
    let(:search_conditions) { Murlsh::SearchConditions.new('foo') }
    subject { search_conditions }

    its(:conditions) { should == [
      'LOWER(name) LIKE ? OR LOWER(title) LIKE ? OR LOWER(url) LIKE ?',
      '%foo%', '%foo%', '%foo%'] }
  end

  context 'when query is multiple terms' do
    let(:search_conditions) { Murlsh::SearchConditions.new('foo bar') }
    subject { search_conditions }

    its(:conditions) { should == [
      'LOWER(name) LIKE ? OR LOWER(name) LIKE ? OR ' +
      'LOWER(title) LIKE ? OR LOWER(title) LIKE ? OR ' +
      'LOWER(url) LIKE ? OR LOWER(url) LIKE ?',
      '%foo%', '%bar%',
      '%foo%', '%bar%',
      '%foo%', '%bar%' ] }
  end

end
