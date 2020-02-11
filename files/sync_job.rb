#!/opt/puppetlabs/puppet/bin/ruby
require 'optparse'
require 'pulp_rpm_client'

options = {}

optparse = OptionParser.new do |opts|
  opts.banner = "Usage: sync_job.rb [options]"

  opts.on('-l', '--repository NAME', 'Local repository') { |v| options[:local_repository] = v }
  opts.on('-r', '--remote NAME', 'Remote source') { |v| options[:remote_source] = v }
  opts.on("-o", "--[no-]overwrite [FLAG]", TrueClass, "Whether to remove all content in the local repo not found in remote") do |v|
    options[:overwrite] = v.nil? ? true : v
  end
end

begin
  optparse.parse!
  mandatory = [:local_repository, :remote_source]
  missing = mandatory.select{ |param| options[param].nil? }
  raise OptionParser::MissingArgument, missing.join(', ') unless missing.empty?
rescue OptionParser::ParseError => e
  puts e
  puts optparse
  exit
end

if options[:overwrite] && options[:overwrite].to_s == 'true'
  mirror_option = 'true'
else
  mirror_option = 'false'
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

api_instance = do_login(PulpRpmClient::RemotesRpmApi.new)

ropts = {
  name: options[:remote_source]
}

repository_sync_url = api_instance.list(ropts).results[0].pulp_href

puts "Syncing local repo #{options[:local_repository]} with content from the #{options[:remote_source]} remote"

api_instance = do_login(PulpRpmClient::RepositoriesRpmApi.new)

data = PulpRpmClient::RepositorySyncURL.new(remote: repository_sync_url, mirror: mirror_option)

begin
  #Sync from remote
  result = api_instance.sync(rpm_repository_href, data)
  p result
rescue PulpRpmClient::ApiError => e
  puts "Exception when calling RepositoriesRpmApi->sync: #{e}"
end
