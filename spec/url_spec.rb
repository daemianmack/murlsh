require 'tempfile'

require 'sqlite3'

require 'murlsh'

describe Murlsh::Url do

  before do
    @db_file = Tempfile.open('murlsh_test_db')

    db = SQLite3::Database.new(@db_file.path)
    db.execute("CREATE TABLE urls (
      id INTEGER PRIMARY KEY,
      time TIMESTAMP,
      url TEXT,
      email TEXT,
      name TEXT,
      title TEXT,
      content_type TEXT,
      via TEXT);
      ")

    ActiveRecord::Base.establish_connection :adapter => 'sqlite3',
      :database => @db_file.path

    @url = Murlsh::Url.new
  end

  after do
    @db_file.close
  end

  it 'should return the url for the title if the title is nil' do
    @url.url = 'http://matthewm.boedicker.org/'
    @url.title = nil

    @url.title.should == @url.url
  end

  it 'should return the url for the title if the title is empty' do
    @url.url = 'http://matthewm.boedicker.org/'
    @url.title = ''

    @url.title.should == @url.url
  end

end
