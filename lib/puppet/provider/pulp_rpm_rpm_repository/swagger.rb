Puppet::Type.type(:pulp_rpm_rpm_repository).provide(:swagger) do
  mk_resource_methods
  desc 'Swagger API implementation for Pulp 3 rpm repository'

  def self.instances
    api_instance = do_login

    repositories = api_instance.list.results

    repositories.map do |repository|
      new(
        ensure: :present,
        name: repository.name,
        description: repository.description,
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

    api_instance = PulpRpmClient::RepositoriesRpmApi.new
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

    api_instance = PulpRpmClient::RepositoriesRpmApi.new
    api_instance
  end

  def exists?
    api_instance = do_login

    opts = {
      name: resource[:name],
    }

    results = api_instance.list(opts).results

    if results.empty?
      false
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

    nr = PulpRpmClient::RpmRpmRepository.new(name: resource[:name], description: resource[:description])

    begin
      result = api_instance.create(nr)
    rescue PulpRpmClient::ApiError => e
      puts "Exception when calling RepositoriesRpmApi->create: #{e}"
    end
  end

  def destroy
    api_instance = do_login

    pulp_href = get_href_by_name(resource[:name])

    begin
      api_instance.delete(pulp_href)
    rescue PulpRpmClient::ApiError => e
      puts "Exception when calling RepositoriesRpmApi->delete: #{e}"
    end
  end

  def get_href_by_name(repository_name)
    api_instance = do_login

    opts = {
      name: repository_name,
    }

    result = api_instance.list(opts).results[0].pulp_href
  end

end
