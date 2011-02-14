require 'time'

require 'aws/s3'

module Murlsh

  # Store assets in Amazon S3.
  #
  # Depends on 's3_id', 's3_secret', and 's3_bucket' in config.
  class StoreAsset40S3 < Plugin

    @hook = 'store_asset'

    def self.run(name, data, config)
      if config['s3_id'] and config['s3_secret'] and config['s3_bucket']
        AWS::S3::Base.establish_connection!(
          :access_key_id => config['s3_id'],
          :secret_access_key => config['s3_secret']
        )

        bucket = begin
          AWS::S3::Bucket.find config['s3_bucket']
        rescue AWS::S3::NoSuchBucket
          AWS::S3::Bucket.create config['s3_bucket'], :access => :public_read
        end

        AWS::S3::S3Object.store name, data, bucket.name,
          :access => :public_read,
          # 100 years
          :expires => (Time.now + (31536000000)).httpdate

        AWS::S3::S3Object.url_for(name, bucket.name, :authenticated => false)
      end
    end

  end

end
