$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'murlsh'

describe Murlsh::YamlOrderedHash do

  it 'should generate yaml with hash keys in sorted order' do
    h = {
      'd' => 4,
      'a' => 1,
      'c' => 3,
      'b' => 2,
      }

    h.extend(Murlsh::YamlOrderedHash)

    h.to_yaml.should == <<EOS
--- 
a: 1
b: 2
c: 3
d: 4
EOS
  end

end
