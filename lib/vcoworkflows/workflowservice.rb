require_relative 'constants'
require_relative 'vcosession'
require_relative 'workflow'
require_relative 'workflowexecutionlog'
require 'json'
require 'erb'

include ERB::Util

module VcoWorkflows
  # WorkflowService is the object which acts as the interface to the vCO
  # API, and is loosely modeled from the vCO API documentation.
  class WorkflowService
    # The VcoSession used by this service
    # @return [VcoWorkflows::VcoSession]
    attr_reader :session

    # Create a new WorkflowService
    # @param [VcoWorkflows::VcoSession] session Session object for the API endpoint
    # @return [VcoWorkflows::WorkflowService]
    def initialize(session)
      @session = session
    end
    # rubocop:enable LineLength

    # Get a workflow by GUID
    # @param [String] id Workflow GUID
    # @return [String] the JSON document of the requested workflow
    def get_workflow_for_id(id)
      @session.get("/workflows/#{id}").body
    end

    # Get the presentation for the given workflow GUID
    # @param [String] workflow_id workflow GUID
    # @return [String] JSON document representation of Workflow Presentation
    def get_presentation(workflow_id)
      @session.get("/workflows/#{workflow_id}/presentation/").body
    end

    # Get one workflow with a specified name.
    # @param [String] name Name of the workflow
    # @return [String] the JSON document of the requested workflow
    def get_workflow_for_name(name)
      path = "/workflows?conditions=name=#{url_encode(name)}"
      response = JSON.parse(@session.get(path).body)

      # barf if we got anything other than a single workflow
      raise(IOError, ERR[:too_many_workflows]) if response['total'] > 1
      raise(IOError, ERR[:no_workflow_found]) if response['total'] == 0

      # yank out the workflow id and name from the result attributes
      workflow_id = nil
      response['link'][0]['attributes'].each do |a|
        workflow_id = a['value'] if a['name'].eql?('id')
      end

      # Get the workflow by GUID
      get_workflow_for_id(workflow_id)
    end

    # Get a WorkflowToken for the requested workflow_id and execution_id
    # @param [String] workflow_id Workflow GUID
    # @param [String] execution_id Execution GUID
    # @return [String] JSON document for workflow token
    def get_execution(workflow_id, execution_id)
      path = "/workflows/#{workflow_id}/executions/#{execution_id}"
      @session.get(path).body
    end

    # Get a list of executions for the given workflow GUID
    # @param [String] workflow_id Workflow GUID
    # @return [Hash] workflow executions, keyed by execution ID
    def get_execution_list(workflow_id)
      path = "/workflows/#{workflow_id}/executions/"
      relations = JSON.parse(@session.get(path).body)['relations']
      # The first two elements of the relations['link'] array are URLS,
      # so scrap them. Everything else is an execution.
      executions = {}
      relations['link'].each do |link|
        next unless link.key?('attributes')
        attributes = {}
        link['attributes'].each { |a| attributes[a['name']] = a['value'] }
        executions[attributes['id']] = attributes
      end
      executions
    end

    # Get the log for a specific execution
    # @param [String] workflow_id Workflow GUID
    # @param [String] execution_id Workflow execution ID
    # @return [String] JSON log document
    def get_log(workflow_id, execution_id)
      path = "/workflows/#{workflow_id}/executions/#{execution_id}/logs/"
      @session.get(path).body
    end

    # Submit the given workflow for execution
    # @param [String] id Workflow GUID for the workflow we want to execute
    # @param [String] parameter_json JSON document of input parameters
    # @return [String] Execution ID
    def execute_workflow(id, parameter_json)
      path = "/workflows/#{id}/executions/"
      response = @session.post(path, parameter_json)
      # Execution ID is the final component in the Location header URL, so
      # chop off the front, then pull off any trailing /
      response.headers[:location].gsub(%r{^.*/executions/}, '').gsub(%r{\/$}, '')
    end
  end
end
