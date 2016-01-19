require_relative '../spec_helper.rb'
require 'vcoworkflows'

describe VcoWorkflows::VcoSession, 'VcoSession' do
  before(:each) do
    @uri = 'https://vcoserver.example.com:8281'
    @username = 'johndoe'
    @password = 's3cr3t'

    @config = VcoWorkflows::Config.new(url: @uri, username: @username, password: @password)
  end

  it 'should set the URL from parameters' do
    vs = VcoWorkflows::VcoSession.new(uri: @uri, user: @username, password: @password)
    api_url = '/vco/api'

    expect(vs.rest_resource.url).to eql(@uri << api_url)
  end

  it 'should set the username from parameters' do
    vs = VcoWorkflows::VcoSession.new(uri: @uri, user: @username, password: @password)

    expect(vs.rest_resource.user).to eql(@username)
  end

  it 'should set the password from parameters' do
    vs = VcoWorkflows::VcoSession.new(uri: @uri, user: @username, password: @password)

    expect(vs.rest_resource.password).to eql(@password)
  end

  it 'should set the URL from configuration' do
    vs = VcoWorkflows::VcoSession.new(config: @config)
    api_url = '/vco/api'

    expect(vs.rest_resource.url).to eql(@uri << api_url)
  end

  it 'should set the username from configuration' do
    vs = VcoWorkflows::VcoSession.new(config: @config)

    expect(vs.rest_resource.user).to eql(@username)
  end

  it 'should set the password from configuration' do
    vs = VcoWorkflows::VcoSession.new(config: @config)

    expect(vs.rest_resource.password).to eql(@password)
  end
end

# rubocop:enable LineLength
