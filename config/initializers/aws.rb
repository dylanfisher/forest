aws_access_key_id = ENV['AWS_ACCESS_KEY_ID'].presence || Rails.application.credentials&.dig(:aws, :aws_access_key_id)
aws_secret_key_id = ENV['AWS_SECRET_KEY_ID'].presence || Rails.application.credentials&.dig(:aws, :aws_secret_key_id)
s3_bucket_name = ENV['S3_BUCKET_NAME'].presence || Rails.application.credentials&.dig(:aws, :s3_bucket_name)
aws_region = ENV['AWS_REGION'].presence || Rails.application.credentials&.dig(:aws, :aws_region)

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
