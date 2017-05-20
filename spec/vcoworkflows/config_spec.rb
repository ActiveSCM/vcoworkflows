require_relative '../spec_helper.rb'
require 'vcoworkflows'
describe VcoWorkflows::Config, 'Config' do
  before(:each) do
    @url = 'https://vcoserver.example.com:8281/vco/api'
    @username = 'johndoe'
    @password = 's3cr3t'

    @config_file = '/tmp/vcoconfig.json'
    @config_data = {
      url: @url,
      username: @username,
      password: @password
    }.to_json

    allow(File).to receive(:read).and_call_original
    allow(File).to receive(:read).with(@config_file).and_return(@config_data)
  end

  it 'should configure the URL from parameters' do
    config = VcoWorkflows::Config.new(url: @url, username: @username, password: @password)

    expect(config.url).to eql(@url)
  end

  it 'should configure the username from parameters' do
    config = VcoWorkflows::Config.new(url: @url, username: @username, password: @password)

    expect(config.username).to eql(@username)
  end

  it 'should configure the password from parameters' do
    config = VcoWorkflows::Config.new(url: @url, username: @username, password: @password)

    expect(config.password).to eql(@password)
  end

  it 'should configure the URL from a configuration file' do
    config = VcoWorkflows::Config.new(config_file: @config_file)

    expect(config.url).to eql(@url)
  end

  it 'should configure the username from a configuration file' do
    config = VcoWorkflows::Config.new(config_file: @config_file)

    expect(config.username).to eql(@username)
  end

  it 'should configure the password from a configuration file' do
    config = VcoWorkflows::Config.new(config_file: @config_file)

    expect(config.password).to eql(@password)
  end
end
