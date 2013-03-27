require 'fog/core'

module Fog
  module Dropbox
    extend Fog::Provider

    module Errors
      class ServiceError < Fog::Errors::Error
        attr_reader :response_data

        def self.slurp(error)
          if error.response.body.empty?
            data = nil
            message = nil
          else
            data = Fog::JSON.decode(error.response.body)
            message = data['message']
            if message.nil? and !data.values.first.nil?
              message = data.values.first['message']
            end
          end

          new_error = super(error, message)
          new_error.instance_variable_set(:@response_data, data)
          new_error
        end
      end

      class AuthenticationError < ServiceError; end
    end

    service(:storage, 'dropbox/storage', 'Storage')

    #def self.authenticate_old(options = {})
    #  oauth_helper = Fog::Dropbox::OAuthHelper.new(options)
    #  consumer = oauth_helper.consumer
    #  puts "Consumer - #{consumer.inspect}"
    #  request_token = consumer.get_request_token
    #  puts "Authorization Url: #{request_token.authorize_url}"
    #  query  = request_token.authorize_url.split('?').last
    #  params = CGI.parse(query)
    #  token  = params['oauth_token'].first
    #  puts "Token: #{token}"
    #  access_token  = request_token.get_access_token(:oauth_verifier => token)
    #  puts "Access Token: #{access_token}"
    #end

    def self.authenticate(options = {})
      #dropbox_access_token = options[:dropbox_access_token]
      @oauth_helper = Fog::Dropbox::OAuthHelper.new(options)
      #if dropbox_access_token
      #  @oauth_helper.access_token = dropbox_access_token
      #  puts "Access Token: #{dropbox_access_token}"
      #else
        authorize_url = @oauth_helper.authorize_url
        puts "Authorization Url: #{authorize_url}"
      #end
    end

    def self.access_token
      @oauth_helper.access_token
    end

    def self.create_signed_request(http_method, path, options = {})
      @oauth_helper.create_signed_request(http_method, path, options = {})
    end

    def self.request(params)
      #@oauth_helper.create_signed_request(http_method, path, options = {})
      @oauth_helper.request(params)
    end

    # CGI.escape, but without special treatment on spaces
    def self.escape(str,extra_exclude_chars = '')
      str.gsub(/([^a-zA-Z0-9_.-#{extra_exclude_chars}]+)/) do
        '%' + $1.unpack('H2' * $1.bytesize).join('%').upcase
      end
    end

    class Mock
      def self.rev
        Fog::Mock.random_hex(12)
      end

      def self.revision
        Fog::Mock.random_numbers(6)
      end

    end

  end
end