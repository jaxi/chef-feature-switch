
class Chef
  class Node
    include Chef::DSL::DataQuery

    DEFAULT_FEATURE_BAG = 'features'.freeze

    # Public: Check whether a node has certain feature
    #
    # Parameters:
    #    name: name of the feature
    #    data_bag: the data bag that helds the source of truth. Defaults to 'features'
    #
    # An example databag may look like
    # {
    #   "id": "foo",
    #   "hosts":[
    #     "www.example.com",
    #     "*.vagrantup.com"
    #   ]
    # }
    #
    # in which is a 'host based' feature, whereas the has_feature? method is expected to
    # return true when the node's FQDN is 'www.example.com' or anything matches `*.vagrantup.com`
    # (e.g. chef.vagrantup.com)
    #
    # Return true/false
    def has_feature?(name, data_bag: DEFAULT_FEATURE_BAG)
      begin
        feature = data_bag_item(data_bag, name)
      rescue StandardError => ex
        Chef::Log.debug("Feature #{name.inspect} cannot be found from #{node[:fqdn].inspect}")
        return false
      end

      if !feature["hosts"] && !feature["roles"]
        return false
      end

      host_match_in_feature?(feature) &&
        role_match_in_feature?(feature)
    end

    private

    InvalidRoleOpsError = Class.new(StandardError)

    def host_match_in_feature?(feature)
      return true unless feature["hosts"]

      feature["hosts"].any? do |expected_host|
        Regexp.new("^#{expected_host}$").match?(node[:fqdn])
      end
    end


    ROLE_CONDITION_OPS = [
      OP_ALL = "all?".freeze,
      OR_ANY = "any?".freeze,
    ]

    ROLE_COND = [
      AND_COND = "AND".freeze,
      OR_COND  = "OR".freeze,
      NOT_COND = "NOT".freeze,
    ]

    ROLE_CONDITION_OP_MAP = {
      "AND" => OP_ALL,
      "OR"  => OR_ANY,
    }

    def role_match_in_feature?(feature, cond: AND_COND)
      return true unless feature["roles"]

      recur_role_match_in_feature?(feature["roles"], cond: cond)
    end

    def recur_role_match_in_feature?(roles, cond: AND_COND)
      case roles
      when Array
        cond = AND_COND
      when Hash
        cond = roles["cond"]
        roles = roles.fetch("target", [])
      when String
        return node.role?(roles)
      end

      case cond
      when AND_COND, OR_COND
        roles.public_send(ROLE_CONDITION_OP_MAP[cond]) do |expected_role|
          recur_role_match_in_feature?(expected_role)
        end
      when NOT_COND
        !recur_role_match_in_feature?(roles)
      else
        raise InvalidRoleOpsError,
          "#{cond.inspect} is not a valid feature switch condition"
      end
    end
  end
end
