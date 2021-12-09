require "uri"
require "json"
require "http/client"

module Teletube
  class Http
    def initialize(config : Teletube::Config)
      @config = config
      @http = HTTP::Client.new(uri: URI.parse(config.endpoint))
      @headers = HTTP::Headers.new
      @headers["Authorization"] = "Token #{config.token}"
      @headers["Accept"] = "application/json,*/*"
      @headers["Content-Type"] = "application/json; charset=utf-8"
    end

    def get(path : String)
      @http.get(path: path, headers: @headers)
    end

    def get(path : String, params : Hash(String, JSON::Any))
      params = params.each_with_object({} of String => String) do |(name, value), h|
        h[name] = value.as_s
      end
      @http.get(path: "#{path}?#{HTTP::Params.encode(params)}", headers: @headers)
    end

    def head(path : String, headers : HTTP::Headers)
      all = @headers.dup
      headers.each { |name, value| all[name] = value }
      @http.head(path: path, headers: all)
    end

    def post(path : String)
      @http.post(path: path, headers: @headers)
    end

    def post(path : String, params : Hash(String, JSON::Any))
      @http.post(path: path, headers: @headers, body: params.to_json)
    end

    def post(path : String, headers : HTTP::Headers)
      all = @headers.dup
      headers.each { |name, value| all[name] = value }
      @http.post(path: path, headers: all)
    end

    def post(path : String, headers : HTTP::Headers, body : HTTP::Client::BodyType)
      all = @headers.dup
      headers.each { |name, value| all[name] = value }
      @http.post(path: path, headers: all, body: body)
    end

    def patch(path : String, params : Hash(String, JSON::Any))
      @http.patch(path: path, headers: @headers, body: params.to_json)
    end

    def patch(path : String, headers : HTTP::Headers, body : HTTP::Client::BodyType)
      all = @headers.dup
      headers.each { |name, value| all[name] = value }
      @http.patch(path: path, headers: all, body: body)
    end

    def delete(path : String)
      @http.delete(path: path, headers: @headers)
    end

    def reset
      @http.close
      @http = HTTP::Client.new(uri: URI.parse(@config.endpoint))
    end
  end
end
