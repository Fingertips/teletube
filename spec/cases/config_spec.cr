require "spec"
require "../spec_helper"

describe Teletube::Config do
  it "loads from a file" do
    config_path = File.expand_path("spec/files/config.yml", Dir.current)
    config = Teletube::Config.load(config_path)
    config.token.should eq("cb70c152644b832148c5ca5410f30d30")
  end

  it "updates" do
    config_path = File.expand_path("spec/files/config.yml", Dir.current)
    config = Teletube::Config.load(config_path)
    config.attributes = { "token" => "changed" }
    config.token.should eq("changed")
  end

  it "creates a new config, saves it, and then loads it again" do
    config_path = File.expand_path("spec/tmp/config.yml", Dir.current)
    config = Teletube::Config.new
    config.attributes = { "token" => "cb70c152644b832148c5ca5410f30d30" }
    config.save(config_path)

    config = Teletube::Config.load(config_path)
    config.token.should eq("cb70c152644b832148c5ca5410f30d30")
  end
end
