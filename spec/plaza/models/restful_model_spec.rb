require 'spec_helper'

class Thing
  include Plaza::RestfulModel

  attribute :id, Integer
  attribute :name, String
  attribute :amajig_id, Integer
end

Plaza.configure :foobar do
  base_url 'http://www.example.com/rest'
  logger   NullLogger.new # Specs should STFU
end

module Foobar
  class Amabob
    include Plaza::RestfulModel
    plaza_config :foobar

    has_many 'Foobar::Amajing'
    attribute :amajing_id, Integer
  end

  class Amajing
    include Plaza::RestfulModel
    plaza_config :foobar
  end
end

class Amajig
  include Plaza::RestfulModel

  has_many :things, Foobar::Amabob
  attribute :name
end

describe Thing do

  let(:things_hash){
    {
      'things'=>[
        {
          'id' => 1,
          'name' => 'Thing 1'
        },
        {
          'id' => 2,
          'name' => 'Thing 2'
        }
      ]
    }
  }

  let(:thing_hash){
    {
      'thing' => {
        'id' => 1,
        'name' => 'Thing One',
        'amajig_id' => 2
      }
    }
  }

  let(:amajig_hash){
    {
      'amajig' => {
        'id' => 2,
        'name'=>'Jigger'
      }
    }
  }

  let(:amabob_hash){
    {
      'amabob' => {
        'id' => 3,
        'amajing_id' => 2
      }
    }
  }

  let(:amabobs_hash){
    {
      'amabobs' =>[
        {
          'id' => 3,
          'amajig_id' => 2
        },
        {
          'id' => 4,
          'amajig_id' => 2
        }
      ]
    }
  }

  let(:amajings_hash){
    {
      'amajings'=>[
        {
          'id'=> 5,
          'amabob_id'=> 4
        },
        {
          'id'=> 6,
          'amabob_id'=> 4
        }
      ]
    }
  }

  describe 'attributes' do
    it{ should respond_to :errors }

    it 'should raise NoMethodError for unknown method' do
      expect{ Thing.new(id:10).foobar }.to raise_error NoMethodError
    end
  end

  describe '.all' do
    before do
      stub_request(:get, 'http://example.com/rest/things.json').to_return(body: things_hash.to_json)
    end

    it 'should return the correct number of things' do
      expect(Thing.all.count).to eq 2
    end

    it 'should return things of class Thing' do
      expect(Thing.all.first.class).to eq Thing
    end

    it 'should return things with the correct attribures' do
      expect(Thing.all.first.name).to eq 'Thing 1'
    end
  end

  describe '#plaza_config / plaza_config' do
    it 'should be able to set in class definition' do
      expect(Thing.new.plaza_config).to eq :default
    end
    it 'should be able to set plaza_config' do
      Thing.plaza_config = :custom
      expect(Thing.new.plaza_config).to eq :custom
      Thing.plaza_config = :default
    end
  end

  describe '.create(attributes)' do
    before do
      hash = {'thing'=> {'id'=>nil,'name'=>'Thing One', 'amajig_id' => 2}}
      stub_request(:post, 'http://example.com/rest/things.json').with(body:hash.to_json).to_return(body: thing_hash.to_json)
    end

    it 'should post new object and return thing object' do
      stub_request(:post, "http://example.com/rest/things.json").
         with(:body => "{\"thing\":{\"name\":\"Thing One\",\"amajig_id\":2}}",
              :headers => {'Accept'=>'application/json', 'Content-Type'=>'application/json'}).
         to_return(:status => 200, :body => thing_hash.to_json, :headers => {})
      thing = Thing.create(:name => 'Thing One', :amajig_id => 2)
      expect(thing.name).to eq 'Thing One'
      expect(thing.id).to eq 1
    end
  end

  describe '.find(id)' do
    before do
      stub_request(:get, 'http://example.com/rest/things/1.json').to_return(body:thing_hash.to_json)
    end

    it 'should return thing with correct attributes' do
      thing = Thing.find(1)
      expect(thing.id).to eq 1
      expect(thing.name).to eq 'Thing One'
    end

    context 'when service is down' do
      it 'should return approprate error' do
        stub_request(:get, 'http://example.com/rest/things/1.json').
          to_raise(Faraday::Error::ConnectionFailed.new('Connection Failed'))

        expect{Thing.find(1)}.to raise_error(Plaza::ConnectionError)
      end
    end

    context 'with caching' do
      it 'second request should be cached and not hit server' do
        stub_request(:get, 'http://www.example.com/rest/amabobs/3.json').to_return(
          headers: {'Cache-Control' => 'max-age=200'},
          body:amabob_hash.to_json
        ).times(1).then.to_raise('Cache Not Working')
        Foobar::Amabob.find(3)
        expect{ Foobar::Amabob.find(3) }.not_to raise_error
      end
    end
  end

  describe '.where()' do
    it 'should attempt to get list of things that meet where clause' do
      stub_request(:get, 'http://example.com/rest/things.json?name=fred&id=3').to_return(body:things_hash.to_json)
      things = Thing.where(name:'fred', id:3)
      things.count.should == 2
    end
  end

  describe '#delete' do
    it 'should attempt to delete object with same id' do
      stub_request(:delete, 'http://example.com/rest/things/3.json').to_return(body:thing_hash.to_json)
      thing = Thing.new(id:3, name:'Cake')
      thing.delete
    end
  end

  describe '#save' do
    context 'when thing does not have id' do
      it 'should update it' do
        return_hash = {'thing' => {'id' => 42, 'name' => 'New Thing', 'amajig_id'=>2 }}
        stub_request(:post, 'http://example.com/rest/things.json').to_return(body: return_hash.to_json)
        thing = Thing.new(name:'New Thing')
        thing.save
        expect(thing.id).to eq 42
      end

      it 'should clear errors on subsequent saves' do
        valid_name = 'New Thing'
        error_hash = {body: {'errors'=>{name: 'must be more than 5 characters'}}.to_json, status: 422}
        valid_hash = {body: {name: valid_name}.to_json, status: 200}
        stub_request(:post, 'http://example.com/rest/things.json').to_return(error_hash, valid_hash ) #multiple response for same call, happens in order
        thing = Thing.new(name:valid_name[0..3])
        expect(thing.save).to be_falsey
        expect(thing.errors).not_to be_empty
        thing.name=valid_name
        thing.save
        expect(thing.save).to be_truthy
        expect(thing.errors).to be_empty
      end


    end

    context 'when thing has an id' do
      it 'should attempt to PUT update thing with things id' do
        stub_request(:put, 'http://example.com/rest/things/1.json').with(body: thing_hash.to_json).to_return(body: thing_hash.to_json)
        thing = Thing.new(thing_hash['thing'])
        thing.save
      end
    end
  end

  describe 'update attributes' do
    it 'should update the attributes' do
      thing = Thing.new(thing_hash['thing'])
      stub_request(:put, "http://example.com/rest/things/1.json").
         with(:body => "{\"thing\":{\"id\":1,\"name\":\"Thing Two\",\"amajig_id\":2}}").
         to_return(:status => 200, :body => "{\"thing\":{\"id\":1,\"name\":\"Thing Two\",\"amajig_id\":2}}", :headers => {})
      thing.update_attributes({:name => "Thing Two"})
      thing.name.should == "Thing Two"
    end
  end

  describe 'belongs_to relations' do
    it 'get related object' do
      thing = Thing.new(thing_hash['thing'])
      stub_request(:get, 'http://example.com/rest/amajigs/2.json').to_return(body:amajig_hash.to_json)
      thing.amajig.name.should == 'Jigger'
    end

    it 'should get reltated object in module' do
      bob = Foobar::Amabob.new(amabob_hash['amabob'])
      stub_request(:get, 'http://www.example.com/rest/amajings/2.json').to_return(body:amabobs_hash.to_json)
      bob.amajing.class.name.should == 'Foobar::Amajing'
    end
  end

  describe 'has_many relationships' do
    it 'gets first has_many relationships' do
      amajig = Amajig.new(amajig_hash['amajig'])
      stub_request(:get, 'http://example.com/rest/amajigs/2/things.json').to_return(body:things_hash.to_json)
      expect(amajig.things.first.class).to be Thing
    end

    it 'gets second has_many relationships' do
      amajig = Amajig.new(amajig_hash['amajig'])
      stub_request(:get, 'http://example.com/rest/amajigs/2/amabobs.json').to_return(body:amabobs_hash.to_json)
      expect(amajig.amabobs.first.class).to be Foobar::Amabob
    end

    it 'gets string has_many relationships' do
      amabob = Foobar::Amabob.new(id:4)
      stub_request(:get, 'http://www.example.com/rest/amabobs/4/amajings.json').to_return(body:amajings_hash.to_json)
      expect(amabob.amajings.first.class).to be Foobar::Amajing
    end
  end

  describe 'error messages' do
    it 'should return an empty array' do
      thing = Thing.new(thing_hash['thing'])
      thing.stubs(:errors).returns({})
      thing.error_messages == {}
    end

    it 'should return an error message' do
      thing = Thing.new(thing_hash['thing'])
      thing.stubs(:errors).returns({:kpi => ["no name"]})
      thing.error_messages == ["kpi no name"]
    end
  end

  describe 'symbolize keys' do
    it 'should return symbolized keys' do
      thing = Thing.new(thing_hash['thing'])
      thing.symbolize_keys({"id" => 2, "name" => "test"}).should == {:id=>2, :name=>"test"}
    end
  end

end

