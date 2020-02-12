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
        tls_validation: remote.tls_validation.to_s,
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
      nr.tls_validation = cast_to_bool(resource[:tls_validation].to_s)
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
    api_instance = do_login

    rpm_remote_href = get_href_by_name(resource[:name])

    begin
      api_instance.delete(rpm_remote_href)
    rescue PulpRpmClient::ApiError => e
      puts "Exception when calling RemotesRpmApi->delete: #{e}"
    end
  end

  def url=(_value)
    api_instance = do_login

    rpm_remote_href = get_href_by_name(resource[:name])

    data = PulpRpmClient::RpmRpmRemote.new(url: resource[:url])

    begin
      #Partially update a rpm remote
      result = api_instance.partial_update(rpm_remote_href, data)
      p result
    rescue PulpRpmClient::ApiError => e
      puts "Exception when calling RemotesRpmApi->partial_update: #{e}"
    end
  end

  def proxy_url=(_value)
    api_instance = do_login

    rpm_remote_href = get_href_by_name(resource[:name])

    data = PulpRpmClient::RpmRpmRemote.new(proxy_url: resource[:proxy_url])

    begin
      #Partially update a rpm remote
      result = api_instance.partial_update(rpm_remote_href, data)
      p result
    rescue PulpRpmClient::ApiError => e
      puts "Exception when calling RemotesRpmApi->partial_update: #{e}"
    end
  end

  def download_concurrency=(_value)
    api_instance = do_login

    rpm_remote_href = get_href_by_name(resource[:name])

    data = PulpRpmClient::RpmRpmRemote.new(download_concurrency: resource[:download_concurrency])

    begin
      #Partially update a rpm remote
      result = api_instance.partial_update(rpm_remote_href, data)
      p result
    rescue PulpRpmClient::ApiError => e
      puts "Exception when calling RemotesRpmApi->partial_update: #{e}"
    end
  end

  def policy=(_value)
    api_instance = do_login

    rpm_remote_href = get_href_by_name(resource[:name])

    data = PulpRpmClient::RpmRpmRemote.new(policy: resource[:policy])

    begin
      #Partially update a rpm remote
      result = api_instance.partial_update(rpm_remote_href, data)
      p result
    rescue PulpRpmClient::ApiError => e
      puts "Exception when calling RemotesRpmApi->partial_update: #{e}"
    end
  end

  def tls_validation=(_value)
    api_instance = do_login

    rpm_remote_href = get_href_by_name(resource[:name])

    tls_validation_bool = cast_to_bool(resource[:tls_validation].to_s)

    data = PulpRpmClient::RpmRpmRemote.new(tls_validation: tls_validation_bool)

    begin
      #Partially update a rpm remote
      result = api_instance.partial_update(rpm_remote_href, data)
      p result
    rescue PulpRpmClient::ApiError => e
      puts "Exception when calling RemotesRpmApi->partial_update: #{e}"
    end
  end

  def get_href_by_name(remote_name)
    api_instance = do_login

    opts = {
      name: remote_name,
    }

    result = api_instance.list(opts).results[0].pulp_href
  end

  def cast_to_bool(foo)
    return true if foo == 'true'
    return false if foo == 'false'
  end

end
