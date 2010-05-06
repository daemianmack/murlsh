$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

%w{
murlsh
}.each { |m| require m }

describe Murlsh.method(:unwrap_jsonp) do

  subject do
    jsonp = <<eos
jsonp1270266100192 ({
  "key" : {
    "v1" : "value 1",
    "v2" : "value 2"
    }
}
)
eos
    Murlsh::unwrap_jsonp(jsonp)
  end

  it { should == { 'key' => { 'v1' => 'value 1', 'v2' => 'value 2' } } }
end
