require 'spec_helper'
include Plaza

describe RestfulAdapter do
  context "when resource not found" do
    before do
      stub_request(:get, "#{Plaza.configuration.base_url}/tests/1000.json").to_return(:status=>404, :body=>{"status"=>"404","error"=>"Couldn't find tests with id=10000"}.to_json)
    end

    let(:mock_resource){
      resource = mock("resource", :plural_name=>"tests", :singular_name=>"test")
      resource.stubs(:plaza_config).returns :default
      resource
    }
    let(:adapter){RestfulAdapter.new(mock_resource)}

    it "raises generic exception" do
      expect{adapter.show(1000)}.to raise_error(Plaza::Error)
    end

    it "raises generic exception which exposes status" do
      expect{adapter.show(1000)}.to raise_error{ |error|
        error.should be_a(Plaza::Error)
        error.status.should == 404
        error.message.should =~ /Couldn't find/
      }
    end

  end


  context "when 422 returned on create" do
    before do
      stub_request(:post, "#{Plaza.configuration.base_url}/tests.json").
      with(:body => mock_data.to_json).
      to_return(:status=>422, :body=>{:errors=>{"name"=>["has already been taken"]}}.to_json)
    end

    let(:mock_data){{"test"=>{"name"=> "test", "klass"=> "test"}}}

    let(:mock_resource){
      resource = mock("resource", :plural_name=>"tests", :singular_name=>"test")
      resource.stubs(:plaza_config).returns :default
      resource
    }
    let(:adapter){RestfulAdapter.new(mock_resource)}

    it "raises ResourceInvalid exception" do
      expect{adapter.create(mock_data)}.to raise_error(Plaza::ResourceInvalid)
    end

    it "raises ResourceInvalid exception which exposes status" do
      expect{adapter.create(mock_data)}.to raise_error{ |error|
        error.should be_a(Plaza::ResourceInvalid)
        error.status.should == 422
        error.message.should =~ /has already been taken/
      }
    end

    it "exception exposes errors hash" do
      expect{adapter.create(mock_data)}.to raise_error{ |error|
        error.errors.should be_a(Hash)
        error.errors.should eql({"name"=>["has already been taken"]})
      }
    end

  end

  context "when non-json returned" do
    before do
      stub_request(:get, "#{Plaza.configuration.base_url}/tests.json").to_return(:status=>200, :body=>"<html></html>")
    end

    let(:mock_resource){
      resource = mock("resource", :plural_name=>"tests", :singular_name=>"test")
      resource.stubs(:plaza_config).returns :default
      resource
    }
    let(:adapter){RestfulAdapter.new(mock_resource)}

    it "raises generic exception" do
      expect{adapter.index}.to raise_error(Plaza::Error)
    end

    it "raises generic exception which exposes status" do
      expect{adapter.index}.to raise_error{ |error|
        error.should be_a(Plaza::Error)
        error.status.should == nil
        error.message.should =~ /unexpected token/
      }
    end

  end
end
