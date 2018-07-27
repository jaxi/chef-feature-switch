describe file('/tmp/fqdn_with_single_host') do
  it { should be_exist }
end

describe file('/tmp/fqdn_does_not_exist') do
  it { should_not be_exist }
end

describe file('/tmp/fqdn_with_wildcard') do
  it { should be_exist }
end

describe file('/tmp/empty_hosts') do
  it { should_not be_exist }
end
