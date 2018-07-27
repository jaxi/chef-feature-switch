%w{
  fqdn_with_single_host
  fqdn_does_not_exist
  fqdn_with_wildcard
  empty_hosts
}.each do |filename|
  file_path = File.join('/', 'tmp', filename)
  file file_path do
    action :delete
  end

  if node.has_feature? filename
    file file_path do
      content 'hello'
    end
  end
end
