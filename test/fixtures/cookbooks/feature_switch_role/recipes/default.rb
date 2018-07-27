%w{
  single_role
  role_doesnt_exist
  roles_all_match
  one_role_doesnt_match
  host_matches_role_doesnt
  both_host_and_roles_match
  role_matches_host_doesnt
  either_role_matches
  explicitly_roles_all_match
  not_rockstar
  complex_role_condition
  complex_role_condition_2
}.each do |filename|
  file_path = File.join('/', 'tmp', filename)
  file file_path do
    action :delete
  end

  if node.has_feature?(filename)
    file file_path do
      content 'hello'
    end
  end
end
