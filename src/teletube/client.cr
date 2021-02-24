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

    def create_upload
      response = @http.post(path: "/api/v1/channels/#{@context.params["channel_id"]}/uploads")
      response.body
    end

    def perform_upload
      instructions = JSON.parse(create_upload)
      response = perform_file_upload(instructions)
      case response.status_code
      when 200..399
        @context.params["secret"] = instructions["secret"].as_s
        create_video
      else
        "Upload failed with status code #{response.status_code}"
      end
    end

    def perform_file_upload(instructions)
      uri = URI.parse(instructions["url"].as_s)
      http = HTTP::Client.new(uri: uri)
      body = IO::Memory.new
      builder = HTTP::FormData::Builder.new(body)
      instructions["params"].as_h.each do |name, value|
        builder.field(name, value)
      end
      filename = @context.filename || ""
      metadata = HTTP::FormData::FileMetadata.new(File.basename(filename))
      File.open(filename: filename) do |file|
        builder.file("file", file, metadata)
      end
      builder.finish

      headers = HTTP::Headers.new
      headers["Content-Type"] = builder.content_type

      http.exec(
        headers: headers,
        method: instructions["method"].as_s.upcase,
        path: uri.path.empty? ? "/" : uri.path,
        body: body.to_s
      )
    end

    def create_video
      handle_response(@http.post(path: "/api/v1/uploads/#{@context.params["secret"]}/videos"))
    end

    def get_languages
      handle_response(@http.get(path: "/api/v1/languages"))
    end

    def get_profiles_me
      handle_response(@http.get(path: "/api/v1/profiles/me"))
    end

    def handle_response(response)
      case response.status_code
      when 200, 201
        response.body
      when 404
        "Not found"
      else
        "Failed"
      end
    end
  end
end
