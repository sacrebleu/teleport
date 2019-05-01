# frozen_string_literal: true

describe 'Stats::Authenticator' do
  let(:subject) { Stats::Authenticator }
  let(:test_mo) { '441234567890' } # db fixture

  context 'During authentication' do
    it 'honours ratelimiting rules' do
      expect(subject).to receive(:ratelimited?).and_return(true)
      expect { subject.authorize(test_mo) }.to raise_error(Stats::RateLimited)
    end

    it 'honours login backoff period rules' do
      expect(subject).to receive(:ratelimited?).and_return(false)
      expect(subject).to receive(:backoff?).and_return(true)
      expect { subject.authorize(test_mo) }.to raise_error(Stats::Unauthenticated)
    end

    it 'detects rate limiting and responds appropriately' do
      expect(subject).to receive(:ratelimited?).and_return(false)
      expect(subject).to receive(:backoff?).and_return(false)

      Rails.cache.clear
      expect(Stats::HttpApi).to receive(:authenticate).and_raise(RestClient::TooManyRequests)
      expect { subject.authorize(test_mo) }.to raise_error(Stats::RateLimited)
    end

    it 'generates a session token for successful authentication' do
      expect(subject).to receive(:ratelimited?).and_return(false)
      expect(subject).to receive(:backoff?).and_return(false)

      Rails.cache.clear
      expect(Stats::HttpApi).to receive(:authenticate).and_return('token')
      expect(subject.authorize(test_mo)).to eql(['Bearer token', 200])
    end
  end
end
