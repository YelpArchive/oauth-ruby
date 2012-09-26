module OAuth
  module RequestProxy
    def self.available_proxies #:nodoc:
      @available_proxies ||= {}
    end

    def self.proxy(request, options = {})
      return request if request.kind_of?(OAuth::RequestProxy::Base)

      klass = available_proxies[request.class]

      # Search for possible superclass matches.
      if klass.nil?
        #When searching for possible superclass match - we should take the most specific superclass
        #e.g. take the proxy for ActionDispatch::Request even when a proxy for Rack::Request is also available
        klass = request.class.ancestors.map{|ancestor_klass| available_proxies[ancestor_klass]}.compact.first
      end

      raise UnknownRequestType, request.class.to_s unless klass
      klass.new(request, options)
    end

    class UnknownRequestType < Exception; end
  end
end
