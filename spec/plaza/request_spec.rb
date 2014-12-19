require 'spec_helper'
include Plaza

describe Request do

  context 'when Thread.current[:x_user_id] is set' do

    before do Thread.current[:x_user_id] = 4242 end

    %i(get post put delete).each do |method|
      it "##{method} should add X-User-Id to headers" do
        stub_request(method, "http://example.com/foobar").
          with(:headers => {
            'Accept'=>'application/json',
            'X-User-Id'=>'4242'}).
          to_return(:status => 200, :body => "", :headers => {})

        Request.new.send(method, '/foobar')
      end
    end

  end

  context 'when Thread.current[:x_user_id] is not set' do

    %i(get post put delete).each do |method|
      it "##{method} should now add X-User-Id to headers" do
        stub_request(method, "http://example.com/foobar").
          with(:headers => {
            'Accept'=>'application/json',
            'User-Agent'=>'Faraday v0.9.0'}).
          to_return(:status => 200, :body => "", :headers => {})

        Request.new.send(method, '/foobar')
      end
    end

  end

  context "when trucker service is down" do
    %i(get put post delete).each do |method|
      describe "#{method}" do
        before do
          stub_request(method, "http://example.com/failblog").
            to_raise(Faraday::Error::ConnectionFailed.new('Connection Failed'))
        end

        let(:response){Request.new.send(method, '/failblog')}

        it 'response code should be 503' do
          expect{response}.to raise_error(Plaza::ConnectionError)
        end

        it 'should have error message' do
          expect{response}.to raise_error { |error|
            error.should be_a(Plaza::ConnectionError)
            error.message.should == "Service is not available."
          }
        end
      end
    end
  end

end

