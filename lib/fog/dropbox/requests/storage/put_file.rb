module Fog
  module Storage
    class Dropbox
      class Real

        # options
        def put_file(filepath, data, headers = {}, options = {})
          data = Fog::Storage.parse_data(data)
          options = options.reject {|key, value| value.nil?}
          headers = data[:headers].merge!(headers)
          headers = headers.reject {|key, value| value.nil?}
          headers.each {|key, value| headers[key] = "#{value}"}
          response = content_request(
            :body     => data[:body],
            :expects  => 200,
            :method   => 'PUT',
            :headers  => headers,
            :path     => "files_put/sandbox/#{filepath}",
            :query    => options
          )
          response
        end

      end

      class Mock # :nodoc:all

        def put_file(filepath, data, headers = {}, options = {})
          response = Excon::Response.new
          response.status = 200

          file = Fog::Storage.parse_data(data)
          unless file[:body].is_a?(String)
            file[:body] = file[:body].read
          end
          bytes = headers['Content-Length'] || data[:headers]['Content-Length']
          size = bytes == 0 ? 0 : (bytes/1024)

          data = {
              :size          => "#{size}KB",
              :rev           => Fog::Dropbox::Mock.rev.to_s,
              :thumb_exists  => false,
              :bytes         => bytes,
              :modified      => Fog::Time.now.to_date_header,
              :path          => filepath,
              :is_dir        => false,
              :icon          => "page_white_acrobat",
              :root          => 'sandbox',
              :mime_type     => headers['Content-Type'] || data[:headers]['Content-Type'],
              :revision      => Fog::Dropbox::Mock.revision
          }

          # convert filepath to a unique key
          filepath_key = filepath.gsub('/\//', '_')
          self.data[:files][filepath_key] = data.merge!(:body => file[:body])
          response.body = data
          response
        end

      end

    end
  end
end
