require 'digest/md5'
require 'fileutils'
require 'open-uri'
require 'tempfile'

require 'RMagick'

require 'murlsh'

describe Murlsh::ImgStore do

  before(:all) do
    @thumb_dir = File.join(Dir::tmpdir, 'img_store_test')
    FileUtils.mkdir_p @thumb_dir
    @img_store = Murlsh::ImgStore.new(@thumb_dir)
  end

  describe :store_url do

    context 'given a valid image url' do

      before(:all) do
        image_url =
          'http://static.mmb.s3.amazonaws.com/2010_10_8_bacon_pancakes.jpg'
        @local_file = @img_store.store_url(image_url)
        @local_path = File.join(@thumb_dir, @local_file)
      end

      it 'should be named with the md5 sum of its contents' do
        md5 = Digest::MD5.file(@local_path).hexdigest
        @local_file.should == "#{md5}.jpg"
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

  describe :store_img_data do

    context 'given valid image data' do

      before(:all) do
        img_data = open(
          'http://static.mmb.s3.amazonaws.com/2010_10_8_bacon_pancakes.jpg') do |f|
          f.read
        end
        @local_file = @img_store.store_img_data(img_data)
        @local_path = File.join(@thumb_dir, @local_file)
      end

      it 'should be named with the md5 sum of its contents' do
        md5 = Digest::MD5.file(@local_path).hexdigest
        @local_file.should == "#{md5}.jpg"
      end

    end

    context 'given invalid image data' do

      it 'should raise Magick::ImageMagickError' do
        lambda { @img_store.store_img_data('xxx') }.should raise_error(
          Magick::ImageMagickError)
      end

    end

  end

end
