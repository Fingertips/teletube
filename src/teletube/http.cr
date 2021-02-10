require "uri"
require "json"
require "http/client"

module Teletube
  class Http
    def initialize(config : Teletube::Config)
      uri = URI.parse(config.endpoint)
      @http = HTTP::Client.new(
        host: uri.host || "localhost",
        port: uri.port || 500,
        tls: uri.scheme == "https"
      )
      @headers = HTTP::Headers.new
      @headers["Authorization"] = "Token #{config.token}"
      @headers["Accept"] = "application/json,*/*"
    end

    def get(path : String)
      @http.get(path: path, headers: @headers)
    end

    def get(path : String, params : Hash(String, String))
      @http.get(path: "#{path}?#{HTTP::Params.encode(params)}", headers: @headers)
    end

    def post(path : String, params : Hash(String, String))
      @http.post(path: path, headers: @headers, body: HTTP::Params.encode(params))
    end
  end
end
