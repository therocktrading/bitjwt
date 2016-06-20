module BitJWT
  class JWTStub
    attr_reader :crypto, :base_url

    PAYLOAD = {
      'aud' => '/response',
      'data' => {
        'field1' => 'text1',
        'field2' => 'text2'
      }
    }.freeze
    
    STATUS_ERROR = 400.freeze
    PAYLOAD_ERROR = {
      'error' => 'data invalid'
    }.freeze

    def initialize(private_key, url, endpoint)
      @crypto = BitJWT::Crypto.new(private_key)
      @base_url = url + endpoint
    end

    def valid_response
      protocol = BitJWT::Protocol.build_request(crypto, JWTStub::PAYLOAD)
      returned_payload = "#{protocol.header_payload_encoded}.#{protocol.signature_encoded}"
      WebMock.stub_request(:post, base_url)
             .to_return(status: 200, body: returned_payload, headers: {})
    end

    def invalid_response
      protocol = BitJWT::Protocol.build_request(crypto, JWTStub::PAYLOAD)
      returned_payload = "#{protocol.header_payload_encoded}X11111.#{protocol.signature_encoded}"
      WebMock.stub_request(:post, base_url)
             .to_return(status: 200, body: returned_payload, headers: {})
    end

    def protocol_error
      WebMock.stub_request(:post, base_url)
             .to_return(status: STATUS_ERROR, body: PAYLOAD_ERROR.to_json, headers: {})
    end
  end
end
