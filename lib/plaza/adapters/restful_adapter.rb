class Plaza::RestfulAdapter
  include Plaza::BaseAdapter
  attr_reader :request, :logger

  def initialize(resource)
    @singular_name = resource.singular_name
    @plural_name   = resource.plural_name
    @request = Plaza::Request.new(resource.plaza_config)
    @logger  = Plaza.configuration(resource.plaza_config).logger
  end

  def index(query_params = nil)
    handle_response(request.get(base_url(query_params)))
  end

  def show(id)
    hash = handle_response(request.get(resource_url(id)))
    hash.fetch(@singular_name){hash}
  end

  def update(id, data)
    hash = handle_response(request.put(resource_url(id), data))
    hash.fetch(@singular_name){hash}
  end

  def create(data)
    hash = handle_response(request.post(base_url, data))
    hash.fetch(@singular_name){hash}
  end

  def delete(id)
    hash = handle_response(request.delete(resource_url(id)))
    hash.fetch(@singular_name){hash}
  end

  def has_many(id, relation)
    hash = handle_response(request.get(has_many_url(id,relation)))
    hash.fetch(@singular_name){hash}
  end

  private
  def base_url(query_params = nil)
    url = "#{@plural_name}.json"
    url << "?#{URI.encode_www_form(query_params)}" if query_params
    url
  end

  def resource_url(id)
    "#{base_url.chomp('.json')}/#{id}.json"
  end

  def has_many_url(id, relation)
    "#{resource_url(id).chomp('.json')}/#{relation}.json"
  end

end

