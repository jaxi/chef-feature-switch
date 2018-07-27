# chef-feature-switch

`chef-feature-switch` allows you to turn feature on/off in Chef cookbooks based on node's roles and FQDN, which allows certain changes to be canary rolled out before fully configuration deployment.

## Prerequisites

* You have all your cookbooks, data bags and roles sit in a monolithic configuration repository, at the same time being version controlled.
* The repository is always in-sync with your chef server(s).
* Cookbook version is meaningless to you. The 'latest' cookbook is always applied to every single node that is managed by chef server.

## Use cases

First thing first, you need to have `depends 'chef-feature-switch'` added into your cookbook `metadata.rb` file.

### FQDN based feature switch

Says you have 4 RoR servers for each dev and sandbox environment, you want to install `jemalloc` in half of the dev and sandbox nodes to testing out the impact on memory. Rather than creating adhoc roles that contain jmalloc install in role's run list, you can

Create a data bag item inside `features` databag

```json
{
  "id": "install_jemalloc",
  "hosts":[
    "sandbox_(1|2).webapp.svc",
    "dev_1.webapp.svc",
    "dev_2.webapp.svc"
  ]
}
```

Then in your Chef cookbook recipe,

```ruby
if node.has_feature? 'install_jemalloc'
  package "jemalloc"
end
```

Once you are happy with the change, you can

* Remove the feature switch in data bag
* Have `package "jemalloc"` in your cookbook and rollout the change globally


**You can also have feature switch based on both fqdn and roles, check `test/fixtures` for examples!**

### Role based feature switch

You can do something similar based on role as well. Says you want to roll out `jemalloc` change on instance with web or proxy roles, and at the same time exclude db role, you can:

Have features data bag item looks like
```json
{
  "id": "install_jemalloc",
  "roles": {
    "cond": "AND",
    "target": [
      {
        "cond": "OR",
        "target": ["web", "proxy"]
      }
      {
        "cond": "NOT",
        "target": "db"
      }
    ]
  }
}
```

and have

```ruby
if node.has_feature? 'install_jemalloc'
  package "jemalloc"
end
```

in your cookbook recipe.


## Why don't you just have the logic in cookbook?

You might think "arguably you can have the logic baked into the cookbook with something looks like

```ruby
if node[:fqdn] =~ "sandbox_(1|2).webapp.svc"
  package "jemalloc"
end
```

why bother having extra databag layer??"


Problem is these hard-coded logics might just stay in the cookbook forever. By using the `chef-feature-switch`, `databags/features` can be used as a list of tech debts. Team should always tidy up these feature switch (simply by removing them), and keep the number of "features" as low as possible

## How to test

```bash
kitchen converge # To converge the change in vagrant boxes
kitchen verify # To have inspec test kicking in
```


