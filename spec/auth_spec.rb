require 'tempfile'

require 'murlsh'

describe Murlsh::Auth do

  before do
    @f = Tempfile.new('murlsh_users_test')

    @a = Murlsh::Auth.new(@f.path)

    @a.add_user('test1', 'test1@test.com', 'secret1')
    @a.add_user('test2', 'test2@test.com', 'secret2')
  end

  after do; @f.close!; end

  it 'should authorize valid credentials' do
    @a.auth('secret1').should == {
      :name => 'test1',
      :email => Digest::MD5.hexdigest('test1@test.com')
      }
    @a.auth('secret2').should == {
      :name => 'test2',
      :email => Digest::MD5.hexdigest('test2@test.com')
      }
  end

  it 'should not authorize invalid credentials' do
    @a.auth('not there').should be_nil
  end

end
