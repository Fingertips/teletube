module Teletube
  # Keeps the details of how the CLI tool was called.
  class Context
    property errors : Array(String)
    property resource : String?
    property command : String?
    property params : Hash(String, String)
    property? run

    def initialize
      @errors = [] of String
      @params = {} of String => String
      @run = true
    end
  end
end
