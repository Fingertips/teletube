require "spec"
require "../spec_helper"

CONFIG_PATH = File.expand_path("spec/files/config.yml", Dir.current)
TMP_CONFIG_PATH = File.expand_path("spec/tmp/config.yml", Dir.current)

describe Teletube::Config do
  before_each do
    FileUtils.mkdir_p("spec/tmp")
  end

  after_each do
    FileUtils.rm_rf("spec/tmp")
  end

  it "loads from a file" do
    config = Teletube::Config.load(CONFIG_PATH)
    config.token.should eq("cb70c152644b832148c5ca5410f30d30")
    config.endpoint.should eq("https://staging.tube.switch.ch")
  end

  it "updates" do
    config = Teletube::Config.load(CONFIG_PATH)
    config.attributes = { "token" => "changed", "endpoint" => "http://example.com/api" }
    config.token.should eq("changed")
    config.endpoint.should eq("http://example.com/api")
  end

  it "creates a new config, saves it, and then loads it again" do
    config = Teletube::Config.new
    config.attributes = {
      "token" => "cb70c152644b832148c5ca5410f30d30",
      "endpoint" => "https://api.example.com"
    }
    config.save(TMP_CONFIG_PATH)

    config = Teletube::Config.load(TMP_CONFIG_PATH)
    config.token.should eq("cb70c152644b832148c5ca5410f30d30")
    config.endpoint.should eq("https://api.example.com")
  end

  it "does not overwrite existing config when updated without values" do
    config = Teletube::Config.load(CONFIG_PATH)
    config.attributes = {} of String => String
    config.token.should eq("cb70c152644b832148c5ca5410f30d30")
    config.endpoint.should eq("https://staging.tube.switch.ch")
  end

  it "does not overwrite existing config with empty values" do
    config = Teletube::Config.load(CONFIG_PATH)
    config.attributes = { "token" => "", "endpoint" => "" } of String => String
    config.token.should eq("cb70c152644b832148c5ca5410f30d30")
    config.endpoint.should eq("https://staging.tube.switch.ch")
  end
end
