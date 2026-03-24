# frozen_string_literal: true

# Tests for the error-routing logic in PlatformClient::Requests::Base#build_error.
# We exercise it via a minimal concrete subclass so we don't need a real HTTP stack.
RSpec.describe PlatformClient::Requests::Base do
  # ── Minimal concrete subclass ────────────────────────────────────────────────
  subject(:base) { test_class.new }

  let(:test_class) do
    Class.new(described_class) do
      # Expose build_error as a public method for direct testing
      public :build_error
    end
  end
  let(:legacy_body) { { errors: ['Something went wrong'] }.to_json }

  # ── Helpers ──────────────────────────────────────────────────────────────────
  def faraday_client_error(body)
    instance_double(Faraday::ResourceNotFound,
      response_body: body,
      message: 'the server responded with status 404')
  end

  def faraday_server_error(body = nil)
    err = Faraday::ServerError.new('the server responded with status 500')
    allow(err).to receive(:response_body).and_return(body)
    err
  end

  def structured_body(code)
    { errors: [{ code: code, message: 'error', reason: 'REASON', details: {}, request_id: 'req_1' }] }.to_json
  end

  # Current production format — errors as a Hash rather than an Array
  def structured_body_hash_format(code)
    { errors: { code: code, message: 'error', reason: 'REASON', details: {}, request_id: 'req_1' } }.to_json
  end

  # Pre-parsed Array format — as returned by Faraday JSON middleware
  def structured_body_pre_parsed(code)
    { 'errors' => [{ 'code' => code, 'message' => 'error', 'reason' => 'REASON', 'details' => {}, 'request_id' => 'req_1' }] }
  end

  # Pre-parsed Hash format — as returned by Faraday JSON middleware (current production shape)
  def structured_body_pre_parsed_hash_format(code)
    { 'errors' => { 'code' => code, 'message' => 'error', 'reason' => 'REASON', 'details' => {}, 'request_id' => 'req_1' } }
  end

  # ── 5xx → InternalError regardless of body ──────────────────────────────────
  describe 'server errors (5xx)' do
    it 'raises InternalError for a Faraday::ServerError with structured body' do
      expect(base.build_error(faraday_server_error(structured_body('SOME_CODE'))))
        .to be_a(PlatformClient::Errors::InternalError)
    end

    it 'raises InternalError for a Faraday::ServerError with a nil body' do
      expect(base.build_error(faraday_server_error(nil)))
        .to be_a(PlatformClient::Errors::InternalError)
    end

    it 'InternalError is a ClientError (backward compatible)' do
      expect(base.build_error(faraday_server_error)).to be_a(PlatformClient::Errors::ClientError)
    end
  end

  # ── Faraday::ParsingError → InternalError ────────────────────────────────────────────
  describe 'parsing errors (invalid JSON from proxy / middleware)' do
    let(:parsing_error) { Faraday::ParsingError.new('unexpected token at \'invalid json\'') }

    it 'wraps Faraday::ParsingError as InternalError' do
      expect(base.build_error(parsing_error)).to be_a(PlatformClient::Errors::InternalError)
    end

    it 'InternalError is a ClientError (backward compatible)' do
      expect(base.build_error(parsing_error)).to be_a(PlatformClient::Errors::ClientError)
    end
  end

  # ── 4xx structured → specific subclass (Array format) ───────────────────────
  describe 'client errors (4xx) with structured body (Array format)' do
    {
      'RATE_UNAVAILABLE' => PlatformClient::Errors::RateUnavailableError,
      'BOOKING_ERROR' => PlatformClient::Errors::BookingError,
      'CANCELLATION_ERROR' => PlatformClient::Errors::CancellationError,
      'NOT_FOUND' => PlatformClient::Errors::NotFoundError,
      'VALIDATION_ERROR' => PlatformClient::Errors::ValidationError,
    }.each do |code, klass|
      it "routes error_code '#{code}' to #{klass.name.split('::').last}" do
        result = base.build_error(faraday_client_error(structured_body(code)))
        expect(result).to be_a(klass)
      end

      it "#{klass.name.split('::').last} is a ClientError (backward compatible)" do
        result = base.build_error(faraday_client_error(structured_body(code)))
        expect(result).to be_a(PlatformClient::Errors::ClientError)
      end
    end

    it 'falls back to ClientError for an unknown structured error_code' do
      result = base.build_error(faraday_client_error(structured_body('UNKNOWN_CODE')))
      expect(result.class).to eq(PlatformClient::Errors::ClientError)
    end
  end

  # ── 4xx structured → specific subclass (Hash format / current production) ───
  describe 'client errors (4xx) with structured body (Hash format)' do
    {
      'RATE_UNAVAILABLE' => PlatformClient::Errors::RateUnavailableError,
      'BOOKING_ERROR' => PlatformClient::Errors::BookingError,
      'CANCELLATION_ERROR' => PlatformClient::Errors::CancellationError,
      'NOT_FOUND' => PlatformClient::Errors::NotFoundError,
      'VALIDATION_ERROR' => PlatformClient::Errors::ValidationError,
    }.each do |code, klass|
      it "routes error_code '#{code}' to #{klass.name.split('::').last}" do
        result = base.build_error(faraday_client_error(structured_body_hash_format(code)))
        expect(result).to be_a(klass)
      end
    end

    it 'falls back to ClientError for an unknown structured error_code' do
      result = base.build_error(faraday_client_error(structured_body_hash_format('UNKNOWN_CODE')))
      expect(result.class).to eq(PlatformClient::Errors::ClientError)
    end
  end

  # ── 4xx legacy / non-JSON → base ClientError ────────────────────────────────
  describe 'client errors (4xx) with non-structured body' do
    it 'returns a plain ClientError for legacy string-array body' do
      result = base.build_error(faraday_client_error(legacy_body))
      expect(result.class).to eq(PlatformClient::Errors::ClientError)
    end

    it 'returns a plain ClientError for a nil body' do
      result = base.build_error(faraday_client_error(nil))
      expect(result.class).to eq(PlatformClient::Errors::ClientError)
    end

    it 'returns a plain ClientError for an HTML body' do
      result = base.build_error(faraday_client_error('<html>502</html>'))
      expect(result.class).to eq(PlatformClient::Errors::ClientError)
    end
  end

  # ── 4xx structured (pre-parsed Hash) → specific subclass (Faraday JSON middleware) ───────
  describe 'client errors (4xx) with pre-parsed Hash body (Faraday JSON middleware)' do
    {
      'RATE_UNAVAILABLE' => PlatformClient::Errors::RateUnavailableError,
      'BOOKING_ERROR' => PlatformClient::Errors::BookingError,
      'CANCELLATION_ERROR' => PlatformClient::Errors::CancellationError,
      'NOT_FOUND' => PlatformClient::Errors::NotFoundError,
      'VALIDATION_ERROR' => PlatformClient::Errors::ValidationError,
    }.each do |code, klass|
      it "routes '#{code}' to #{klass.name.split('::').last} (Array format, pre-parsed)" do
        result = base.build_error(faraday_client_error(structured_body_pre_parsed(code)))
        expect(result).to be_a(klass)
      end

      it "routes '#{code}' to #{klass.name.split('::').last} (Hash format, pre-parsed)" do
        result = base.build_error(faraday_client_error(structured_body_pre_parsed_hash_format(code)))
        expect(result).to be_a(klass)
      end
    end

    it 'falls back to ClientError for an unknown structured error_code' do
      result = base.build_error(faraday_client_error(structured_body_pre_parsed('UNKNOWN_CODE')))
      expect(result.class).to eq(PlatformClient::Errors::ClientError)
    end
  end
end
