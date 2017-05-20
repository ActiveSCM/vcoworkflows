require 'vcoworkflows/constants'
require 'uri'

# VcoWorkflows
module VcoWorkflows
  # Class Config
  class Config
    # URL for the vCenter Orchestrator REST API
    attr_reader :url

    # User name to authenticate to vCenter Orchestrator
    attr_accessor :username

    # Password to authenticate to vCenter Orchestrator
    attr_accessor :password

    # Whether or not to do SSL/TLS Certificate verification
    attr_accessor :verify_ssl

    # rubocop:disable MethodLength, CyclomaticComplexity, PerceivedComplexity

    # Constructor
    # @param [String] config_file Path to config file to load
    # @param [String] url URL for vCO server
    # @param [String] username Username for vCO server
    # @param [String] password Password for vCO server
    # @param [Boolean] verify_ssl Verify SSL Certificates?
    # @return [VcoWorkflows::Config]
    def initialize(config_file: nil, url: nil, username: nil, password: nil, verify_ssl: true)
      # If we're given a URL and no config_file, then build the configuration
      # from the values we're given (or can scrape from the environment).
      # Otherwise, load the given config file or the default config file if no
      # config file was given.
      if url && config_file.nil?
        self.url    = url
        @username   = username.nil? ? ENV['VCO_USER'] : username
        @password   = password.nil? ? ENV['VCO_PASSWD'] : password
        @verify_ssl = verify_ssl
      else
        # First, check if an explicit config file was given
        config_file = DEFAULT_CONFIG_FILE if config_file.nil?
        load_config(config_file)
      end

      # Fail if we don't have both a username and a password.
      raise(IOError, ERR[:url_unset]) if @url.nil?
      raise(IOError, ERR[:username_unset]) if @username.nil?
      raise(IOError, ERR[:password_unset]) if @password.nil?
    end
    # rubocop:enable LineLength, MethodLength, CyclomaticComplexity, PerceivedComplexity

    # Set the URL for the vCO server, force the path component.
    # @param [String] vco_url
    def url=(vco_url)
      url = URI.parse(vco_url)
      url.path = '/vco/api'
      @url = url.to_s
    end
    # rubocop:enable LineLength

    # load config file
    # @param [String] config_file Path for the configuration file to load
    def load_config(config_file)
      config_data = JSON.parse(File.read(config_file))
      return if config_data.nil?
      self.url    = config_data['url']
      @username   = config_data['username']
      @password   = config_data['password']
      @verify_ssl = config_data['verify_ssl']
    end

    # Return a String representation of this object
    # @return [String]
    def to_s
      puts "url:        #{@url}"
      puts "username:   #{@username}"
      puts "password:   #{@password}"
      puts "verify_ssl: #{@verify_ssl}"
    end

    # Return a JSON document for this object
    def to_json
      config = {}
      config['url'] = @url
      config['username'] = @username
      config['password'] = @password
      config['verify_ssl'] = @verify_ssl
      puts JSON.pretty_generate(config)
    end
  end
end
