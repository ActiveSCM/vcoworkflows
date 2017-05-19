require_relative 'constants'
require_relative 'workflowservice'
require_relative 'workflowpresentation'
require_relative 'workflowtoken'
require_relative 'workflowparameter'
require 'json'

# VcoWorkflows
module VcoWorkflows
  # rubocop:disable ClassLength

  # Class to represent a Workflow as presented by vCenter Orchestrator.
  class Workflow
    # Workflow GUID
    # @return [String] workflow GUID
    attr_reader :id

    # Workflow name
    # @return [String] workflow name
    attr_reader :name

    # Workflow version
    # @return [String] workflow version
    attr_reader :version

    # Workflow description
    # @return [String] workflow description
    attr_reader :description

    # Workflow Input Parameters: Hash of WorkflowParameters, keyed by name
    # @return [Hash<VcoWorkflows::WorkflowParameter>]
    attr_reader :input_parameters

    # Workflow Output Parameters: Hash of WorkflowParameters, keyed by name
    # @return [Hash<VcoWorkflows::WorkflowParameter>]
    attr_reader :output_parameters

    # Workflow Service in use by this Workflow
    # @return [VcoWorkflows::WorkflowService]
    attr_accessor :service

    # Workflow execution ID
    # @return [String]
    attr_reader :execution_id

    # Workflow source JSON
    # @return [String]
    attr_reader :source_json

    # rubocop:disable CyclomaticComplexity, PerceivedComplexity, MethodLength

    # Create a Workflow object given vCenter Orchestrator's JSON description
    #
    # When passed `url`, `username` and `password` the necessary session and
    # service objects will be created behind the scenes. Alternatively you can
    # pass in a Config or a WorkflowService object if you have
    # constructed them yourself. You may also pass in the path to a
    # configuration file (`config_file`).
    #
    # @param [String] name Name of the requested workflow
    # @param [Hash] options Hash of options:
    #  - id: (String) GUID for the Workflow
    #  - url: (String) vCO REST API URL
    #  - username: (String) User to authenticate as
    #  - password: (String) Password for username
    #  - verify_ssl: (Boolean) Perform TLS/SSL certificate validation
    #  - service: (VcoWorkflows::WorkflowService) WorkflowService to use for communicating to vCO
    #  - config: (VcoWorkflows::Config) Configuration object to use for this workflow's session
    #  - config_file: (String) Path to load configuration file from for this workflow's session
    # @return [VcoWorkflows::Workflow]
    def initialize(name = nil, options = {})
      @options = {
        id: nil,
        url: nil,
        username: nil,
        password: nil,
        verify_ssl: true,
        service: nil,
        config: nil,
        config_file: nil
      }.merge(options)

      config = nil
      @service = nil
      @execution_id = nil

      # -------------------------------------------------------------
      # Figure out how to get a workflow service. If I can't, I die.
      # (DUN dun dun...)

      if options[:service]
        @service = options[:service]
      else
        # If we were given a configuration object, use it
        # If we were given a config file path, use it
        # If we have a url, username and password, use them
        # If all we have is a URL, try anyway, maybe we'll get username and
        # password from ENV values (hey, it might work...)
        if @options[:config]
          config = @options[:config]
        elsif @options[:config_file]
          config = VcoWorkflows::Config.new(config_file: @options[:config_file])
        elsif @options[:url] && @options[:username] && @options[:password]
          config = VcoWorkflows::Config.new(url:        @options[:url],
                                            username:   @options[:username],
                                            password:   @options[:password],
                                            verify_ssl: @options[:verify_ssl])
        elsif @options[:url]
          config = VcoWorkflows::Config.new(url:        @options[:url],
                                            verify_ssl: @options[:verify_ssl])
        end

        # If we got a config object above, great. If it's still nil, VcoSession
        # will accept that and try to load the default config file.
        session  = VcoWorkflows::VcoSession.new(config: config)
        @service = VcoWorkflows::WorkflowService.new(session)
      end

      fail(IOError, 'Unable to create/use a WorkflowService!') if @service.nil?

      # -------------------------------------------------------------
      # Retrieve the workflow and parse it into a data structure
      # If we're given both a name and ID, prefer the id
      if @options[:id]
        workflow_json = @service.get_workflow_for_id(@options[:id])
      else
        workflow_json = @service.get_workflow_for_name(name)
      end
      workflow_data = JSON.parse(workflow_json)

      # Set up the attributes if they exist in the data json,
      # otherwise nil them
      # rubocop:disable SpaceAroundOperators
      @id          = workflow_data.key?('id')          ? workflow_data['id']          : nil
      @name        = workflow_data.key?('name')        ? workflow_data['name']        : nil
      @version     = workflow_data.key?('version')     ? workflow_data['version']     : nil
      @description = workflow_data.key?('description') ? workflow_data['description'] : nil
      # rubocop:enable SpaceAroundOperators

      # Process the input parameters
      if workflow_data.key?('input-parameters')
        @input_parameters = Workflow.parse_parameters(workflow_data['input-parameters'])
      else
        @input_parameters = {}
      end

      # Identify required input_parameters
      wfpres = VcoWorkflows::WorkflowPresentation.new(@service, @id)
      wfpres.required.each do |req_param|
        @input_parameters[req_param].required(true)
      end

      # Process the output parameters
      if workflow_data.key?('output-parameters')
        @output_parameters = Workflow.parse_parameters(workflow_data['output-parameters'])
      else
        @output_parameters = {}
      end
    end
    # rubocop:enable CyclomaticComplexity, PerceivedComplexity, MethodLength, LineLength

    # vCO API URL used when creating this workflow
    # @return [String]
    def url
      options[:url]
    end

    # vCO user name used when creating this workflow object
    # @return [String]
    def username
      options[:username]
    end

    # vCO password used when creating this workflow object
    # @return [String]
    def password
      options[:password]
    end

    # Verify SSL?
    # @return [Boolean]
    def verify_ssl?
      options[:verify_ssl]
    end

    # rubocop:disable MethodLength, LineLength

    # Parse json parameters and return a nice hash
    # @param [Array<Hash>] parameter_data Array of parameter data hashes
    # by vCO
    # @return [Hash]
    def self.parse_parameters(parameter_data = [])
      wfparams = {}
      parameter_data.each do |parameter|
        wfparam = VcoWorkflows::WorkflowParameter.new(parameter['name'], parameter['type'])
        if parameter['value']
          if wfparam.type.eql?('Array')
            value = []
            begin
              parameter['value'][wfparam.type.downcase]['elements'].each do |element|
                value << element[element.keys.first]['value']
              end
            rescue StandardError => error
              parse_failure(error, wfparam, parameter)
            end
          else
            begin
              value = parameter['value'][parameter['value'].keys.first]['value']
            rescue StandardError => error
              parse_failure(error, wfparam, parameter)
            end
          end
          value = nil if value.eql?('null')
          wfparam.set(value)
        end
        wfparams[parameter['name']] = wfparam
      end
      wfparams
    end
    # rubocop:enable MethodLength

    # Process exceptions raised in parse_parameters by bravely ignoring them
    #   and forging ahead blindly!
    # @param [Exception] error
    def self.parse_failure(error, wfparam, parameter)
      $stderr.puts "\nWhoops!"
      $stderr.puts "Ran into a problem parsing parameter #{wfparam.name} (#{wfparam.type})!"
      $stderr.puts "Source data: #{JSON.pretty_generate(parameter)}\n"
      $stderr.puts error.message
      $stderr.puts "\nBravely forging on and ignoring parameter #{wfparam.name}!"
    end

    # Get an array of the names of all the required input parameters
    # @return [Hash] Hash of WorkflowParameter input parameters which
    #   are required for this workflow
    def required_parameters
      required = {}
      @input_parameters.each_value { |v| required[v.name] = v if v.required? }
      required
    end

    # Get the parameter object named. If a value is provided, set the value
    # and return the parameter object.
    #
    # To get a parameter value, use parameter(parameter_name).value
    #
    # @param [String] parameter_name Name of the parameter to get
    # @param [Object, nil] parameter_value Optional value for parameter.
    # @return [VcoWorkflows::WorkflowParameter] The resulting WorkflowParameter
    def parameter(parameter_name, parameter_value = nil)
      if @input_parameters.key?(parameter_name)
        @input_parameters[parameter_name].set parameter_value
      else
        $stderr.puts "\nAttempted to set a value for a non-existent WorkflowParameter!"
        $stderr.puts "It appears that there is no parameter \"#{parameter}\"."
        $stderr.puts "Valid parameter names are: #{@input_parameters.keys.join(', ')}"
        $stderr.puts ''
        fail(IOError, ERR[:no_such_parameter])
      end unless parameter_value.nil?
      @input_parameters[parameter_name]
    end
    # rubocop:enable MethodLength

    # Set a parameter with a WorkflowParameter object
    # @param [VcoWorkflows::WorkflowParameter] wfparameter New parameter
    def parameter=(wfparameter)
      @input_parameters[wfparameter.name] = wfparameter
    end

    # Determine whether a parameter has been set
    # @param [String] parameter_name Name of the parameter to check
    # @return [Boolean]
    def parameter?(parameter_name)
      parameter(parameter_name).set?
    end

    # Set all input parameters using the given hash
    # @param [Hash] parameter_hash input parameter values keyed by
    #   input_parameter name
    def parameters=(parameter_hash)
      parameter_hash.each { |name, value| parameter(name, value) }
    end

    # Set a parameter to a value.
    # @deprecated Use {#parameter} instead
    # @param [String] parameter_name name of the parameter to set
    # @param [Object] value value to set
    # @return [VcoWorkflows::WorkflowParameter] The resulting WorkflowParameter
    def set_parameter(parameter_name, value)
      parameter(parameter_name, value)
    end

    # Get the value for an input parameter
    # @deprecated Use {#parameter} to retrieve the
    #   {VcoWorkflows::WorkflowParameter} object, instead
    # @param [String] parameter_name Name of the input parameter
    #   whose value to get
    # @return [Object]
    def get_parameter(parameter_name)
      parameter(parameter_name).value
    end

    # Execute this workflow
    # @param [VcoWorkflows::WorkflowService] workflow_service
    # @return [String] Workflow Execution ID
    def execute(workflow_service = nil)
      # If we're not given an explicit workflow service for this execution
      # request, use the one defined when we were created.
      workflow_service = @service if workflow_service.nil?
      # If we still have a nil workflow_service, go home.
      fail(IOError, ERR[:no_workflow_service_defined]) if workflow_service.nil?
      # Make sure we didn't forget any required parameters
      verify_parameters
      # Let's get this thing running!
      @execution_id = workflow_service.execute_workflow(@id, input_parameter_json)
    end

    # Get a list of all the executions of this workflow. Wrapper for
    # VcoWorkflows::WorkflowService#get_execution_list
    # @return [Hash]
    def executions
      @service.get_execution_list(@id)
    end

    # Return a WorkflowToken
    # @param [String] execution_id optional execution id to get logs for
    # @return [VcoWorkflows::WorkflowToken]
    def token(execution_id = nil)
      execution_id = @execution_id if execution_id.nil?
      VcoWorkflows::WorkflowToken.new(@service, @id, execution_id)
    end

    # Return logs for the given execution
    # @param [String] execution_id optional execution id to get logs for
    # @return [VcoWorkflows::WorkflowExecutionLog]
    def log(execution_id = nil)
      execution_id = @execution_id if execution_id.nil?
      log_json = @service.get_log(@id, execution_id)
      VcoWorkflows::WorkflowExecutionLog.new(log_json)
    end

    # rubocop:disable MethodLength

    # Stringify the workflow
    # @return [String]
    def to_s
      string =  "Workflow:    #{@name}\n"
      string << "ID:          #{@id}\n"
      string << "Description: #{@description}\n"
      string << "Version:     #{@version}\n"

      string << "\nInput Parameters:\n"
      if @input_parameters.size > 0
        @input_parameters.each_value { |wf_param| string << " #{wf_param}" }
      end

      string << "\nOutput Parameters:" << "\n"
      if @output_parameters.size > 0
        @output_parameters.each_value { |wf_param| string << " #{wf_param}" }
      end

      # Assert
      string
    end
    # rubocop:enable MethodLength

    private

    # Convert the input parameters to a JSON document
    # @return [String]
    def input_parameter_json
      tmp_params = []
      @input_parameters.each_value { |v| tmp_params << v.as_struct if v.set? }
      param_struct = { parameters: tmp_params }
      param_struct.to_json
    end

    # Verify that all mandatory input parameters have values
    def verify_parameters
      required_parameters.each do |name, wfparam|
        if wfparam.required? && (wfparam.value.nil? || wfparam.value.size == 0)
          fail(IOError, ERR[:param_verify_failed] << "#{name} required but not present.") # rubocop:disable Metrics/LineLength
        end
      end
    end
  end
  # rubocop:enable ClassLength
end
