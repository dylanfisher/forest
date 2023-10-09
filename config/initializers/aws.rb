Forest.config[:credentials] = Aws::Credentials.new(
  (@s3_access_key_id ||= ENV['AWS_ACCESS_KEY_ID'].presence || Rails.application.credentials&.dig(:s3, :access_key_id)),
  (@s3_secret_access_key ||= ENV['AWS_SECRET_KEY_ID'].presence || Rails.application.credentials&.dig(:s3, :secret_access_key))
)
Forest.config[:aws_bucket] = ENV['S3_BUCKET_NAME'].presence || Rails.application.credentials&.dig(:s3, :bucket)
Forest.config[:aws_region] = ENV['AWS_REGION'].presence || Rails.application.credentials&.dig(:s3, :region)
