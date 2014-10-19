require 'spec_helper'

class Thing
  include Plaza::RestfulModel

  attribute :id, Integer
  attribute :name, String
  attribute :amajig_id, Integer
end

class Amajig
  include Plaza::RestfulModel

  has_many :things, :amabobs
  attribute :name
end

Plaza.configure :amabob do
  base_url 'http://www.example.com/rest'
  logger   NullLogger.new # Specs should STFU
end

class Amabob
  include Plaza::RestfulModel
  plaza_config :amabob

  attribute :amajig_id, Integer
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
      expect(amajig.amabobs.first.class).to be Amabob
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

