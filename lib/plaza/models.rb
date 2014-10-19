require 'plaza/models/base_model'
require 'plaza/models/restful_model'
require 'plaza/models/error'

module Plaza
  Dir.glob(File.join(File.dirname(__FILE__), "models", "*.rb")).each do |file_name|
    base_name = File.basename(file_name).gsub("\.rb", "")
    const_name = base_name.split('_').collect!{ |w| w.capitalize }.join
    autoload const_name.to_sym, File.join(File.dirname(__FILE__), "models", base_name)
  end
  autoload "ConnectionError", File.join(File.dirname(__FILE__), "models", "error.rb")
  autoload "ResourceInvalid", File.join(File.dirname(__FILE__), "models", "error.rb")
end
