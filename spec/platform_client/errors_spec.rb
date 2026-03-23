# frozen_string_literal: true

RSpec.describe PlatformClient::Errors::ClientError do # rubocop:disable RSpec/SpecFilePathFormat
  # Helpers to build a Faraday-like error double with a given response body
  def faraday_error_with_body(body)
    instance_double(Faraday::ResourceNotFound, response_body: body, message: 'the server responded with status 404')
  end

  def described_error(body)
    described_class.new(faraday_error_with_body(body))
  end

  # ─────────────────────────────────────────────────────────────────────────────
  # Structured (new) format body — errors as Array
  # ─────────────────────────────────────────────────────────────────────────────
  let(:structured_body) do
    {
      errors: [
        {
          code: 'RATE_UNAVAILABLE',
          message: 'No packages with a friendly cancellation policy are found.',
          reason: 'NO_FRIENDLY_CANCEL',
          details: {
            original_error_message: 'No refundable rates found',
            search_criteria: { property_code: 'P123', room_code: 'R456' },
          },
          request_id: 'req_abc-123-xyz',
        }
      ],
    }.to_json
  end

  # Production format — errors as a Hash object (not wrapped in an array)
  let(:structured_body_hash_format) do
    {
      errors: {
        code: 'RATE_UNAVAILABLE',
        message: 'No packages with a friendly cancellation policy are found.',
        reason: 'NO_FRIENDLY_CANCEL',
        details: {
          original_error_message: 'No refundable rates found',
          search_criteria: { property_code: 'P123', room_code: 'R456' },
        },
        request_id: 'req_abc-123-xyz',
      },
    }.to_json
  end

  # Legacy format — errors array contains plain strings
  let(:legacy_body) { { errors: ['Rate is unavailable for the requested parameters.'] }.to_json }

  # ─────────────────────────────────────────────────────────────────────────────
  # #response_body
  # ─────────────────────────────────────────────────────────────────────────────
  describe '#response_body' do
    it 'delegates to the original_error' do
      expect(described_error(structured_body).response_body).to eq(structured_body)
    end

    it 'returns nil when original_error does not respond to response_body' do
      faraday_err = instance_double(Faraday::ResourceNotFound)
      allow(faraday_err).to receive(:try).with(:response_body).and_return(nil)
      expect(described_class.new(faraday_err).response_body).to be_nil
    end
  end

  # ─────────────────────────────────────────────────────────────────────────────
  # #structured?
  # ─────────────────────────────────────────────────────────────────────────────
  describe '#structured?' do
    context 'with structured error body — errors as Array (new format)' do
      it 'returns true' do
        expect(described_error(structured_body)).to be_structured
      end
    end

    context 'with structured error body — errors as Hash (current production format)' do
      it 'returns true' do
        expect(described_error(structured_body_hash_format)).to be_structured
      end
    end

    context 'with legacy string-array error body (old format)' do
      it 'returns false' do
        expect(described_error(legacy_body)).not_to be_structured
      end
    end

    context 'with an HTML body (e.g. nginx error page)' do
      it 'returns false' do
        expect(described_error('<html><body>502 Bad Gateway</body></html>')).not_to be_structured
      end
    end

    context 'with a nil body' do
      it 'returns false' do
        expect(described_error(nil)).not_to be_structured
      end
    end

    context 'with an empty string body' do
      it 'returns false' do
        expect(described_error('')).not_to be_structured
      end
    end

    context 'with malformed JSON body' do
      it 'returns false' do
        expect(described_error('{invalid_json')).not_to be_structured
      end
    end

    context 'with a JSON body that has errors as non-array' do
      it 'returns false' do
        expect(described_error({ errors: 'plain string' }.to_json)).not_to be_structured
      end
    end
  end

  # ─────────────────────────────────────────────────────────────────────────────
  # Structured error accessors — errors as Array (new format)
  # ─────────────────────────────────────────────────────────────────────────────
  describe 'structured error accessors (Array format)' do
    subject(:error) { described_error(structured_body) }

    describe '#error_code' do
      it 'returns the code from the first error object' do
        expect(error.error_code).to eq('RATE_UNAVAILABLE')
      end
    end

    describe '#error_message' do
      it 'returns the message from the first error object' do
        expect(error.error_message).to eq('No packages with a friendly cancellation policy are found.')
      end
    end

    describe '#error_reason' do
      it 'returns the reason from the first error object' do
        expect(error.error_reason).to eq('NO_FRIENDLY_CANCEL')
      end
    end

    describe '#error_details' do
      it 'returns the details hash from the first error object' do
        expect(error.error_details).to eq(
          'original_error_message' => 'No refundable rates found',
          'search_criteria' => { 'property_code' => 'P123', 'room_code' => 'R456' }
        )
      end
    end

    describe '#request_id' do
      it 'returns the request_id from the first error object' do
        expect(error.request_id).to eq('req_abc-123-xyz')
      end
    end
  end

  # ─────────────────────────────────────────────────────────────────────────────
  # Structured error accessors — errors as Hash (current production format)
  # ─────────────────────────────────────────────────────────────────────────────
  describe 'structured error accessors (Hash format)' do
    subject(:error) { described_error(structured_body_hash_format) }

    it 'returns the error_code'    do expect(error.error_code).to eq('RATE_UNAVAILABLE') end
    it 'returns the error_message' do expect(error.error_message).to eq('No packages with a friendly cancellation policy are found.') end
    it 'returns the error_reason'  do expect(error.error_reason).to eq('NO_FRIENDLY_CANCEL') end
    it 'returns the request_id'    do expect(error.request_id).to eq('req_abc-123-xyz') end

    it 'returns the error_details hash' do
      expect(error.error_details).to eq(
        'original_error_message' => 'No refundable rates found',
        'search_criteria' => { 'property_code' => 'P123', 'room_code' => 'R456' }
      )
    end
  end

  # ─────────────────────────────────────────────────────────────────────────────
  # Structured error accessors — old / nil format (return nil gracefully)
  # ─────────────────────────────────────────────────────────────────────────────
  describe 'structured error accessors with non-structured body' do
    subject(:error) { described_error(legacy_body) }

    it 'returns nil for error_code'    do expect(error.error_code).to be_nil end
    it 'returns nil for error_message' do expect(error.error_message).to be_nil end
    it 'returns nil for error_reason'  do expect(error.error_reason).to be_nil end
    it 'returns nil for error_details' do expect(error.error_details).to be_nil end
    it 'returns nil for request_id'    do expect(error.request_id).to be_nil end
  end

  # ─────────────────────────────────────────────────────────────────────────────
  # #message override
  # ─────────────────────────────────────────────────────────────────────────────
  describe '#message' do
    context 'when the body is structured' do
      it 'returns the human-friendly error_message from the Platform API' do
        expect(described_error(structured_body).message).to eq(
          'No packages with a friendly cancellation policy are found.'
        )
      end
    end

    context 'when the body is legacy format' do
      it 'falls back to the original Faraday error message' do
        expect(described_error(legacy_body).message).to eq('the server responded with status 404')
      end
    end

    context 'when the body is nil' do
      it 'falls back to the original Faraday error message' do
        expect(described_error(nil).message).to eq('the server responded with status 404')
      end
    end
  end

  # ─────────────────────────────────────────────────────────────────────────────
  # Memoization — parsed_error_object computed only once
  # ─────────────────────────────────────────────────────────────────────────────
  describe 'memoization' do
    it 'parses the response body only once per error instance' do
      error = described_error(structured_body)

      allow(JSON).to receive(:parse).once.and_call_original

      error.error_code
      error.error_message
      error.error_reason
      error.structured?

      expect(JSON).to have_received(:parse).once
    end
  end
end
