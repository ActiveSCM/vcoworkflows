require 'vcoworkflows'
require 'thor/group'

# rubocop:disable MethodLength

# VcoWorkflows
module VcoWorkflows
  # Cli
  module Cli
    # Execute a workflow with the given options.
    class Execute < Thor::Group
      include Thor::Actions

      argument :workflow, type: :string, desc: DESC_CLI_WORKFLOW
      class_option :server, type: :string, aliases: '-s', required: true, desc: DESC_CLI_SERVER
      class_option :username, type: :string, aliases: '-u', desc: DESC_CLI_USERNAME
      class_option :password, type: :string, aliases: '-p', desc: DESC_CLI_PASSWORD
      class_option :id, type: :string, aliases: '-i', desc: DESC_CLI_WORKFLOW_ID
      class_option :verify_ssl, type: :boolean, default: true, desc: DESC_CLI_VERIFY_SSL
      class_option :dry_run, type: :boolean, default: false, desc: DESC_CLI_DRY_RUN
      class_option :verbose, type: :boolean, default: true, desc: DESC_CLI_VERBOSE
      class_option :watch, type: :boolean, default: true, desc: DESC_CLI_EXECUTE_WATCH

      class_option :parameters, type: :string, required: true, desc: DESC_CLI_EXECUTE_PARAMETERS

      # Thor
      def self.source_root
        File.dirname(__FILE__)
      end

      # rubocop:disable CyclomaticComplexity, PerceivedComplexity
      def execute
        config = VcoWorkflows::Config.new(url:        options[:server],
                                          username:   options[:username],
                                          password:   options[:password],
                                          verify_ssl: options[:verify_ssl])

        # Parse out the parameters
        parameters = {}
        options[:parameters].split(/,/).each do |p|
          k, v = p.split(/=/)
          parameters[k] = v
        end
        if parameters.key?('runlist')
          parameters['runlist'] = parameters['runlist'].split(/:/)
        end

        puts "Executing against vCO REST endpoint: #{options[:server]}"
        puts "Requested execution of workflow: '#{workflow}'"
        puts "Will call workflow by GUID (#{options[:id]})" if options[:id]
        if options[:verbose] || options[:dry_run]
          puts 'Parameters:'
          parameters.each do |k, v|
            v = v.join(',') if v.is_a?(Array)
            puts " - #{k}: #{v}"
          end
          puts ''
        end

        return if options[:dry_run]

        # Get the workflow
        puts "Retrieving workflow '#{workflow}' ..."
        wf = VcoWorkflows::Workflow.new(workflow,
                                        id:     options[:id],
                                        config: config)

        # List out mandatory parameters
        puts "Required parameters:\n #{wf.required_parameters.keys.join(', ')}"

        # Set the input parameters
        puts 'Setting workflow input parameters...' if options[:verbose]
        parameters.each do |k, v|
          puts "setting #{k} to #{v}" if options[:verbose]
          wf.set_parameter(k, v)
        end

        # Execute the workflow
        puts 'Executing workflow...'
        wf.execute

        # Fetch the results
        wftoken = wf.token
        puts "#{wftoken.id} started at #{Time.at(wftoken.start_date / 1000)}"

        # If we don't care about the results, move on.
        return unless options[:watch]

        # Check for update results until we get one who's state
        # is not "running" or "waiting"
        puts "\nChecking status...\n"
        while wftoken.alive?
          sleep 10
          wftoken = wf.token
          puts "#{Time.now} state: #{wftoken.state}"
        end
        puts "\nFinal status of execution:"
        puts wftoken

        # Print out the execution log
        puts "\nWorkflow #{wf.name} log for execution #{wftoken.id}:"
        log = wf.log(wftoken.id)
        puts "\n#{log}"
      end
      # rubocop:enable CyclomaticComplexity, PerceivedComplexity
    end
  end
end
# rubocop:enable MethodLength, LineLength
