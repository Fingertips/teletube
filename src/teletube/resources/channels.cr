module Teletube
  module Resources
    class Channels
      def initialize(context : Teletube::Context, client : Teletube::Client)
        @context = context
        @client = client
      end

      def channels
        response = @client.get(path: "/api/v1/channels", params: @context.params)
        if response.status_code == 200
          JSON.parse(response.body).as_a
        else
          [] of Hash(String, String)
        end
      end
    end
  end
end
