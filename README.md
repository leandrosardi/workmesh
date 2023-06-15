**>>This Project is Under Construction<<**

# WorkMesh

WorkMesh is an open-source micro-services orchestration system for automatng software scaling and work distribution.

For creating your own micro-service, refer to [micro.template](https://github.com/leandrosardi/micro.template) project.

## 1. Getting Started

### 1.1. Installing WorkMesh

```bash
gem install workmesh
```

### 1.2. Defining Nodes

```ruby
BlackStack::WorkMesh.add_node({
    # unique node name
    :name => 'local',
    # setup REST-API communication
    :net_remote_ip => '127.0.0.1',
    :workmesh_api_key => '****', # keep this secret - don't push this to your repository.  
})
```

### 1.3. Defining Services

```ruby
BlackStack::WorkMesh.add_service({
    # unique service name
    :name => 'micro.emails.delivery',
    # Define the tasks table: each record is a task.
    #
    # In this example, each account in our saas is assigned to a micr-service node.
    # In other words, the work is assigned at an account-level.
    #
    # Each account is stored in a row in the `account` table.
    # 
    :entity_table => :account,
    # Define what is the column in the table where I store the name of the assigned node.
    :entity_field_assignation => :'node_for_micro_emails_delivery',
})
```

### 1.4. Assigning your Entities

```ruby
BlackStack::WorkMesh.assignation(:'micro.emails.delivery')
```

## 2. Removing Nodes

When removing a node, you need to re-assign its entitties.

```ruby
BlackStack::WorkMesh.remove_node(:local)
```

## 3. Adding Nodes

When adding a new node, you may want to re-distribute your entities.

Simply call the `assignation` method again, with the `:reassign` modifier.

```ruby
BlackStack::WorkMesh.assignation(:'micro.emails.delivery', {:reassign=>true})
```

