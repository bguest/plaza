module Plaza
  module Inflector
    extend self

    def classify(table_name)
      singularize(table_name.split('_').map(&:capitalize).join)
    end

    def pluralize(str)
      str.strip!
      str.gsub!(/y$/,'ies')
      str << 's' unless str[-1] == 's'
      str
    end

    def singularize(str)
      str.strip!
      str.gsub!(/ies$/,'y')
      str.chomp('s')
    end

    def tableize(str)
      pluralize(underscore(str))
    end

    def underscore(str)
      return str unless str =~ /[A-Z-]|::/
      word = str.to_s.gsub(/::/, '/')
      word.gsub!(/([A-Z\d]+)([A-Z][a-z])/,'\1_\2')
      word.gsub!(/([a-z\d])([A-Z])/,'\1_\2')
      word.tr!("-", "_")
      word.downcase!
      word
    end

  end
end
