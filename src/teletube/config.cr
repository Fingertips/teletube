require "yaml"

module Teletube
  class Config
    ENDPOINT = "https://tube.switch.ch"
    PATH     = Path["~/.teletube.yml"].expand(home: true)

    getter token : String?
    getter endpoint : String?

    def initialize
    end

    protected def initialize(config : YAML::Any?)
      self.attributes = config
    end

    def attributes=(attributes : YAML::Any)
      @token = attributes["token"].as_s?
      @endpoint = attributes["endpoint"].as_s?
    end

    def attributes=(attributes : Hash(String, String))
      @token = attributes["token"] unless attributes.fetch("token", "").empty?
      @endpoint = attributes["endpoint"] unless attributes.fetch("endpoint", "").empty?
    end

    def endpoint
      @endpoint || ENDPOINT
    end

    def save(path = PATH)
      File.open(path, "wb") do |file|
        file << YAML.dump({"token" => @token, "endpoint" => @endpoint})
      end
    end

    def self.load(path = PATH)
      if File.exists?(path)
        Config.new(YAML.parse(File.read(path)))
      else
        Config.new
      end
    rescue e
      raise "Config file is invalid: #{e.message}"
    end
  end
end
