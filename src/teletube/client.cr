module Teletube
  class Client
    def initialize(config : Teletube::Config, context : Teletube::Context)
      @config = config
      @context = context
      @http = Teletube::Http.new(@config)
    end

    def get_categories
      handle_response(@http.get(path: "/api/v1/categories"))
    end

    def get_channel
      handle_response(@http.get(path: "/api/v1/channels/#{@context.params["id"]}"))
    end

    def get_channels
      if @context.params.empty?
        handle_response(@http.get(path: "/api/v1/channels"))
      else
        handle_response(@http.get(path: "/api/v1/channels", params: @context.params))
      end
    end

    def create_channel
      response = @http.post(path: "/api/v1/channels", params: @context.params)
      response.body
    end

    def get_languages
      handle_response(@http.get(path: "/api/v1/languages"))
    end

    def get_profiles_me
      handle_response(@http.get(path: "/api/v1/profiles/me"))
    end

    def handle_response(response)
      if response.status_code == 200
        response.body
      else
        "Failed"
      end
    end
  end
end
