require "yaml"

module Teletube
  class Config
    ENDPOINT = "https://tube.switch.ch"
    PATH = Path["~/.teletube.yml"].expand(home: true)

    getter token : String?
    getter endpoint : String?

    def initialize
    end

    protected def initialize(config : YAML::Any?)
      self.attributes = config
    end

    def attributes=(attributes : YAML::Any)
      @token = attributes["token"]? ? attributes["token"].as_s : ""
      @endpoint = attributes["endpoint"]? ? attributes["endpoint"].as_s : ENDPOINT
    end

    def attributes=(attributes : Hash(String, String))
      @token = attributes.fetch("token", "")
      @endpoint = attributes.fetch("endpoint", ENDPOINT)
    end

    def save(path = PATH)
      File.open(path, "wb") do |file|
        file << YAML.dump({ "token" => @token, "endpoint" => @endpoint })
      end
    end

    def self.load(path = PATH)
      Config.new(YAML.parse(File.exists?(path) ? File.read(path) : "{}"))
    rescue e
      raise "Config file is invalid: #{e.message}"
    end
  end
end
