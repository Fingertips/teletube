require "spec"
require "../spec_helper"

describe Teletube::Context do
  it "stores details about a CLI invokation" do
    context = Teletube::Context.new
    context.errors = ["Something went wrong"]
    context.resource = "channels"
    context.command = "create"
    context.params = { "token" => JSON::Any.new("secret") }
    context.run = false
    context.verbose = true
    context.command.should eq("create")
  end
end
