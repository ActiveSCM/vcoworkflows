# VcoWorkflows
module VcoWorkflows
  # rubocop:disable LineLength

  #
  class Config
    # Where we nominally expect configuration files to be
    DEFAULT_CONFIG_DIR  = File.join((ENV['HOME'] || ENV['HOMEDRIVE']), '.vcoworkflows')

    # Default configuration file
    DEFAULT_CONFIG_FILE = File.join(DEFAULT_CONFIG_DIR, 'config.json')
  end

  # Options description messages

  # Version
  DESC_VERSION = 'Display the installed version of the VcoWorkflows gem'.freeze

  # Execute
  DESC_CLI_EXECUTE = 'Execute the specified workflow'.freeze

  # Query
  DESC_CLI_QUERY = 'Query vCO for a workflow'.freeze

  # Workflow
  DESC_CLI_WORKFLOW = 'Name of the workflow'.freeze

  # ID
  DESC_CLI_WORKFLOW_ID = 'GUID of the workflow'.freeze

  # dry-run
  DESC_CLI_DRY_RUN = 'Dry run; do not actually perform operations against vCO'.freeze

  # verbose
  DESC_CLI_VERBOSE = 'Show extra information'.freeze

  # name
  DESC_CLI_NAME = 'Name of the workflow to execute'.freeze

  # server
  DESC_CLI_SERVER = 'VMware vCenter Orchestrator server URL'.freeze

  # username
  DESC_CLI_USERNAME = 'vCO user name'.freeze

  # password
  DESC_CLI_PASSWORD = 'vCO password'.freeze

  # verify certificates
  DESC_CLI_VERIFY_SSL = 'Perform TSL Certificate verification'.freeze

  # watch execution
  DESC_CLI_EXECUTE_WATCH = 'Wait around for workflow results'.freeze

  # execution parameter list
  DESC_CLI_EXECUTE_PARAMETERS = 'Comma-separated list of key=value parameters for workflow'.freeze

  # query exeuction list
  DESC_CLI_QUERY_EXECS = 'Fetch a list of executions for the workflow'.freeze

  # limit queried execution list size
  DESC_CLI_QUERY_EXEC_LIM = 'Limit the number of returned executions to the most recent N'.freeze

  # exeuction id
  DESC_CLI_QUERY_EXEC_ID = 'Fetch the execution data for this execution GUID'.freeze

  # execution state
  DESC_CLI_QUERY_EXEC_STATE = 'Fetch the state of the specified workflow execution'.freeze

  # execution log
  DESC_CLI_QUERY_EXEC_LOG = 'In addition to execution data, show the execution log'.freeze

  # show JSON
  DESC_CLI_QUERY_JSON = 'Show the JSON document for the requested information'.freeze

  # What do all the vCO REST URIs start with?
  API_URL_BASE = '/vco/api'.freeze

  # error messages
  ERR = {
    wtf: 'vcoworkflows: I have no idea what just went wrong.',
    no_workflow_found: 'vcoworkflows: no workflow found!',
    too_many_workflows: 'vcoworkflows: more than one workflow found for given name!',
    wrong_workflow_wtf: 'vcoworkflows: search returned the wrong workflow! (?)',
    no_workflow_service_defined: 'vcoworkflows: Attempted to execute a workflow with a nil workflow service!',
    param_verify_failed: 'vcoworkflows: Attempt to verify required parameter failed!',
    no_such_parameter: 'Attempted to set a parameter that does not exist!',
    url_unset: 'No URL was configured, nothing to connect to!',
    username_unset: 'No username was specified, either by $VCO_USER or --username',
    password_unset: 'No password was specified, either by $VCO_PASSWD or --password'
  }.freeze

  # rubocop:enable LineLength
end
