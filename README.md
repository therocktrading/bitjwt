# BitJWT

Simple JWT Ruby implementation based on Bitcoin secp256k1
inspired by bitjws (https://github.com/deginner/bitjws).

JWT protocol header built on a custom bitcoin algorithm:
```ruby
header = {
    'alg' => 'CUSTOM-BITCOIN-SIGN',
    'kid' => '<bitcoin public address>',
    'typ' => 'JWT'
}
```


## Installation

Add this line to your application's Gemfile:

    gem 'bitjwt'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install bitjwt

## Install bitcoin library

Compile and install libsecp256k1 required by bitcoin-ruby:
(https://github.com/bitcoin/bitcoin/tree/v0.11.0/src/secp256k1)

tag: v0.11.0

commit: d26f951802c762de04fb68e1a112d611929920ba

and place it under your vendor/bitcoin/src/secp256k1/.libs local path

## Usage

```ruby
# import your WIF private key
wif_key = 'L2mvkaTyiZMVZ8kPjBkov6FHbp2AVo8DeuXEZVvH7P19KrtpsJtj'

# or generate a new one using Bitcoin library
wif_key = Bitcoin::Key.generate.to_base58

# instantiate BitJWT crypto object with your private key
crypto = BitJWT::Crypto.new(wif_key)

# define your payload to send
payload =
  {
    'aud' => '/api/audience',
    'data' => {
      'key1' => 'value1',
      'key2' => 0
    }
  }
# 'aud'  relative URL path of your request
# 'data' data to send

#build BitJWT protocol request
request = BitJWT::Protocol.build_request(crypto, payload)

# send request to base URL
begin
    response = request.send('http://service_base_url', 'POST')
    # check returned data contains a valid signature
    if response.verify
        # get your decoded response
        payload = response.payload_to_h
    end
rescue BitJWT::ProtocolError => e
    # e.status  http error status code
    # e.body    application returned error
end
```

## Contributing

1. Fork it ( https://github.com/[my-github-username]/bitjwt/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
