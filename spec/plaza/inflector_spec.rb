require 'spec_helper'
include Plaza

describe Plaza::Inflector do

  describe '#singularize' do
    it 'should return singularized random word with s at the end' do
      Inflector.singularize('foobars').should == 'foobar'
      Inflector.singularize('intentss').should == 'intents'
    end

    it 'should change ies to y' do
      Inflector.singularize('entries').should == 'entry'
    end

    it 'should not change ies in middle of word' do
      Inflector.singularize('fiesties ').should == 'fiesty'
    end
  end

  describe '#classify' do
    it 'should classify strings with and s at the end' do
      Inflector.classify('foobars ').should == 'Foobar'
    end

    it 'should classify strings that end in ies' do
      Inflector.classify('entries').should == 'Entry'
    end

    it 'should work with underscores' do
      Inflector.classify('targeting_entries').should == 'TargetingEntry'
      Inflector.classify('events_collections').should == 'EventsCollection'
    end
  end
end
