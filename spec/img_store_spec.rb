require 'cgi'
require 'digest/md5'
require 'fileutils'
require 'open-uri'
require 'tempfile'

require 'murlsh'

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
        @local_file = @img_store.store_url(@image_url)
        @local_path = File.join(@thumb_dir, @local_file)
      end

      it 'should return the correct filename' do
        @local_file.should == '089d0d10e322c3afb6dbfc2106f76e31.jpg'
      end

      it 'should create a local file with the correct contents' do
        md5 = Digest::MD5.hexdigest(open(@local_path) { |f| f.read })
        md5.should == '089d0d10e322c3afb6dbfc2106f76e31'
      end

    end

    context 'given an image url with an invalid path' do

      it 'should raise OpenURI::HTTPError 404 Not Found' do
        lambda {
          @img_store.store_url('http://matthewm.boedicker.org/does_not_exist') }.
          should raise_error(OpenURI::HTTPError, '404 Not Found')
      end

    end

  end

end
