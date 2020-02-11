#!/opt/puppetlabs/puppet/bin/ruby
require 'optparse'
require 'pulp_rpm_client'

options = {}

optparse = OptionParser.new do |opts|
  opts.banner = "Usage: sync_job.rb [options]"

  opts.on('-l', '--repository NAME', 'Local repository') { |v| options[:local_repository] = v }
end

begin
  optparse.parse!
  mandatory = [:local_repository]
  missing = mandatory.select{ |param| options[param].nil? }
  raise OptionParser::MissingArgument, missing.join(', ') unless missing.empty?
rescue OptionParser::ParseError => e
  puts e
  puts optparse
  exit
end

def do_login(object)
  require 'yaml'
  require 'pulp_rpm_client'
  my_config = YAML.load_file('/etc/puppetlabs/swagger.yaml')

  PulpRpmClient.configure do |config|
    config.username = my_config['username']
    config.password = my_config['password']
  end

  api_instance = object
  api_instance
end

api_instance = do_login(PulpRpmClient::RepositoriesRpmApi.new)

ropts = {
  name: options[:local_repository]
}
rpm_repository_href = api_instance.list(ropts).results[0].pulp_href

puts "Publishing local repo #{options[:local_repository]}"

api_instance = do_login(PulpRpmClient::PublicationsRpmApi.new)

data = PulpRpmClient::RpmRpmPublication.new(repository: rpm_repository_href)

begin
  #Create a rpm publication
  result = api_instance.create(data)
  p result
rescue PulpRpmClient::ApiError => e
  puts "Exception when calling PublicationsRpmApi->create: #{e}"
end
