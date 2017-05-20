require_relative '../spec_helper.rb'
require 'vcoworkflows'

# rubocop:disable LineLength
# rubocop:disable Metrics/BlockLength

describe VcoWorkflows::WorkflowToken, 'WorkflowToken' do
  before(:each) do
    # Set up some basic starting data
    @workflow_name = 'Request Component'
    @workflow_id = '6e04a460-4a45-4e16-9603-db2922c24462'
    @execution_id = 'ff8080814a1cb55c014a6481a9927a78'

    # The JSON we'd get back from vCenter Orchestrator
    @token_json = '{"relations":{"link":[{"href":"https://vco.example.com:8281/vco/api/workflows/6e04a460-4a45-4e16-9603-db2922c24462/executions/","rel":"up"},{"href":"https://vco.example.com:8281/vco/api/workflows/6e04a460-4a45-4e16-9603-db2922c24462/executions/ff8080814a1cb55c014a6481a9927a78/","rel":"remove"},{"href":"https://vco.example.com:8281/vco/api/workflows/6e04a460-4a45-4e16-9603-db2922c24462/executions/ff8080814a1cb55c014a6481a9927a78/logs/","rel":"logs"},{"href":"https://vco.example.com:8281/vco/api/workflows/6e04a460-4a45-4e16-9603-db2922c24462/executions/ff8080814a1cb55c014a6481a9927a78/state/","rel":"state"}]},"id":"ff8080814a1cb55c014a6481a9927a78","state":"completed","name":"Request Component","href":"https://vco.example.com:8281/vco/api/workflows/6e04a460-4a45-4e16-9603-db2922c24462/executions/ff8080814a1cb55c014a6481a9927a78/","start-date":1419025426833,"end-date":1419026124320,"started-by":"someuser@EXAMPLE.COM","input-parameters":[{"value":{"string":{"value":"2"}},"type":"string","name":"coreCount","scope":"local"},{"value":{"string":{"value":"2048"}},"type":"string","name":"ramMB","scope":"local"},{"value":{"string":{"value":"svcacct@example.com"}},"type":"string","name":"onBehalfOf","scope":"local"},{"value":{"string":{"value":"1"}},"type":"string","name":"machineCount","scope":"local"},{"value":{"string":{"value":"aw"}},"type":"string","name":"businessUnit","scope":"local"},{"value":{"string":{"value":"nonprodlinux"}},"type":"string","name":"reservation","scope":"local"},{"value":{"string":{"value":"us_east"}},"type":"string","name":"location","scope":"local"},{"value":{"string":{"value":"dev1"}},"type":"string","name":"environment","scope":"local"},{"value":{"string":{"value":"centos-6.6-x86_64-20141203-1"}},"type":"string","name":"image","scope":"local"},{"value":{"array":{"elements":[{"string":{"value":"role[loc_uswest]"}},{"string":{"value":"role[base]"}},{"string":{"value":"role[api]"}}]}},"type":"Array/string","name":"runlist","scope":"local"},{"value":{"string":{"value":""}},"type":"string","name":"nodename","scope":"local"},{"value":{"string":{"value":"api"}},"type":"string","name":"component","scope":"local"},{"value":{"string":{"value":""}},"type":"string","name":"attributesJS","scope":"local"}],"output-parameters":[{"value":{"string":{"value":"SUCCESSFUL"}},"type":"string","name":"result","scope":"local"},{"value":{"number":{"value":326.0}},"type":"number","name":"requestNumber","scope":"local"},{"value":{"string":{"value":"Request succeeded. Created vm00378."}},"type":"string","name":"requestCompletionDetails","scope":"local"}]}'

    # Mock the WorkflowService
    @service = double('service')
    allow(@service).to receive(:get_execution) { @token_json }
  end

  it 'should successfully initialize from token json' do
    token = VcoWorkflows::WorkflowToken.new(@service, @workflow_id, @execution_id)

    expect(token).to_not eq(nil)
  end

  it 'should match the workflow id' do
    token = VcoWorkflows::WorkflowToken.new(@service, @workflow_id, @execution_id)

    expect(token.id).to eql(@execution_id)
  end

  it 'should match the execution id' do
    token = VcoWorkflows::WorkflowToken.new(@service, @workflow_id, @execution_id)

    expect(token.workflow_id).to eql(@workflow_id)
  end

  it 'should match the workflow name' do
    token = VcoWorkflows::WorkflowToken.new(@service, @workflow_id, @execution_id)

    expect(token.name).to eql(@workflow_name)
  end

  it 'should be completed' do
    token = VcoWorkflows::WorkflowToken.new(@service, @workflow_id, @execution_id)

    expect(token.alive?).to eq(false)
    expect(token.state).to eql('completed')
  end

  it 'should have been successful' do
    token = VcoWorkflows::WorkflowToken.new(@service, @workflow_id, @execution_id)

    expect(token.output_parameters['result'].value).to eql('SUCCESSFUL')
  end

  it 'should have an end date' do
    token = VcoWorkflows::WorkflowToken.new(@service, @workflow_id, @execution_id)

    expect(token.end_date).to_not eq(nil)
  end
end
# rubocop:enable LineLength
