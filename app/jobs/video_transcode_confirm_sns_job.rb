# This job simply performs an HTTP GET request to the subscribe URL of an Amazon SNS subscription.
# https://docs.aws.amazon.com/sns/latest/dg/SendMessageToHttp.prepare.html
class VideoTranscodeConfirmSnsJob < ApplicationJob
  def perform(subscribe_url)
    response = Faraday.get(subscribe_url)

    if response.status != 200
      Rails.logger.error { '[Forest][Error] Failed to subscibe to SNS transcode topic.' }
    end
  end
end
