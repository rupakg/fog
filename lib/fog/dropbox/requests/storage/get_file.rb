module Fog
  module Storage
    class Dropbox
      class Real

        # options
        def get_file(filepath, options = {})
          options = options.reject {|key, value| value.nil?}
          response = content_request(
            :expects  => 200,
            :method   => 'GET',
            :path     => "files/sandbox/#{filepath}",
            :query    => options
          )
          response
        end

      end

      class Mock # :nodoc:all

        def get_file(filepath, options = {})
        end

      end

    end
  end
end
