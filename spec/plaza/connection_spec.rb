require 'spec_helper'
require_relative 'support/middleware'

Plaza.configure :connection_spec do
  logger NullLogger.new
  use Example::HelloMiddleware
  use Example::GoodbyeMiddleware
end

describe Plaza::Connection do

  context 'with custom middeware' do
    it 'should run middleware in correct order' do
      stub_request(:get, "http://example.com/").
        with(:headers => {
          'Accept'=>'application/json',
          'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
          'Greetings'=>'HelloGoodbye',
          'X-User-Id'=>''}
        ).to_return(:status => 200, :body => "", :headers => {})
      connection = Plaza::Connection.for(:connection_spec)
      response = connection.get('http://example.com')
      expect(response.headers).to eq( {'Greetings' => 'GoodbyeHello'} )
    end

  end

end
