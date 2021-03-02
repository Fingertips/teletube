require "json"

module Teletube
  # Keeps the details of how the CLI tool was called.
  class Context
    property errors : Array(String)
    property resource : String?
    property command : String?
    property params : Hash(String, JSON::Any)
    property filename : String?
    property? run
    property? verbose

    def initialize
      @errors = [] of String
      @params = {} of String => JSON::Any
      @run = true
      @verbose = false
    end
  end
end
