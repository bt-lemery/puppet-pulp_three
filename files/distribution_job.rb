#!/opt/puppetlabs/puppet/bin/ruby

# ./distribution_job.rb --publication-name rhel-7-rsyslog --base-path rsyslog/7/x86_64 --publication "/pulp/api/v3/publications/rpm/rpm/73f8d971-0451-452a-adf8-4f6bf8dd11eb/"
# Need repository name in publish job to get repository href, find repository href in repository list.  Get pulp_href of publication to pass as 'publication' to distribution job.

require 'optparse'
require 'pulp_rpm_client'

options = {}

optparse = OptionParser.new do |opts|
  opts.banner = "Usage: sync_job.rb [options]"

  opts.on('-n', '--publication-name NAME', 'Name') { |v| options[:publication_name] = v }
  opts.on('-b', '--base-path NAME', 'Base path') { |v| options[:base_path] = v }
  opts.on('-p', '--publication NAME', 'Publication') { |v| options[:publication] = v }
end

begin
  optparse.parse!
  mandatory = [:publication_name]
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

puts "Creating distribution"

api_instance = do_login(PulpRpmClient::DistributionsRpmApi.new)

data = PulpRpmClient::RpmRpmDistribution.new(name: options[:publication_name], base_path: options[:base_path], publication: options[:publication])

begin
  #Create a rpm distribution
  result = api_instance.create(data)
  p result
rescue PulpRpmClient::ApiError => e
  puts "Exception when calling DistributionsRpmApi->create: #{e}"
end
