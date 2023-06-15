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
    :name => 'micro.emails.timeline',
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

Deciding at which is the right entity for distributing your work is an important design desicion.

### 1.4. Assigning your Entities

```ruby
BlackStack::WorkMesh.assignation(:'micro.emails.timeline')
```

## 2. Re-Assigning your Entities

This code works for:

- When removing a node, you need to re-assign its entitties.

- When adding a new node, you may want to re-distribute your entities.

Simply call the `assignation` method again, with the `:reassign` modifier.

```ruby
BlackStack::WorkMesh.assignation(:'micro.emails.timeline', {:reassign=>true})
```

## 3. Defining Protocol

The protocol is defining:

- How one or more different objects are pushed to the micro-service.
- How one or more different objects are updated from the micro-service.

```ruby
BlackStack::WorkMesh.add_service({
    # unique service name
    :name => 'micro.emails.timeline',
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

# TODO: Write this

})
```

## 4. Defining Assignation Criteria

**WorkMesh** can assign entities based on 3 critierias:

1. Round-Robin (default).
2. Number of Entities.
3. Weight of Entities.

Deciding which criteria works better for your micro-service is an important design decision.

```ruby
BlackStack::WorkMesh.add_service({
    # unique service name
    :name => 'micro.emails.timeline',
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

    # Defining assignation criteria
    :assignation => :entityweight, # other choices are: `:roundrobin` and `:entitynumber`

    # Defining a function deciding the weight of an entity.
    # This function applies only of assignation criteria is `:entityweight`.
    :entity_weight => Proc.new do |entity, l, *args|
        # TODO: Code Me!
        return 1
    end,
})
```

You can also define the maximum weight supported by a node.

```ruby
BlackStack::WorkMesh.add_node({
    # unique node name
    :name => 'local',
    # setup REST-API communication
    :net_remote_ip => '127.0.0.1',
    :workmesh_api_key => '****', # keep this secret - don't push this to your repository.  
    # max weight supported
    max_weight => {
        # define the max-weight supported for each service with assignation criteria `:entityweight`
        :'micro.emails.timeline' => 500,
    },
})
```

You can also define the maximum number of entities supported by a node.

```ruby
BlackStack::WorkMesh.add_node({
    # unique node name
    :name => 'local',
    # setup REST-API communication
    :net_remote_ip => '127.0.0.1',
    :workmesh_api_key => '****', # keep this secret - don't push this to your repository.  
    # max weight supported
    max_weight => {
        # define the max-weight supported for each service with assignation criteria `:entityweight`
        :'micro.emails.timeline' => 500,
    },
    # max entities supported
    max_entities => {
        # define the max-entities supported for each service with assignation criteria `:roundrobin` or `:entitynumber`
        :'micro.emails.appending' => 5000,
    },
})
```