require "yaml"

module Teletube
  class Config
    PATH = "~/.teletube.yml"

    getter token : String?

    def initialize
    end

    protected def initialize(config : YAML::Any?)
      self.attributes = config
    end

    def attributes=(attributes : YAML::Any)
      @token = attributes["token"]? ? attributes["token"].as_s : ""
    end

    def attributes=(attributes : Hash(String, String))
      @token = attributes["token"]
    end

    def save(path = PATH)
      File.open(path, "wb") do |file|
        file << YAML.dump({ "token" => @token })
      end
    end

    def self.load(path = PATH)
      path = File.expand_path(path)
      Config.new(YAML.parse(File.exists?(path) ? File.read(path) : "{}"))
    rescue e
      raise "Config file is invalid: #{e.message}"
    end
  end
end
