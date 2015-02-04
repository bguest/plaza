require 'spec_helper'
require_relative 'support/middleware'

describe Plaza::Configuration do

  let(:config){Plaza::Configuration.new}

  describe '#use' do
    expected_stack= [
      Example::HelloMiddleware,
      Example::GoodbyeMiddleware,
      Plaza::Middleware::Exceptions,
      Plaza::Middleware::UserId
    ]

    it 'should add middleware to the faraday stack' do
      config.use Example::HelloMiddleware
      config.use Example::GoodbyeMiddleware
      config.middleware.should == expected_stack
    end

    it 'should add middleware if added as a list' do
      config.use Example::HelloMiddleware, Example::GoodbyeMiddleware
      config.middleware.should == expected_stack
    end
  end
end
