module Plaza
  module Inflector
    extend self

    def singularize(str)
      str.strip!
      str.gsub!(/ies$/,'y')
      str.chomp('s')
    end

    def classify(table_name)
      singularize(table_name.split('_').map(&:capitalize).join)
    end
  end
end
