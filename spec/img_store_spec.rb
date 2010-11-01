%w{
cgi
digest/sha1
fileutils
open-uri
tempfile

murlsh
}.each { |m| require m }

describe Murlsh::ImgStore do

  before(:all) do
    @thumb_dir = File.join(Dir::tmpdir, 'img_store_test')
    FileUtils.mkdir_p(@thumb_dir)
    @img_store = Murlsh::ImgStore.new(@thumb_dir)
  end

  describe :store do

    context 'given a valid image url' do

      before(:all) do
        @image_url =
          'http://static.mmb.s3.amazonaws.com/2010_10_8_bacon_pancakes.jpg'
        @local_file = @img_store.store(@image_url)
        @local_path = File.join(@thumb_dir, @local_file)
      end

      it 'should return the correct filename' do
        @local_file.should == CGI.escape(@image_url)
      end

      it 'should create a local file with the correct contents' do
        sha1 = Digest::SHA1.hexdigest(open(@local_path) { |f| f.read })
        sha1.should == '2749b80537cbf15f1c432c576b4d9e109a8ab565'
      end

    end

    context 'given an image url with an invalid path' do

      it 'should raise OpenURI::HTTPError 404 Not Found' do
        lambda {
          @img_store.store('http://matthewm.boedicker.org/does_not_exist') }.
          should raise_error(OpenURI::HTTPError, '404 Not Found')
      end

    end

  end

end
