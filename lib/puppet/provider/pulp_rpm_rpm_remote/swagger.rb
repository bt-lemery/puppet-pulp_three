Puppet::Type.type(:pulp_rpm_rpm_remote).provide(:swagger) do
  mk_resource_methods
  desc 'Swagger API implementation for Pulp 3 rpm remote'

  def self.instances
    api_instance = do_login

    remotes = api_instance.list.results

    remotes.map do |remote|
      new(
        ensure: :present,
        name: remote.name,
        url: remote.url,
        policy: remote.policy,
        ca_cert: remote.ca_cert,
        client_cert: remote.client_cert,
        client_key: remote.client_key,
        tls_validation: remote.tls_validation,
        proxy_url: remote.proxy_url,
        download_concurrency: remote.download_concurrency,
        provider: :swagger,
      )
    end
  end

  def self.prefetch(resources)
    instances.each do |int|
      if (resource = resources[int.name])
        resource.provider = int
      end
    end
  end

  def self.do_login
    require 'yaml'
    require 'pulp_rpm_client'
    my_config = YAML.load_file('/etc/puppetlabs/swagger.yaml')

    PulpRpmClient.configure do |config|
      config.username = my_config['username']
      config.password = my_config['password']
    end

    api_instance = PulpRpmClient::RemotesRpmApi.new
    api_instance
  end

  def do_login
    require 'yaml'
    require 'pulp_rpm_client'
    my_config = YAML.load_file('/etc/puppetlabs/swagger.yaml')

    PulpRpmClient.configure do |config|
      config.username = my_config['username']
      config.password = my_config['password']
    end

    api_instance = PulpRpmClient::RemotesRpmApi.new
    api_instance
  end

  def exists?
    api_instance = do_login

    opts = {
      name: resource[:name],
    }

    results = api_instance.list(opts).results

    if results.empty?
      return false
    else
      result = api_instance.list(opts).results[0].name
      if result.empty?
        false
      else
        true
      end
    end
  end

  def create
    api_instance = do_login

    nr = PulpRpmClient::RpmRpmRemote.new(name: resource[:name], url: resource[:url], policy: resource[:policy], download_concurrency: resource[:download_concurrency])

    if resource[:proxy_url]
      nr.proxy_url = resource[:proxy_url]
    end

    if resource[:tls_validation]
      nr.tls_validation = resource[:tls_validation]
      ca_cert_to_string = File.read(resource[:ca_cert])
      nr.ca_cert = ca_cert_to_string
    end


    if resource[:client_cert]
      client_cert_to_string = File.read(resource[:client_cert])
      nr.client_cert = client_cert_to_string
    end

    if resource[:client_key]
      client_key_to_string = File.read(resource[:client_key])
      nr.client_key = client_key_to_string
    end

    puts "before submission, final nr looks like #{nr}"

    begin
      result = api_instance.create(nr)
    rescue PulpRpmClient::ApiError => e
      puts "Exception when calling RepositoriesRpmApi->create: #{e}"
    end
  end

  def destroy
  end

end
