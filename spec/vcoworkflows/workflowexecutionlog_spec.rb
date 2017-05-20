require_relative '../spec_helper.rb'
require 'vcoworkflows'

# rubocop:disable LineLength

describe VcoWorkflows::WorkflowExecutionLog, 'WorkflowExecutionLog' do
  before(:each) do
    # Set up some basic starting data
    @workflow_name = 'Request Component'
    @workflow_id = '6e04a460-4a45-4e16-9603-db2922c24462'

    # The JSON we'd get back from vCenter Orchestrator
    @log_json = '{"logs":[{"entry":{"severity":"info","time-stamp":1419026124333,"user":"gruiz-ade","short-description":"Workflow \'Request Component\' has completed","long-description":"Workflow \'Request Component\' has completed"}},{"entry":{"severity":"info","time-stamp":1419026123927,"user":"gruiz-ade","short-description":"Workflow \'Request Component\' has resumed","long-description":"Workflow \'Request Component\' has resumed"}},{"entry":{"severity":"info","time-stamp":1419025439183,"user":"gruiz-ade","short-description":"Workflow is paused","long-description":"Workflow \'Request Component\' has paused while waiting on signal"}},{"entry":{"severity":"info","time-stamp":1419025426870,"user":"gruiz-ade","short-description":"Workflow \'Request Component\' has started","long-description":"Workflow \'Request Component\' has started"}}]}'
  end

  it 'should initialize and parse the log JSON' do
    wflog = VcoWorkflows::WorkflowExecutionLog.new(@log_json)
    expect(wflog).to_not eq(nil)
    expect(wflog.messages.size).to eq(4)
  end
end
# rubocop:enable LineLength
