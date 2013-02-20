module Fog
  module Storage
    class Dropbox
      class Real

        # options - locale
        def get_account_info(options = {})
          options = options.reject {|key, value| value.nil?}
          response = request(
            :expects  => 200,
            :method   => 'GET',
            :path     => "account/info",
            :query    => options
          )
          response
        end

      end

      class Mock # :nodoc:all

        def get_container(options = {})
        end

      end

    end
  end
end
