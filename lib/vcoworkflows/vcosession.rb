require 'vcoworkflows/constants'
require 'vcoworkflows/config'
require 'rest_client'

# VcoWorkflows
module VcoWorkflows
  # VcoSession is a simple wrapper for RestClient::Resource, and supports
  # GET and POST operations against the vCO API.
  class VcoSession
    # Accessor for rest-client object, primarily for testing purposes
    attr_reader :rest_resource

    # rubocop:disable MethodLength

    # Initialize the session
    #
    # When specifying a config, do not provide other parameters. Likewise,
    # if providing uri, user, and password, a config object is not necessary.
    #
    # @param [VcoWorkflows::Config] config Configuration object for the connection
    # @param [String] uri URI for the vCenter Orchestrator API endpoint
    # @param [String] user User name for vCO
    # @param [String] password Password for vCO
    # @param [Boolean] verify_ssl Whether or not to verify SSL certificates
    def initialize(config: nil, uri: nil, user: nil, password: nil, verify_ssl: true)
      # If a configuration object was provided, use it.
      # If we got a URL and no config, build a new config with the URL and any
      # other options that passed in.
      # Otherwise, load the default config file if possible...
      if config
        config = config
      elsif uri && config.nil?
        config = VcoWorkflows::Config.new(url:        uri,
                                          username:   user,
                                          password:   password,
                                          verify_ssl: verify_ssl)
      elsif uri.nil? && config.nil?
        config = VcoWorkflows::Config.new
      end

      RestClient.proxy = ENV['http_proxy'] # Set a proxy if present
      @rest_resource = RestClient::Resource.new(config.url,
                                                user:       config.username,
                                                password:   config.password,
                                                verify_ssl: config.verify_ssl)
    end
    # rubocop:enable MethodLength, LineLength

    # Perform a REST GET operation against the specified endpoint
    #
    # @param [String] endpoint REST endpoint to use
    # @param [Hash] headers Optional headers to use in request
    # @return [String] JSON response body
    def get(endpoint, headers = {})
      headers = { accept: :json }.merge(headers)
      @rest_resource[endpoint].get headers
    end

    # Perform a REST POST operation against the specified endpoint with the
    # given data body
    #
    # @param [String] endpoint REST endpoint to use
    # @param [String] body JSON data body to post
    # @param [Hash] headers Optional headers to use in request
    # @return [String] JSON response body
    def post(endpoint, body, headers = {})
      headers = { accept: :json, content_type: :json }.merge(headers)
      @rest_resource[endpoint].post body, headers
    end
  end
end
