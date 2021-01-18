aws_access_key_id = ENV['AWS_ACCESS_KEY_ID'].presence || Rails.application.credentials&.dig(:s3, :access_key_id)
aws_secret_key_id = ENV['AWS_SECRET_KEY_ID'].presence || Rails.application.credentials&.dig(:s3, :secret_access_key)
s3_bucket_name = ENV['S3_BUCKET_NAME'].presence || Rails.application.credentials&.dig(:s3, :bucket)
aws_region = ENV['AWS_REGION'].presence || Rails.application.credentials&.dig(:s3, :region)

if aws_access_key_id.present? &&
   aws_secret_key_id.present? &&
   s3_bucket_name.present? &&
   aws_region.present?

  Aws.config.update({
    region: aws_region,
    credentials: Aws::Credentials.new(aws_access_key_id, aws_secret_key_id),
  })

  S3_BUCKET = Aws::S3::Resource.new.bucket(s3_bucket_name)
end
