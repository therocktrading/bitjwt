require 'spec_helper'
require 'excon'

module BitJWT
  describe BitJWT::Protocol do
    let(:wif_key) { 'L2mvkaTyiZMVZ8kPjBkov6FHbp2AVo8DeuXEZVvH7P19KrtpsJtj' }
    let(:public_key) { '1AyG7DLm14sWEAK1By4seHP33KUQakP3Tc' }
    let(:crypto) { Crypto.new(wif_key) }
    let(:user_payload) {
      {
        'aud' => '/endpoint',
        'data' => 'test'
      }
    }

    context 'initialization' do
      it 'build a valid JWT request' do
        request = Protocol.build_request(crypto, user_payload)
        expect(request.verify).to be_truthy
        header = request.header_to_h
        payload = request.payload_to_h
        # check JWT header
        expect(header).to have_key('alg')
        expect(header).to have_key('kid')
        expect(header).to have_key('typ')
        expect(header['alg']).to eql 'CUSTOM-BITCOIN-SIGN'
        expect(header['kid']).to eql public_key
        expect(header['typ']).to eql 'JWT'
        # check JWT payload
        expect(payload).to have_key('aud')
        expect(payload).to have_key('data')
        expect(payload).to have_key('exp')
        expect(payload).to have_key('iat')
        expect(payload['aud']).to eql user_payload['aud']
        expect(payload['data']).to eql user_payload['data']
      end
    end

    context 'send request' do
      let(:url) { 'http://localhost' }
      let(:request) { Protocol.build_request(crypto, user_payload) }
      let(:peer_wif_key) { 'L13zZXQnhgAHuQ8n5GkSasMitEoHFWxV3MC3xJ4U66NJWt2uyNA2' }
      let(:peer_public_key) { '1CAnfBknvhbrpoRmGjRtZ8WsXjMg22wgLf' }
      let(:jwt_stub) { JWTStub.new(peer_wif_key, url, user_payload['aud']) }

      it 'receive a valid response' do
        jwt_stub.valid_response
        response = request.send(url, 'POST')
        header = response.header_to_h
        payload = response.payload_to_h
        expect(response.verify).to be_truthy
        expect(header['kid']).to eql peer_public_key
        expect(payload['aud']).to eql JWTStub::PAYLOAD['aud']
        expect(payload['data']).to eql JWTStub::PAYLOAD['data']
      end

      it 'receive a raw response' do
        jwt_stub.valid_response
        response = request.send(url, 'POST', true)
        expect(response).to be_a(String)
      end

      it 'receive an invalid response (tampered payload)' do
        jwt_stub.invalid_response
        response = request.send(url, 'POST')
        expect(response.verify).to be_falsey
      end

      it 'receive a protocol error' do
        jwt_stub.protocol_error
        expect{request.send(url, 'POST')}.to raise_error(BitJWT::ProtocolError)
      end

      it 'get explict error from  exception' do
        jwt_stub.protocol_error
        begin
          request.send(url, 'POST')
        rescue BitJWT::ProtocolError => e
          expect(e.status).to eql JWTStub::STATUS_ERROR
          expect(e.body).to eql JWTStub::PAYLOAD_ERROR.to_json
        end
      end
    end
  end
end
