require 'spec_helper'
require 'json'
require 'base64'

module BitJWT
  describe BitJWT::Crypto do
    let(:wif_key) { 'L2mvkaTyiZMVZ8kPjBkov6FHbp2AVo8DeuXEZVvH7P19KrtpsJtj' }
    let(:public_key) { '1AyG7DLm14sWEAK1By4seHP33KUQakP3Tc' }
    let(:crypto) { Crypto.new(wif_key) }
    let(:data) { JSON.generate(data: 'test') }

    it 'import a valid WIF key' do
      expect(crypto.bitcoin_address).to eql public_key
    end

    it 'generate a valid Base64 strict signature' do
      signature = crypto.sign(data)
      expect(signature).not_to include('\n')
    end

    it 'verify signature to recover right public key' do
      signature = crypto.sign(data)
      expect(Crypto.verify(data, signature, public_key)).to be_truthy
    end
  end
end
