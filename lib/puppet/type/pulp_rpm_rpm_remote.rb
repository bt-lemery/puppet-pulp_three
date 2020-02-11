Puppet::Type.newtype(:pulp_rpm_rpm_remote) do
  @doc = "Manage a Pulp 3 RPM remote"
  ensurable

  newparam(:name, :namevar => true) do
    desc "A unique name for this remote."
  end

  newproperty(:url) do
    desc "The URL of an external content source."
  end

  newparam(:ca_cert) do
    desc "Path to the PEM encoded CA certificate used to validate the server certificate presented by the remote server."
  end

  newparam(:client_cert) do
    desc "Path to a file containing the PEM encoded client certificate used for authentication."
  end

  newparam(:client_key) do
    desc "Path to a file containing a PEM encoded private key used for authentication."
  end

  newproperty(:tls_validation) do
    desc "Whether to perform TLS peer validation."
    defaultto false
    newvalues(true, false)
  end

  newproperty(:proxy_url) do
    desc "A proxy URL to use when connecting in the format: scheme://user:password@host:port"
  end

  newproperty(:download_concurrency) do
    desc "Total number of simultaneous connections."
    defaultto 20
  end

  newproperty(:policy) do
    desc "The policy to use when downloading content."
    defaultto "immediate"
    # newvalues('immediate', 'on_demand', 'streamed')
  end
end
