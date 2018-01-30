if ENV['AWS_ACCESS_KEY_ID'].present? &&
   ENV['AWS_SECRET_KEY_ID'].present? &&
   ENV['S3_BUCKET_NAME'].present? &&
   ENV['AWS_REGION'].present?

  Aws.config.update({
    region: ENV['AWS_REGION'],
    credentials: Aws::Credentials.new(ENV['AWS_ACCESS_KEY_ID'], ENV['AWS_SECRET_KEY_ID']),
  })

  S3_BUCKET = Aws::S3::Resource.new.bucket(ENV['S3_BUCKET_NAME'])
end
