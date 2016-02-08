require_relative 'constants'
require 'json'

module VcoWorkflows
  # WorkflowParameter is an object wrapper for workflow input and output
  # parameters.
  class WorkflowParameter
    # Parameter name
    # @return [String] parameter name
    attr_reader :name

    # Parameter type
    # @return [String] parameter type
    attr_reader :type

    # Parameter subtype (used when type is 'Array')
    # @return [String] parameter subtype
    attr_reader :subtype

    # Parameter value
    # @return [Object] parameter value
    attr_reader :value

    # rubocop:disable MethodLength

    # Create a new workflow parameter object
    # @param [String] name Name of the workflow parameter
    # @param [String] type Data type of the parameter (according to vCO)
    # @return [VcoWorkflows::WorkflowParameter]
    def initialize(name = nil, type = nil, options = {})
      # Merge provided options with our defaults
      options = {
        required: false,
        value: nil
      }.merge(options)

      @name = name

      case type
      when %r{\/}
        @type = type.gsub(%r{\/.*$}, '')
        @subtype = type.gsub(%r{^.*\/}, '')
      else
        @type = type
        @subtype = nil
      end

      @required = options[:required]

      # If value is supposed to be an array but we dont' have a value yet,
      # create an empty array. If it's not supposed to be an array, just
      # set the value, even if it's still nil.
      if options[:value].nil?
        @type.eql?('Array') ? @value = [] : @value = nil
      else
        @value = set(options[:value])
      end
    end
    # rubocop:enable MethodLength

    # Set the parameter value
    # @param [Object] value Value for the parameter
    def set(value)
      # Do some basic checking for Arrays.
      case @type
      when 'Array'
        raise(IOError, ERR[:param_verify_failed]) unless value.is_a?(Array)
      end unless value.nil?
      @value = value
    end
    # rubocop:enable CyclomaticComplexity

    # Has a value been set for this parameter?
    # @return [Boolean]
    def set?
      case value.class
      when Array
        value.empty? ? false : true
      else
        value.nil? ? false : true
      end
    end

    # rubocop:disable TrivialAccessors

    # Set whether or not this WorkflowParameter is required
    # @param [Boolean] required Set this parameter as required (if not specified)
    def required(required = true)
      @required = required
    end
    # rubocop:enable LineLength

    # Determine whether or not this WorkflowParameter has been marked as
    # required
    # @return [Boolean]
    def required?
      @required
    end
    # rubocop:enable TrivialAccessors

    # rubocop:disable CyclomaticComplexity, PerceivedComplexity, MethodLength

    # Return a string representation of the parameter
    # @return [String] Pretty-formatted string
    def to_s
      string = @name.to_s
      # If value is either nil or an empty array
      if @value.nil? || @value.is_a?(Array) && @value.empty?
        string << " (#{@type}"
        string << "/#{@subtype}" if @subtype
        string << ')'
        string << ' [required]' if @required
      elsif @type.eql?('Array')
        string << ' ='
        @value.each { |v| string << "\n  - #{v}" }
      else
        string << " = #{@value}"
      end
      string << "\n"
    end
    # rubocop:enable CyclomaticComplexity, PerceivedComplexity, MethodLength

    # Public
    # Return a JSON document representation of this object
    # @return [String] JSON representation
    def to_json
      as_struct.to_json
    end

    # rubocop:disable LineLength

    # Hashify the parameter (primarily useful for converting to JSON or YAML)
    # @return [Hash] Contents of this object as a hash
    def as_struct
      attributes = { type: @type, name: @name, scope: 'local' }

      # If the value is an array, we need to build it in the somewhat silly
      # manner that vCO requires it to be presented. Otherwise, just paste
      # it on the end of the hash.
      if @type.eql?('Array')
        raise(IOError, ERR[:wtf]) unless @value.is_a?(Array)
        attributes[:value] = { @type.downcase => { elements: [] } }
        @value.each { |val| attributes[:value][@type.downcase][:elements] << { @subtype => { value: val } } }
      else
        attributes[:value] = { @type => { value: @value } }
      end
      attributes
    end
    # rubocop:enable LineLength
  end
end
