require_relative 'constants'
require_relative 'workflowservice'
require_relative 'workflow'
require_relative 'workflowtoken'
require_relative 'workflowparameter'
require 'json'

# VcoWorkflows
module VcoWorkflows
  # WorkflowPresentation is a helper class for Workflow and is primarily used
  # internally to apply additional constraints to WorkflowParameters. Currently
  # WorkflowPresentation examines the presentation JSON from vCO to determine
  # whether input parameters for the workflow are required or not.
  class WorkflowPresentation
    # Accessor for the data structure
    # @return [Hash] parsed JSON
    attr_reader :presentation_data

    # Get the list of required parameters for the workflow
    # @return [String[]] Array of strings (names of parameters)
    attr_reader :required

    # rubocop:disable MethodLength

    # Create a new WorkflowPresentation
    # @param [VcoWorkflows::WorkflowService] workflow_service workflow service to use
    # @param [String] workflow_id workflow GUID
    # @return [VcoWorkflows::WorkflowPresentation]
    def initialize(workflow_service, workflow_id)
      @required = []
      @presentation_data = JSON.parse(workflow_service.get_presentation(workflow_id))

      # Determine if there are any required input parameters
      # We're parsing this because we specifically want to know if any of
      # the input parameters are marked as required. This is very specifically
      # in the array of hashes in:
      # presentation_data[:steps][0][:step][:elements][0][:fields]
      fields = @presentation_data['steps'][0]['step']['elements'][0]['fields']
      fields.each do |attribute|
        next unless attribute.key?('constraints')
        attribute['constraints'].each do |const|
          if const.key?('@type') && const['@type'].eql?('mandatory')
            @required << attribute['id']
          end
        end
      end
    end

    # String representation of the presentation
    # @return [String]
    def to_s
      @presentation_data.to_s
    end

    # JSON document
    # @return [String] JSON Document
    def to_json
      JSON.pretty_generate(@presentation_data)
    end
  end
  # rubocop:enable ClassLength
end
