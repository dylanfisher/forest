require 'json'
require 'aws-sdk-s3'

def lambda_handler(event:, context:)
  region = event['region']
  bucket_name = event['bucket']
  object_path = event['object_path']

  client = Aws::S3::Client.new(region: region)
  resource = Aws::S3::Resource.new(client: client)
  signer = Aws::S3::Presigner.new(client: client)
  s3_source_signed_url = signer.presigned_url(:get_object,
    bucket: bucket_name,
    key: object_path
  )

  bucket = resource.bucket(bucket_name)
  object = bucket.object(object_path)

  ffprobe = `ffprobe -loglevel error -print_format json -show_format -show_streams '#{s3_source_signed_url}'`

  if ffprobe
    status_code = 200
    lambda_json_response = JSON.parse(ffprobe)
  else
    status_code = 500
    lambda_json_response = JSON.generate('Error executing ffprobe command')
  end

  { 
    statusCode: status_code, 
    body: lambda_json_response
  }
end
