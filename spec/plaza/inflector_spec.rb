require 'spec_helper'
include Plaza

describe Plaza::Inflector do

  describe '#classify' do
    it 'should classify strings with and s at the end' do
      expect(Inflector.classify('foobars ')).to eq 'Foobar'
    end

    it 'should classify strings that end in ies' do
      expect(Inflector.classify('entries')).to eq('Entry')
    end

    it 'should work with underscores' do
      expect(Inflector.classify('targeting_entries')).to eq('TargetingEntry')
      expect(Inflector.classify('events_collections')).to eq('EventsCollection')
    end
  end

  describe '#pluralize' do
    it 'should add s to end of thing' do
      expect(Inflector.pluralize('thing')).to eq('things')
    end

    it 'should change y to ies' do
      expect(Inflector.pluralize('entry')).to eq('entries')
    end

    it 'should not add another s' do
      expect(Inflector.pluralize('things')).to eq('things')
    end
  end

  describe '#singularize' do
    it 'should return singularized random word with s at the end' do
      expect(Inflector.singularize('foobars')).to eq 'foobar'
      expect(Inflector.singularize('intentss')).to eq 'intents'
    end

    it 'should change ies to y' do
      expect(Inflector.singularize('entries')).to eq 'entry'
    end

    it 'should not change ies in middle of word' do
      expect(Inflector.singularize('fiesties ')).to eq 'fiesty'
    end
  end

  describe '#tableize' do
    it 'convert rails examples' do
      expect(Inflector.tableize('RawScaledScorer')).to eq 'raw_scaled_scorers'
      expect(Inflector.tableize('egg_and_ham')).to eq 'egg_and_hams'
      expect(Inflector.tableize('fancyCategory')).to eq 'fancy_categories'
    end
  end

  describe '#underscore' do
    it 'convert rails examples' do
      expect( Inflector.underscore('ActiveModel') ).to eq 'active_model'
      expect( Inflector.underscore('ActiveModel::Errors')).to eq 'active_model/errors'
    end
  end

end
