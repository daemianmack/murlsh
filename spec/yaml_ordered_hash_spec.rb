%w{
murlsh
}.each { |m| require m }

describe Murlsh::YamlOrderedHash do

  subject do
    h = {
      'd' => 4,
      'a' => 1,
      'c' => 3,
      'b' => 2,
      }

    h.extend(Murlsh::YamlOrderedHash)
  end
  
  its(:to_yaml) { should == <<EOS
--- 
a: 1
b: 2
c: 3
d: 4
EOS
  }

end
