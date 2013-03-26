module Fog
  module Storage
    class Dropbox
      class Real

        # options - locale
        def get_account_info(options = {})
          options = options.reject {|key, value| value.nil?}
          response = api_request(
            :expects  => 200,
            :method   => 'GET',
            :path     => "account/info",
            :query    => options
          )
          response
        end

      end

      class Mock # :nodoc:all

        def get_account_info(options = {})
          response = Excon::Response.new
          response.status = 200

          data = self.data[:account]['100']
          response.body = data
          response
        end

      end

    end
  end
end
