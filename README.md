# Plaza

_Because rest areas are more fun with a service plaza_

Plaza is a client side gem that works with [RestArea][1] to provide an ActiveRecord like experience
in dealing with a JSON rest API. Plaza uses [Virtus][2] and [Faraday][3] under the hood to access a
json api, so most things that work with those projects will also work with Plaza.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'plaza'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install plaza

## Usage

### Creating a Plaza Model

Rest API backed plaza models can be created like any other class, here's an example

```ruby
require 'plaza'

class Thing
  include Plaza::RestfulModel

  attribute :name, String
  attribute :amajig_id, Integer

  has_many :amabobs
end
```

See [Virtus][2] for more information on configuring attributes.

### Configuring Plaza

At some point before you use a Plaza model, you need to configure Plaza, at the bare minimum you
need to tell plaza the base url to use for the rest_area api. You can optionally configure the
logger that plaza models will use.

```ruby
Plaza.configure do
  base_url    'http://www.example.com/rest' # Required
  logger      Logger.new(STDOUT)            # Default
  cache_store MemoryStore.new               # Default, recommend `Rails.cache` for rails apps
end
```

#### Cache Store

The store where cached responses are stored, for rails apps we recommend that you just set this
to `Rails.cache`. Plaza uses [Faraday Http Cache][4] for caching, refer to their documentation for
more information on what the store can be.

#### Multiple Services

If your plaza models need to connect to multiple services with different base urls, they can be
configured as such:

```ruby
Plaza.configure :my_first_service do
  base_url 'http://www.first_example.com/rest'
end

Plaza.configure :my_second_service do
  base_url 'http://www.later_example.com/rest'
end

class Amabob
  include Plaza::RestfulModel
  plaza_config :my_first_service  # <-- This tells the model to use the :my_first_service configuration

  attribute :thing_id, Integer
end
```

### Using Plaza Models

You can:

Create new models: `my_thing = Thing.new(:name => 'Fred')` (not persisted to api)

Create models: `my_thing = Thing.create(:name => 'Bob')`. This results in an POST api call like
`POST http://example.com/rest/things`

Find existing models: `my_thing = Thing.find(10)`. This results in a GET API call like `GET
http://example.com/things/10`

Pass query string to API: `Thing.were(:name = 'bob')`. This results in an api call like `GET
http://example.com/rest/things?name=bob`. Returns an array.

Update model attributes: `my_thing.name = 'Kevin'`

Save new or update existing models: `my_thing.save`. This results in either a PUT or POST to the api
depending on if `my_thing.id` is `nil` or not.

Delete Models: `my_thing.delete`

Get associated objects: `amabobs_array = my_thing.amabobs`. This requires that you define the
   `has_many` relationship in the class definition. (See Thing definition above)

Get related models for which you have the foreign key: `my_thing = a_mabob.thing`
Note on this: If you ask a rest model for a attribute and it doesn't have it, but it has the
same attribute with an underscore id, it's smart enough to know thats a foreign key and go off and
fetch the related rest model.

Want to know more, go checkout the code, the guts of it are located at
`lib/plaza/models/restfull_model.rb`

## Contributing

1. Fork it ( https://github.com/[my-github-username]/plaza/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Add Specs!
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## STD (Stuff To Do) before 1.0.0

3. Add Ability to customize Faraday Stack from configuration
4. Add Support for messages (see rest_area)

[1]:https://github.com/bguest/rest_area
[2]:https://github.com/solnic/virtus
[3]:https://github.com/lostisland/faraday
[4]:https://github.com/plataformatec/faraday-http-cache
