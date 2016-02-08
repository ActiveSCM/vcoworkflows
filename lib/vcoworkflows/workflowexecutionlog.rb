require_relative 'workflowservice'
require 'json'

# VcoWorkflows
module VcoWorkflows
  # WorkflowExecutionLog is a simple object to contain the log for an
  # execution of a workflow.
  class WorkflowExecutionLog
    # Log messages
    # @return [String[]] Array of log message lines
    attr_reader :messages

    # Create an execution log object
    # @param [String] log_json JSON document as string
    # @return [VcoWorkflows::WorkflowExecutionLog]
    def initialize(log_json)
      @messages = {}
      JSON.parse(log_json)['logs'].each do |log_entry|
        messages[log_entry['entry']['time-stamp']] = log_entry['entry']
      end
    end

    # rubocop:disable MethodLength, LineLength

    # Stringify the log
    # @return [String]
    def to_s
      message = ''
      @messages.keys.sort.each do |timestamp|
        message << Time.at(timestamp / 1000).to_s
        message << " #{@messages[timestamp]['severity']}: #{@messages[timestamp]['user']}:"
        message << " #{@messages[timestamp]['short-description']}"
        unless @messages[timestamp]['short-description'].eql?(@messages[timestamp]['long-description'])
          message << "; #{@messages[timestamp]['long-description']}"
        end
        message << "\n"
      end
      message
    end
    # rubocop:enable MethodLength, LineLength
  end
end
