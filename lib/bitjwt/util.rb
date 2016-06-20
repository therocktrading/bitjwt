module BitJWT
  class Util
    class << self
      def hex_to_bin(hex)
        [hex].pack('H*')
      end

      def bin_to_hex(bin)
        bin.unpack('H*')[0]
      end

      def base64url_encode(str)
        Base64.encode64(str).tr('+/', '-_').gsub(/[\n=]/, '')
      end
    end
  end
end
