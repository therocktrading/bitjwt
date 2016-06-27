module BitJWT
  class Protocol
    attr_reader :header, :payload, :signature

    def initialize(header, payload, signature = nil)
      @header = header
      @payload = payload
      @signature = signature
    end

    def header_to_h
      JSON.parse(header)
    end

    def payload_to_h
      JSON.parse(payload)
    end

    def header_encoded
      Util.base64url_encode(header)
    end

    def payload_encoded
      Util.base64url_encode(payload)
    end

    def header_payload_encoded
      "#{header_encoded}.#{payload_encoded}"
    end

    def signature_encoded
      Util.base64url_encode(signature)
    end

    def build_signature(crypto)
      @signature ||= crypto.sign(header_payload_encoded)
    end

    def send(url, method, raw_response = false)
      connection = Excon.new(url, omit_default_port: true)
      response = connection.request(path: payload_to_h['aud'],
                                    method: method,
                                    headers: {
                                      'Content-Type' => 'application/jose',
                                      'User-Agent' => 'bitjwt_client'
                                    },
                                    body: "#{header_payload_encoded}.#{signature_encoded}")
      raise ProtocolError.new(response.status, response.body) unless (200..299).cover?(response.status)
      return response.body if raw_response
      build_response(response.body)
    end

    def build_response(response)
      header, payload, signature = response.split('.')
      header_decoded = Base64.decode64(header)
      payload_decoded = Base64.decode64(payload)
      signature_decoded = Base64.decode64(signature)
      self.class.new(header_decoded, payload_decoded, signature_decoded)
    end

    def verify
      Crypto.verify(header_payload_encoded, signature, header_to_h['kid'])
    end

    def self.build_request(crypto, payload = {})
      header = default_header.merge({ 'kid' => crypto.bitcoin_address })
      payload = default_payload.merge(payload)
      bitjws = new(header.to_json, payload.to_json)
      bitjws.build_signature(crypto)
      bitjws
    end

    private

    class << self
      def default_header
        {
          'alg' => 'CUSTOM-BITCOIN-SIGN',
          'kid' => '',
          'typ' => 'JWT'
        }
      end

      def default_payload
        {
          'aud'  => '',
          'data' => {},
          'exp'  => Time.now.to_f + 3600,
          'iat'  => Time.now.to_f
        }
      end
    end
  end
end
