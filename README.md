# Ozonetel

Ruby interface for ozonetel APIs

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'ozonetel'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install ozonetel

## Usage

### Setup

require 'ozonetel'

@client = Ozonetel::Client.new(customer, api_key, campaign_name)

### Make an outgoing call

  @client.agent_manual_dial(agent_id, customer_number)

## Requirements

1. httparty

## Contributing

1. Fork it ( https://github.com/[my-github-username]/ozonetel/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
