# frozen_string_literal: true

describe 'Stats::HttpApi' do
  class MockBody
    attr_reader :code, :body

    def initialize(code, body)
      @code = code
      @body = body
    end
  end

  let(:subject) { Stats::HttpApi }
  let(:test_mo) { '12345' }
  let(:url) { WhatsappUrl.generate(test_mo, '/users/login') }
  let(:token) { 'testtoken' }
  let(:successful_auth) do
    {
      body: {
        'users' => [{ 'token' => token }]
      }
    }
  end

  context 'During authentication' do
    it 'Generates a bearer auth token' do
      expect(subject).to receive(:post).with(url, an_instance_of(String)).and_return([:ok, successful_auth])

      res = subject.authenticate(test_mo, 'fred', 'flintstone')
      expect(res).to eql(token)
    end

    it 'checks the number raises an exception if authentication fails' do
      expect(Rails.cache).to receive(:write).with("authfail/#{test_mo}", true, expires_in: 1.minutes)
      expect(subject).to receive(:post).with(url, an_instance_of(String)).and_return([:error, ''])

      expect { subject.authenticate(test_mo, 'fred', 'flintstone') }.to raise_error(Stats::Unauthenticated)
    end
  end

  context 'When getting values' do
    it 'wraps successful responses with an :ok code' do
      expect(subject).to receive(:call).with('/test', :get, '123').and_return(MockBody.new(200, { a: :b }.to_json))
      code, res = subject.get('/test', '123')
      expect(code).to eql(:ok)
      expect(res[:code]).to eql(200)
    end

    it 'honours requests for a raw response' do
      expect(subject).to receive(:call).with('/test', :get, '123').and_return(MockBody.new(200, '123'))
      code, res = subject.get('/test', '123', expects: 200, format: :raw)
      expect(code).to eql(:ok)
      expect(res[:code]).to eql(200)
      expect(res[:body]).to eql('123')
    end

    it 'wraps errors as a struct with an :error code' do
      expect(subject).to receive(:call).with('/test', :get, '123').and_return(MockBody.new(401, '{}'))
      code, res = subject.get('/test', '123')
      expect(code).to eql(:error)
      expect(res[:code]).to eql(401)
    end

    it 'rescues from an unauthenticated exception' do
      expect(subject).to receive(:call).with('/test', :get, '123').and_raise(RestClient::Unauthorized)
      code, res = subject.get('/test', '123')
      expect(code).to eql(:error)
      expect(res[:code]).to eql(401)
      expect(res[:body]).to eql('Unauthorized')
    end
  end

  context 'When posting values' do
    it 'wraps successful responses with an :ok code' do
      expect(subject).to receive(:call).with('/test', :post, '123').and_return(MockBody.new(200, { a: :b }.to_json))
      code, res = subject.post('/test', '123')

      expect(code).to eql(:ok)
      expect(res[:code]).to eql(200)
    end

    it 'honours requests for a raw response' do
      expect(subject).to receive(:call).with('/test', :post, '123').and_return(MockBody.new(200, '123'))
      code, res = subject.post('/test', '123', expects: 200, format: :raw)

      expect(code).to eql(:ok)
      expect(res[:code]).to eql(200)
      expect(res[:body]).to eql('123')
    end

    it 'wraps errors as a struct with an :error code' do
      expect(subject).to receive(:call).with('/test', :post, '123').and_return(MockBody.new(401, '{}'))
      code, res = subject.post('/test', '123')

      expect(code).to eql(:error)
      expect(res[:code]).to eql(401)
    end

    it 'rescues from an unauthenticated exception' do
      expect(subject).to receive(:call).with('/test', :post, '123').and_raise(RestClient::Unauthorized)
      code, res = subject.post('/test', '123')

      expect(code).to eql(:error)
      expect(res[:code]).to eql(401)
      expect(res[:body]).to eql('Unauthorized')
    end
  end
end
