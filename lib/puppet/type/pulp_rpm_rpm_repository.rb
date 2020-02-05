Puppet::Type.newtype(:pulp_rpm_rpm_repository) do
  @doc = "Manage a Pulp 3 RPM repository"
  ensurable

  newparam(:name, :namevar => true) do
    desc "A unique name for this repository."
  end

  newproperty(:description) do
    desc "An optional description."
  end
end
