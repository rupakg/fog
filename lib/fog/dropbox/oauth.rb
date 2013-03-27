# This module implements the Authentication related API calls using OAuth
require "oauth"

module Fog::Dropbox

  class OAuthHelper

    attr_reader :app_key, :app_secret, :access_type
    attr_reader :access_token, :request_token

    def initialize(options={})
        # keys and tokens
        @app_key      = options[:dropbox_app_key]
        @app_secret   = options[:dropbox_app_secret]
        @access_type  = options[:dropbox_access_type]
        @access_token_str = options[:dropbox_access_token]
        @access_token_str = options[:dropbox_access_token]
        # auth url
        @auth_url     = options[:dropbox_auth_url]
        # api url
        @api_version  = options[:dropbox_api_version]
        @api_url      = options[:dropbox_api_url]
    end

    def consumer
      @consumer ||= get_consumer
    end

    def request_token
      @request_token ||= consumer.get_request_token
    end

    def authorize_url
      request_token.authorize_url
    end

    def access_token
      @access_token ||= get_access_token
      #puts "Access Token: #{@access_token.inspect}"
      @access_token
    end

    def access_token=(new_access_token)
      @access_token = new_access_token
    end

    def get_consumer
      if !@app_key or !@app_secret
        raise Fog::Dropbox::Errors.new("app_key or app_secret not provided")
      end

      ::OAuth::Consumer.new(@app_key, @app_secret,
                            :site => @auth_url,
                            :request_token_path => "/#{@api_version}/oauth/request_token",
                            :authorize_path     => "/#{@api_version}/oauth/authorize",
                            :access_token_path  => "/#{@api_version}/oauth/access_token")
    end

    def get_access_token
      if @access_token_str
        hydrate_access_token
      else
        if request_token && authorize_url
          query  = authorize_url.split('?').last
          params = CGI.parse(query)
          token  = params['oauth_token'].first
          request_token.get_access_token(:oauth_verifier => token)
        end
      end
    end

    def hydrate_access_token()
      ::OAuth::AccessToken.new(consumer, @access_token_str, @access_secret_str)
    end

    def request(params)
      call_url = "#{params[:host]}#{params[:path]}?#{URI.encode(query(params[:query]))}"
      #puts "Call Url: #{call_url} - Header: #{params[:headers]}"

      method = params[:method]
      case method
      when 'GET'
        response = access_token.get(call_url, params[:headers])
      when 'PUT'
        response = access_token.put(call_url, params[:body], params[:headers])
      when 'POST'
        response = access_token.post(call_url, params[:body], params[:headers])
      when 'DELETE'
        response = access_token.delete(call_url, params[:headers])
      else
        raise ArgumentError, "Unsupported HTTP method: #{method}"
      end
      response
    end

    def create_signed_request(http_method, path, options = {})
      consumer.create_signed_request(http_method, path, access_token, {}, options)
    end

    private

    def query(data)
      data.inject([]) { |memo, entry| memo.push(entry.join('=')); memo }.join('&')
    end

  end
end