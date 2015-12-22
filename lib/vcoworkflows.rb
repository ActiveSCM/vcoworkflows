require 'thor'

require File.dirname(__FILE__) + '/vcoworkflows/version'
require File.dirname(__FILE__) + '/vcoworkflows/constants'
require File.dirname(__FILE__) + '/vcoworkflows/config'
require File.dirname(__FILE__) + '/vcoworkflows/vcosession'
require File.dirname(__FILE__) + '/vcoworkflows/workflowservice'
require File.dirname(__FILE__) + '/vcoworkflows/workflow'
require File.dirname(__FILE__) + '/vcoworkflows/workflowparameter'
require File.dirname(__FILE__) + '/vcoworkflows/workflowtoken'
require File.dirname(__FILE__) + '/vcoworkflows/cli/execute'
require File.dirname(__FILE__) + '/vcoworkflows/cli/query'

# Refer to README.md for use instructions
module VcoWorkflows
  # Start of main CLI processing
  class CLI < Thor
    package_name 'vcoworkflows'
    map '--version' => :version
    map '-v' => :version

    desc 'version', DESC_VERSION

    # Display the version of `vcoworkflows`
    def version
      puts VERSION
    end

    register(VcoWorkflows::Cli::Execute, 'execute', 'execute <WORKFLOW>', DESC_CLI_EXECUTE)
    register(VcoWorkflows::Cli::Query, 'query', 'query <WORKFLOW>', DESC_CLI_QUERY)
  end
end
# rubocop:enable LineLength
