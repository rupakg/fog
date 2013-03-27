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
          response = Excon::Response.new
          response.status = 200

          # convert filepath to a unique key
          filepath_key = filepath.gsub('/\//', '_')
          # return contents of the file
          data = self.data[:files][filepath_key]
          response.body = data
          response
        end

      end

    end
  end
end
