require_relative '../spec_helper.rb'
require 'vcoworkflows'

# rubocop:disable LineLength
# rubocop:disable Metrics/BlockLength

describe VcoWorkflows::Workflow, 'Workflow' do
  before(:each) do
    # Set up some basic starting data
    @workflow_name = 'Request Component'
    @workflow_id = '6e04a460-4a45-4e16-9603-db2922c24462'
    @execution_id = 'ff8080814a1cb55c014a6481a9927a78'
    @workflow_json = '{"output-parameters":[{"name":"result","type":"string","description":"Catalog item request state"},{"name":"requestNumber","type":"number"},{"name":"requestCompletionDetails","type":"string"}],"relations":{"link":[{"rel":"up","href":"https://vco.example.com:8281/vco/api/inventory/System/Workflows/dlinsley%2540vmware.com/vCAC/"},{"rel":"executions","href":"https://vco.example.com:8281/vco/api/workflows/6e04a460-4a45-4e16-9603-db2922c24462/executions/"},{"rel":"presentation","href":"https://vco.example.com:8281/vco/api/workflows/6e04a460-4a45-4e16-9603-db2922c24462/presentation/"},{"rel":"tasks","href":"https://vco.example.com:8281/vco/api/workflows/6e04a460-4a45-4e16-9603-db2922c24462/tasks/"},{"rel":"icon","href":"https://vco.example.com:8281/vco/api/workflows/6e04a460-4a45-4e16-9603-db2922c24462/icon/"},{"rel":"schema","href":"https://vco.example.com:8281/vco/api/workflows/6e04a460-4a45-4e16-9603-db2922c24462/schema/"},{"rel":"permissions","href":"https://vco.example.com:8281/vco/api/workflows/6e04a460-4a45-4e16-9603-db2922c24462/permissions/"},{"rel":"interactions","href":"https://vco.example.com:8281/vco/api/workflows/6e04a460-4a45-4e16-9603-db2922c24462/interactions/"}]},"id":"6e04a460-4a45-4e16-9603-db2922c24462","name":"Request Component","version":"0.0.33","description":"","href":"https://vco.example.com:8281/vco/api/workflows/6e04a460-4a45-4e16-9603-db2922c24462/","customized-icon":false,"input-parameters":[{"name":"coreCount","type":"string"},{"name":"ramMB","type":"string"},{"name":"onBehalfOf","type":"string"},{"name":"machineCount","type":"string"},{"name":"businessUnit","type":"string"},{"name":"reservation","type":"string"},{"name":"location","type":"string"},{"name":"environment","type":"string"},{"name":"image","type":"string","description":"vCenter template name"},{"name":"runlist","type":"Array/string","description":"Chef Runlist for first run.  Leave empty for no Chef"},{"name":"nodename","type":"string","description":"Chef Nodename"},{"name":"component","type":"string"},{"name":"attributesJS","type":"string","description":"JSON object of vCenter Attributes to apply to VM(s)"}]}'
    @presentation_json = '{"output-parameters":[{"name":"machineCount","type":"string"},{"name":"location","type":"string"},{"name":"image","type":"string","description":"vCenter template name"},{"name":"coreCount","type":"string"},{"name":"ramMB","type":"string"},{"name":"onBehalfOf","type":"string"},{"name":"businessUnit","type":"string"},{"name":"environment","type":"string"},{"name":"component","type":"string"},{"name":"reservation","type":"string"},{"name":"runlist","type":"Array/string","description":"Chef Runlist for first run.  Leave empty for no Chef"},{"name":"nodename","type":"string","description":"Chef Nodename"},{"name":"attributesJS","type":"string","description":"JSON object of vCenter Attributes to apply to VM(s)"}],"input-parameters":[{"name":"businessUnit","type":"string","description":"businessUnit"},{"name":"environment","type":"string","description":"environment"},{"name":"component","type":"string","description":"component"},{"name":"onBehalfOf","type":"string","description":"On Behalf of User: (user@domain format)"},{"name":"machineCount","type":"string","description":"machineCount"},{"name":"image","type":"string","description":"image"},{"name":"coreCount","type":"string","description":"coreCount"},{"name":"ramMB","type":"string","description":"ramSizeMB"},{"name":"runlist","type":"Array/string","description":"runlist"},{"name":"reservation","type":"string","description":"reservation"},{"name":"location","type":"string","description":"location"},{"name":"attributesJS","type":"string","description":"JSON object of vCenter Attributes to apply to VM(s)"},{"name":"nodename","type":"string","description":"Chef Nodename"}],"href":"https://vco.example.com:8281/vco/api/workflows/6e04a460-4a45-4e16-9603-db2922c24462/presentation/","name":"Request Component","id":"6e04a460-4a45-4e16-9603-db2922c24462","steps":[{"step":{"messages":[],"hidden":false,"elements":[{"fields":[{"display-name":"businessUnit","constraints":[{"@type":"mandatory"}],"@type":"field","fields":[],"id":"businessUnit","description":"businessUnit","hidden":false,"messages":[],"decorators":[{"array":{"elements":[{"string":{"value":"an"}},{"string":{"value":"aw"}},{"string":{"value":"soi"}}]},"@type":"drop-down"}],"type":"string"},{"display-name":"environment","constraints":[{"@type":"mandatory"}],"@type":"field","fields":[],"id":"environment","description":"environment","hidden":false,"messages":[],"decorators":[],"type":"string"},{"display-name":"component","constraints":[{"@type":"mandatory"}],"@type":"field","fields":[],"id":"component","description":"component","hidden":false,"messages":[],"decorators":[],"type":"string"},{"display-name":"On Behalf of User: (user@domain format)","constraints":[],"@type":"field","fields":[],"id":"onBehalfOf","description":"On Behalf of User: (user@domain format)","hidden":false,"messages":[],"decorators":[],"type":"string"},{"display-name":"machineCount","constraints":[],"@type":"field","fields":[],"id":"machineCount","description":"machineCount","hidden":false,"messages":[],"decorators":[{"array":{"elements":[{"string":{"value":"1"}},{"string":{"value":"2"}},{"string":{"value":"3"}},{"string":{"value":"4"}},{"string":{"value":"5"}},{"string":{"value":"6"}},{"string":{"value":"7"}},{"string":{"value":"8"}},{"string":{"value":"9"}},{"string":{"value":"10"}}]},"@type":"drop-down"}],"type":"string"},{"display-name":"image","constraints":[{"@type":"mandatory"}],"@type":"field","fields":[],"id":"image","description":"image","hidden":false,"messages":[],"decorators":[{"array":{"elements":[{"string":{"value":"vcaccentos65v8-agent"}},{"string":{"value":"win2012std"}},{"string":{"value":"vcac2012std"}},{"string":{"value":"centos-6.6-x86_64-20141203-1"}},{"string":{"value":"v8-centos65-agent"}},{"string":{"value":"vcac2008r2std"}},{"string":{"value":"oracle-6.5-x86_64-20141203-1"}},{"string":{"value":"centos65v8"}},{"string":{"value":"w2012r2std_coreservices"}},{"string":{"value":"2008r2std"}}]},"@type":"drop-down"}],"type":"string"},{"display-name":"coreCount","constraints":[{"@type":"mandatory"}],"@type":"field","fields":[],"id":"coreCount","description":"coreCount","hidden":false,"messages":[],"decorators":[{"@type":"refresh-on-change"},{"array":{"elements":[{"string":{"value":"1"}},{"string":{"value":"2"}},{"string":{"value":"4"}},{"string":{"value":"8"}}]},"@type":"drop-down"}],"type":"string"},{"display-name":"ramSizeMB","constraints":[{"@type":"mandatory"}],"@type":"field","fields":[],"id":"ramMB","description":"ramSizeMB","hidden":false,"messages":[],"decorators":[{"array":{"elements":[null]},"@type":"drop-down"}],"type":"string"},{"display-name":"runlist","constraints":[],"@type":"field","fields":[],"id":"runlist","description":"runlist","hidden":false,"messages":[],"decorators":[],"type":"Array/string"},{"display-name":"reservation","constraints":[{"@type":"mandatory"}],"@type":"field","fields":[],"id":"reservation","description":"reservation","hidden":false,"messages":[],"decorators":[],"type":"string"},{"display-name":"location","constraints":[],"@type":"field","fields":[],"id":"location","description":"location","hidden":false,"messages":[],"decorators":[],"type":"string"},{"display-name":"JSON object of vCenter Attributes to apply to VM(s)","constraints":[],"@type":"field","fields":[],"id":"attributesJS","description":"JSON object of vCenter Attributes to apply to VM(s)","hidden":false,"messages":[],"decorators":[{"@type":"multiline"}],"type":"string"},{"display-name":"Chef Nodename","constraints":[],"@type":"field","fields":[],"id":"nodename","description":"Chef Nodename","hidden":false,"messages":[],"decorators":[],"type":"string"}],"messages":[],"hidden":false,"@type":"group"}]}}],"relations":{"link":[{"rel":"up","href":"https://vco.example.com:8281/vco/api/workflows/6e04a460-4a45-4e16-9603-db2922c24462/"},{"rel":"instances","href":"https://vco.example.com:8281/vco/api/workflows/6e04a460-4a45-4e16-9603-db2922c24462/presentation/instances/"},{"rel":"add","href":"https://vco.example.com:8281/vco/api/workflows/6e04a460-4a45-4e16-9603-db2922c24462/presentation/instances/"}]}}'
    @param_string_json = '{"type":"string","name":"stringparam","scope":"local","value":{"string":{"value":"squirrel!"}}}'
    @param_array_json = '{"type":"Array/string","name":"arrayparam","scope":"local","value":{"array":{"elements":[{"string":{"value":"a"}},{"string":{"value":"b"}},{"string":{"value":"c"}}]}}}'

    @target_parameters = {
      'coreCount'    => 2,
      'ramMB'        => 2048,
      'businessUnit' => 'aw',
      'reservation'  => 'nonprodlinux',
      'environment'  => 'dev1',
      'image'        => 'centos-6.6-x86_64-20141203-1',
      'component'    => 'api',
      'onBehalfOf'   => 'svcacct@example.com',
      'location'     => 'us_east',
      'runlist'      => %w(role[loc_uswest] role[base] role[api]),
      'machineCount' => 1
    }

    # Mock the WorkflowService
    @service = double('service')
    allow(@service).to receive(:get_workflow_for_id).and_return(@workflow_json)
    allow(@service).to receive(:get_workflow_for_name).and_return(@workflow_json)
    allow(@service).to receive(:get_presentation).and_return(@presentation_json)

    # Config object, file, data for constructor testing
    @config_file = '/tmp/vcoconfig.json'
    @config_data = {
      url: @url,
      username: @username,
      password: @password
    }.to_json
    @config = VcoWorkflows::Config.new(url: 'https://vcoserver.example.com:8281/vco/api',
                                       username: 'johndoe',
                                       password: 's3cre3t')
    allow(VcoWorkflows::VcoSession).to receive(:new).and_return(true)
    allow(VcoWorkflows::WorkflowService).to receive(:new).and_return(@service)
    allow(File).to receive(:read).and_call_original
    allow(File).to receive(:read).with(@config_file).and_return(@config_data)
  end

  it 'should not explode when created with service' do
    wf = VcoWorkflows::Workflow.new(@workflow_name, service: @service)

    expect(wf).to_not eq(nil)
  end

  it 'should not explode when created with config' do
    wf = VcoWorkflows::Workflow.new(@workflow_name, config: @config)

    expect(wf).to_not eq(nil)
  end

  it 'should not explode when created with config_file' do
    wf = VcoWorkflows::Workflow.new(@workflow_name)

    expect(wf).to_not eq(nil)
  end

  it 'should parse a single string parameter' do
    param_data = []
    param_data << JSON.parse(@param_string_json)
    wfparams = VcoWorkflows::Workflow.parse_parameters(param_data)

    expect(wfparams).to_not eq(nil)
    expect(wfparams.size).to eq(1)
    expect(wfparams.key?('stringparam')).to eq(true)
    expect(wfparams['stringparam'].type).to eql('string')
    expect(wfparams['stringparam'].subtype).to eq(nil)
    expect(wfparams['stringparam'].value).to eql('squirrel!')
  end

  it 'should parse a single Array parameter' do
    param_data = []
    param_data << JSON.parse(@param_array_json)
    wfparams = VcoWorkflows::Workflow.parse_parameters(param_data)

    expect(wfparams).to_not eq(nil)
    expect(wfparams.size).to eq(1)
    expect(wfparams.key?('arrayparam')).to eq(true)
    expect(wfparams['arrayparam'].type).to eql('Array')
    expect(wfparams['arrayparam'].subtype).to eql('string')
    expect(wfparams['arrayparam'].value).to eql(%w[a b c])
  end

  it 'should parse an array of mixed parameters' do
    param_data = []
    param_data << JSON.parse(@param_string_json)
    param_data << JSON.parse(@param_array_json)
    wfparams = VcoWorkflows::Workflow.parse_parameters(param_data)

    expect(wfparams).to_not eq(nil)
    expect(wfparams.size).to eq(2)
    expect(wfparams.key?('stringparam')).to eq(true)
    expect(wfparams['stringparam'].type).to eql('string')
    expect(wfparams['stringparam'].subtype).to eq(nil)
    expect(wfparams['stringparam'].value).to eql('squirrel!')
    expect(wfparams.key?('arrayparam')).to eq(true)
    expect(wfparams['arrayparam'].type).to eql('Array')
    expect(wfparams['arrayparam'].subtype).to eql('string')
    expect(wfparams['arrayparam'].value).to eql(%w[a b c])
  end

  it 'should have input and output parameters' do
    input_param_count = 13
    output_param_count = 3
    wf = VcoWorkflows::Workflow.new(@workflow_name, service: @service)

    expect(wf.input_parameters.size).to eq(input_param_count)
    expect(wf.output_parameters.size).to eq(output_param_count)
  end

  it 'should have required parameters' do
    required_param_count = 7
    wf = VcoWorkflows::Workflow.new(@workflow_name, service: @service)

    expect(wf.required_parameters.size).to eq(required_param_count)
  end

  it 'should set a parameter value' do
    wf = VcoWorkflows::Workflow.new(@workflow_name, service: @service)

    # Set the value and check the returned parameter
    expect(wf.parameter('coreCount', 4).value).to eq(4)

    # Check the parameter value
    expect(wf.parameter('coreCount').value).to eq(4)

    # Check the parameter by reaching through input_parameters
    expect(wf.input_parameters['coreCount'].value).to eq(4)
  end

  it 'should set all parameters by hash' do
    wf = VcoWorkflows::Workflow.new(@workflow_name, service: @service)
    wf.parameters = @target_parameters

    @target_parameters.each_key do |param_name|
      expect(wf.parameter(param_name).value).to eql(@target_parameters[param_name])
    end
  end

  it 'should set a parameter by object' do
    wf = VcoWorkflows::Workflow.new(@workflow_name, service: @service)
    wfparam = VcoWorkflows::WorkflowParameter.new('coreCount', 'string', value: 2)
    wf.parameter = wfparam

    expect(wf.parameter('coreCount')).to_not eq(nil)
    expect(wf.parameter('coreCount').type).to eql('string')
    expect(wf.parameter('coreCount').value).to eq(2)
  end

  it 'should execute' do
    allow(@service).to receive(:execute_workflow) { @execution_id }

    wf = VcoWorkflows::Workflow.new(@workflow_name, service: @service)
    wf.parameters = @target_parameters

    expect(wf.execute).to eql(@execution_id)
  end

  it 'should provide a WorkflowToken' do
    token_json = '{"relations":{"link":[{"href":"https://vco.example.com:8281/vco/api/workflows/6e04a460-4a45-4e16-9603-db2922c24462/executions/","rel":"up"},{"href":"https://vco.example.com:8281/vco/api/workflows/6e04a460-4a45-4e16-9603-db2922c24462/executions/ff8080814a1cb55c014a6481a9927a78/","rel":"remove"},{"href":"https://vco.example.com:8281/vco/api/workflows/6e04a460-4a45-4e16-9603-db2922c24462/executions/ff8080814a1cb55c014a6481a9927a78/logs/","rel":"logs"},{"href":"https://vco.example.com:8281/vco/api/workflows/6e04a460-4a45-4e16-9603-db2922c24462/executions/ff8080814a1cb55c014a6481a9927a78/state/","rel":"state"}]},"id":"ff8080814a1cb55c014a6481a9927a78","state":"completed","name":"Request Component","href":"https://vco.example.com:8281/vco/api/workflows/6e04a460-4a45-4e16-9603-db2922c24462/executions/ff8080814a1cb55c014a6481a9927a78/","start-date":1419025426833,"end-date":1419026124320,"started-by":"someuser@EXAMPLE.COM","input-parameters":[{"value":{"string":{"value":"2"}},"type":"string","name":"coreCount","scope":"local"},{"value":{"string":{"value":"2048"}},"type":"string","name":"ramMB","scope":"local"},{"value":{"string":{"value":"svcacct@example.com"}},"type":"string","name":"onBehalfOf","scope":"local"},{"value":{"string":{"value":"1"}},"type":"string","name":"machineCount","scope":"local"},{"value":{"string":{"value":"aw"}},"type":"string","name":"businessUnit","scope":"local"},{"value":{"string":{"value":"nonprodlinux"}},"type":"string","name":"reservation","scope":"local"},{"value":{"string":{"value":"us_east"}},"type":"string","name":"location","scope":"local"},{"value":{"string":{"value":"dev1"}},"type":"string","name":"environment","scope":"local"},{"value":{"string":{"value":"centos-6.6-x86_64-20141203-1"}},"type":"string","name":"image","scope":"local"},{"value":{"array":{"elements":[{"string":{"value":"role[loc_uswest]"}},{"string":{"value":"role[base]"}},{"string":{"value":"role[api]"}}]}},"type":"Array/string","name":"runlist","scope":"local"},{"value":{"string":{"value":""}},"type":"string","name":"nodename","scope":"local"},{"value":{"string":{"value":"api"}},"type":"string","name":"component","scope":"local"},{"value":{"string":{"value":""}},"type":"string","name":"attributesJS","scope":"local"}],"output-parameters":[{"value":{"string":{"value":"SUCCESSFUL"}},"type":"string","name":"result","scope":"local"},{"value":{"number":{"value":326.0}},"type":"number","name":"requestNumber","scope":"local"},{"value":{"string":{"value":"Request succeeded. Created vm00378."}},"type":"string","name":"requestCompletionDetails","scope":"local"}]}'
    allow(@service).to receive(:get_execution) { token_json }

    wf = VcoWorkflows::Workflow.new(@workflow_name, service: @service)
    wftoken = wf.token(@execution_id)

    expect(wftoken).to_not eq(nil)
    expect(wftoken.workflow_id).to eq(wf.id)
    expect(wftoken.id).to eq(@execution_id)
    expect(wftoken.alive?).to eq(false)
    expect(wftoken.state).to eql('completed')
  end

  it 'should provide a WorkflowExectionLog' do
    log_json = '{"logs":[{"entry":{"severity":"info","time-stamp":1419026124333,"user":"gruiz-ade","short-description":"Workflow \'Request Component\' has completed","long-description":"Workflow \'Request Component\' has completed"}},{"entry":{"severity":"info","time-stamp":1419026123927,"user":"gruiz-ade","short-description":"Workflow \'Request Component\' has resumed","long-description":"Workflow \'Request Component\' has resumed"}},{"entry":{"severity":"info","time-stamp":1419025439183,"user":"gruiz-ade","short-description":"Workflow is paused","long-description":"Workflow \'Request Component\' has paused while waiting on signal"}},{"entry":{"severity":"info","time-stamp":1419025426870,"user":"gruiz-ade","short-description":"Workflow \'Request Component\' has started","long-description":"Workflow \'Request Component\' has started"}}]}'
    allow(@service).to receive(:get_log) { log_json }

    wf = VcoWorkflows::Workflow.new(@workflow_name, service: @service)
    wflog = wf.log(@execution_id)

    expect(wflog).to_not eq(nil)
  end
end
# rubocop:enable LineLength
