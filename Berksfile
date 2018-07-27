source 'https://supermarket.chef.io'

metadata

def fixture(name)
  cookbook "feature_switch_#{name}",
    path: File.join('test', 'fixtures', 'cookbooks', "feature_switch_#{name}")
end

group :integration do
  fixture 'fqdn'
  fixture 'role'
end
