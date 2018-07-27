describe file('/tmp/single_role') do
  it { should be_exist }
end

describe file('/tmp/role_doesnt_exist') do
  it { should_not be_exist }
end

describe file('/tmp/roles_all_match') do
  it { should be_exist }
end

describe file('/tmp/one_role_doesnt_match') do
  it { should_not be_exist }
end

describe file('/tmp/host_matches_role_doesnt') do
  it { should_not be_exist }
end

describe file('/tmp/both_host_and_roles_match') do
  it { should be_exist }
end

describe file('/tmp/role_matches_host_doesnt') do
  it { should_not be_exist }
end

describe file('/tmp/either_role_matches') do
  it { should be_exist }
end

describe file('/tmp/explicitly_roles_all_match') do
  it { should be_exist }
end

describe file('/tmp/not_rockstar') do
  it { should be_exist }
end

describe file('/tmp/complex_role_condition') do
  it { should be_exist }
end

describe file('/tmp/complex_role_condition_2') do
  it { should be_exist }
end
