module BitJWT
  class ProtocolError < StandardError
    attr_reader :status, :body

    def initialize(status, body)
      @status = status
      @body = body
    end
  end
end
