require "json"

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

    def get_channel
      handle_response(@http.get(path: "/api/v1/channels/#{@context.params["id"]}"))
    end

    def update_channel
      handle_response(
        @http.patch(path: "/api/v1/channels/#{@context.params["id"]}", params: @context.params)
      )
    end

    def destroy_channel
      handle_response(
        @http.delete(path: "/api/v1/channels/#{@context.params["id"]}")
      )
    end

    def get_languages
      handle_response(@http.get(path: "/api/v1/languages"))
    end

    def get_profiles_me
      handle_response(@http.get(path: "/api/v1/profiles/me"))
    end

    def encoded_json(params)
      
    end

    def handle_response(response)
      case response.status_code
      when 200
        response.body
      when 404
        "Not found"
      else
        "Failed"
      end
    end
  end
end
