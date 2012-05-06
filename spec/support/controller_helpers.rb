module ControllerHelpers

  def self.included(parent)
    super
    parent.send(:before, :all) { controller_class.logger = Logger.new(StringIO.new) }
  end
  
  def controller_class
    TestController
  end

  def request_cache
    @request_cache ||= {}
  end
  
  def request(action = :echo)
    request_cache[action] ||= Rack::MockRequest.new(controller_class.action(action))
  end
  
  def response
    @response ||= nil
  end
  
  def get(action_name, params = {}, path_parameters = {}, others = {})
    @request = request(action_name)
    path_parameters[:version] = 1 unless path_parameters.has_key?(:version)
    params[:action]  = action_name.to_s
    @content = nil
    @response = @request.get('/', {:params => params, 'action_dispatch.request.path_parameters' => path_parameters}.reverse_merge(others))
  end
  
  def post(action_name, params = {}, path_parameters = {}, others = {})
    @request = request(action_name)
    path_parameters[:version] = 1 unless path_parameters.has_key?(:version)
    params[:action]  = action_name.to_s
    @content = nil
    @response = @request.post('/', {:params => params, 'action_dispatch.request.path_parameters' => path_parameters}.reverse_merge(others))
  end
  
  def content
    @content ||= ActiveSupport::JSON.decode(response.body).with_indifferent_access
  end
  
  def set_caching_to(value, &blk)
    caching, RocketPants.caching_enabled = RocketPants.caching_enabled?, value
    blk.call
  ensure
    RocketPants.caching_enabled = caching
  end

end