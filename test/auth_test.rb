$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'murlsh'

require 'test/unit'

class AuthTest < Test::Unit::TestCase

  def setup
    @f = '/tmp/murlsh_users_test'

    @a = Murlsh::Auth.new(@f)

    @a.add_user('test1', 'test1@test.com', 'secert1')
    @a.add_user('test2', 'test2@test.com', 'secert2')
    @a.add_user('test3', 'test3@test.com', 'secert3')
  end

  def teardown
    File.delete(@f)
  end

  def test_auth_good
    assert_equal({
      :name => 'test1',
      :email => Digest::MD5.hexdigest('test1@test.com') },
      @a.auth('secert1'))
  end

  def test_bad
    assert_equal(nil, @a.auth('not there'))
  end

end
