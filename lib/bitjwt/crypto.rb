require 'bitcoin'

module BitJWT
  class Crypto
    def initialize(private_key)
      @key = Bitcoin::Key.from_base58(private_key)
    end

    def bitcoin_address
      @key.addr
    end

    def sign(data)
      bsm = Bitcoin.bitcoin_signed_message_hash(data)
      signature = Bitcoin::Secp256k1.sign_compact(bsm, Util.hex_to_bin(@key.priv))
      Base64.strict_encode64(signature)
    end

    def self.verify(data, signature_base64, pub_address)
      pubkey = Bitcoin::Key.recover_compact_signature_to_key(data, signature_base64)
      pubkey.addr == pub_address
    end
  end
end
