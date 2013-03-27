require 'fog/dropbox'
require 'fog/storage'
require 'fog/dropbox/oauth'

module Fog
  module Storage
    class Dropbox < Fog::Service
      requires    :dropbox_app_key, :dropbox_app_secret
      recognizes  :dropbox_access_type, :dropbox_access_token, :dropbox_api_version, :persistent
      recognizes  :dropbox_auth_url, :dropbox_api_url

      request_path 'fog/dropbox/requests/storage'
      request :get_account_info
      request :get_file
      request :put_file

      module Utils

        #def request_token
        #  @request_token
        #end
        #
        #
        #def get_authorize_url(options={})
        #  callback_url = options[:callback_url]
        #  locale = options[:locale]
        #  get_request_token()
        #  url = "#{@dropbox_auth_url}?oauth_token=#{Fog::Dropbox.escape(@request_token)}"
        #  if callback_url
        #    url += "&oauth_callback=#{Fog::Dropbox.escape(callback_url)}"
        #  end
        #  if locale
        #    url += "&locale=#{Fog::Dropbox.escape(locale)}"
        #  end
        #  url
        #end
        #
        #def access_token
        #  @dropbox_access_token
        #end
        #
        #def authorized?
        #  !!@dropbox_access_token
        #end
        #
        #def clear_access_token
        #  @dropbox_access_token = nil
        #end
        #
        #def get_access_token
        #  return @dropbox_access_token if authorized?
        #  if @request_token.nil?
        #    raise AuthenticationError.new("A request token is required.")
        #  end
        #  begin
        #    @dropbox_access_token = get_token("/access_token", @request_token)
        #  rescue Excon::Errors::Unauthorized, Excon::Errors::BadRequest
        #    clear_access_token
        #  end
        #  @dropbox_access_token
        #end
        #
        #def get_token(path, request_token=nil)
        #
        #  header_content = "#{credentials.client_id}:#{credentials.client_secret}"
        #  encoded_credentials = Base64.encode64(header_content).chomp
        #
        #  @connection.request({
        #    :path => path,
        #    :expects  => 200,
        #    :headers  => {
        #      'Authorization' => "Basic #{encoded_credentials}",
        #      'Content-Type' => 'application/json'
        #    },
        #    :method   => 'POST',
        #    :body     => Fog::JSON.encode(token_strategy.authorization_body_data)
        #  })
        #end
        #
      end

      class Mock
        include Utils

        def self.data
          @data ||= Hash.new do |hash, key|
            hash[key] = {
              :account => {
                "100" => {
                  "referral_link" => "https://www.dropbox.com/referrals/xxxxyyyyzzzz",
                  "display_name"  => "Rupak Ganguly",
                  "uid" => 100,
                  "country" => "US",
                  "quota_info" =>
                  {
                    "shared" => 111111111,
                    "quota" => 2222222222,
                    "normal" => 3333333333
                  },
                  "email" => "my@email.com"
                }
              },
              :files => {}
            }
            end
        end

        def self.reset
          @data = nil
        end

        def initialize(options={})
          @dropbox_app_key      = options[:dropbox_app_key]
          @dropbox_access_type  = options[:dropbox_access_type] || "sandbox" # or "dropbox"
        end

        def data
          self.class.data[@dropbox_app_key]
        end

        def reset_data
          self.class.data.delete(@dropbox_app_key)
        end

      end

      class Real
        include Utils

        def initialize(options={})
          # keys and tokens
          @dropbox_app_key          = options[:dropbox_app_key]
          @dropbox_app_secret       = options[:dropbox_app_secret]
          @dropbox_access_type      = options[:dropbox_access_type] ||= "sandbox" # or "dropbox"
          @dropbox_access_token     = options[:dropbox_access_token]
          @dropbox_api_version      = options[:dropbox_api_version] ||= "1"
          # auth url
          @dropbox_auth_url         = options[:dropbox_auth_url] ||= "https://www.dropbox.com"
          # api url
          @dropbox_api_url          = options[:dropbox_api_url] ||= "https://api.dropbox.com/#{@dropbox_api_version}"
          # api content url
          @dropbox_api_content_url  = options[:@dropbox_api_content_url] ||= "https://api-content.dropbox.com/#{@dropbox_api_version}"
          #@connection_options   = options[:connection_options]  ||= {}
          #@persistent           = options[:persistent] ||= false
          #@connection           = Fog::Connection.new(@dropbox_api_url, @persistent, @connection_options)

          Fog::Dropbox.authenticate(options)

        end

        def api_request(params, parse_json = true, &block)
          request(params.merge!({:host => @dropbox_api_url}), parse_json = true, &block)
        end
        def content_request(params, parse_json = true, &block)
          #params.merge!({:host => @dropbox_api_content_url})
          #puts "content_request params: #{params}"
          request(params.merge!({:host => @dropbox_api_content_url}), parse_json = true, &block)
        end

        def request(params, parse_json = true, &block)
          begin
            #signed_req = Fog::Dropbox.create_signed_request(params[:method], params[:path], options = {})
            response = Fog::Dropbox.request(params.merge!({
              :headers  => {
                'Content-Type' => 'application/json'
              }.merge!(params[:headers] || {}),
              #:host     => @dropbox_api_url,
              :path     => "#{@path}/#{params[:path]}"
            }))
          #begin
          #  response = @connection.request(params.merge!({
          #    :headers  => {
          #      'Content-Type' => 'application/json'
          #    }.merge!(params[:headers] || {}),
          #    :host     => @host,
          #    :path     => "#{@path}/#{params[:path]}",
          #  }), &block)
          rescue Excon::Errors::HTTPStatusError => error
            raise case error
            when Excon::Errors::NotFound
              Fog::Storage::Dropbox::NotFound.slurp(error)
            else
              error
            end
          end
          if !response.body.empty? && parse_json
            begin
              response.body = Fog::JSON.decode(response.body)
            rescue MultiJson::DecodeError
              response.body   #### not JSON output, so just return as is
            end
          end
          response
          # create a temp JSON object to return the response details
          { :code => "#{response.code}",
            :code_type => "#{response.code_type}",
            :message => "#{response.message}",
            :content_length => "#{response.content_length}",
            :content_type => "#{response.content_type}",
            :body => "#{response.body}"
          }
        end

      end

    end
  end
end