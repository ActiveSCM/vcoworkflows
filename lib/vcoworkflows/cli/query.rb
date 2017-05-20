require 'vcoworkflows'
require 'thor/group'

# rubocop:disable MethodLength, LineLength

# VcoWorkflows
module VcoWorkflows
  # Cli
  module Cli
    # Query
    class Query < Thor::Group
      include Thor::Actions

      argument :workflow, type: :string, desc: DESC_CLI_WORKFLOW
      class_option :server, type: :string, aliases: '-s', required: true, desc: DESC_CLI_SERVER
      class_option :username, type: :string, aliases: '-u', desc: DESC_CLI_USERNAME
      class_option :password, type: :string, aliases: '-p', desc: DESC_CLI_PASSWORD
      class_option :id, type: :string, aliases: '-i', desc: DESC_CLI_WORKFLOW_ID
      class_option :verify_ssl, type: :boolean, default: true, desc: DESC_CLI_VERIFY_SSL
      class_option :dry_run, type: :boolean, default: false, desc: DESC_CLI_DRY_RUN

      class_option :executions, type: :boolean, aliases: '-e', default: false, desc: DESC_CLI_QUERY_EXECS
      class_option :last, type: :numeric, aliases: '-l', default: 0, desc: DESC_CLI_QUERY_EXEC_LIM
      class_option :execution_id, type: :string, aliases: ['-I', '--execution'], desc: DESC_CLI_QUERY_EXEC_ID
      class_option :state, type: :boolean, aliases: '-r', desc: DESC_CLI_QUERY_EXEC_STATE
      class_option :logs, type: :boolean, aliases: ['-L', '--log'], desc: DESC_CLI_QUERY_EXEC_LOG
      class_option :show_json, type: :boolean, default: false, desc: DESC_CLI_QUERY_JSON

      # Thor
      def self.source_root
        File.dirname(__FILE__)
      end

      # Process the subcommand
      # rubocop:disable CyclomaticComplexity, PerceivedComplexity
      def query
        config = VcoWorkflows::Config.new(url:        options[:server],
                                          username:   options[:username],
                                          password:   options[:password],
                                          verify_ssl: options[:verify_ssl])

        if options[:dry_run]
          puts "\nQuerying against vCO REST endpoint:\n  #{options[:server]}"
          puts "Will search for workflow: '#{workflow}'"
          puts "Will query workflow by GUID (#{options[:id]})" if options[:id]
          return
        end

        # Get the workflow
        puts "\nRetrieving workflow '#{workflow}' ..."
        wf = VcoWorkflows::Workflow.new(workflow,
                                        id:     options[:id],
                                        config: config)

        puts ''
        if options[:execution_id]
          puts "Fetching data for execution #{options[:execution_id]}..."
          execution = wf.token(options[:execution_id])
          if options[:state]
            puts "Execution started at #{Time.at(execution.start_date / 1000)}"
            puts "Execution #{execution.state} at #{Time.at(execution.end_date / 1000)}"
          else
            puts ''
            if options[:show_json]
              puts execution.to_json
            else
              puts execution
            end
          end

          if options[:logs]
            puts ''
            wflog = wf.log(options[:execution_id])
            if options[:show_json]
              puts wflog.to_json
            else
              puts wflog
            end
          end
        else
          puts wf unless options[:executions]
        end

        # Last thing we're checking for, so if it's not wanted, just return
        return unless options[:executions]
        puts "\nWorkflow:   #{wf.name}"
        puts "ID:           #{wf.id}"
        puts "Description:  #{wf.description}"
        puts "Version:      #{wf.version}"
        puts "\nExecutions: "
        executions = {}
        wf.executions.each_value { |attrs| executions[attrs['startDate']] = attrs }
        keys = executions.keys.sort
        keys = keys.slice(keys.size - options[:last], keys.size) if options[:last] > 0
        keys.each do |timestamp|
          dataline = timestamp.to_s
          dataline << " [#{executions[timestamp]['id']}]"
          dataline << " #{executions[timestamp]['state']}"
          puts dataline
        end
      end
      # rubocop:enable CyclomaticComplexity, PerceivedComplexity
    end
  end
end
# rubocop:enable MethodLength, LineLength
