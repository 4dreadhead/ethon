# frozen_string_literal: true

RSpec.describe TelegramApi do
  let(:instance) { described_class.new logger: Logging.logger }

  describe "#set_webhook" do
  let(:request_url) { instance.send :request_url, "setWebhook" }
  let(:url) { rand.to_s }

    before do
      stub_request(:post, request_url).with(
        body: { url: url }.to_json
      ).to_return(
        status: 200,
        body: {}.to_json,
        headers: { "Content-Type": "application/json" }
      )
    end

    subject(:perform) { instance.set_webhook url }

    it "sends setWebhook request" do
      perform
    end
  end
end
