**>>This Project is Under Construction<<**

![Gem version](https://img.shields.io/gem/v/workmesh)![Gem downloads](https://img.shields.io/gem/dt/workmesh)

# Workmesh

Workmesh is an open-source micro-services orchestration system for automating software scaling and work distribution.

Some hints:

- In the **Workmesh** world, a **micro-service** is an **external web-service** who receives tasks for any kind of offline processing, and returns the result to **master**. Just that. Nothing more.

- This library is for defininng the micro-service protocol at the **master** side.

- For creating your own micro-service, refer to [micro.template](https://github.com/leandrosardi/micro.template) project.

- If you are looking for a multi-threading processing framework, you should refer to [Pampa](https://github.com/leandrosardi/workmesh) instead.

## 1. Getting Started

### 1.1. Installing Workmesh

```bash
gem install workmesh
```

### 1.2. Defining Nodes

```ruby
BlackStack::Workmesh.add_node({
    # unique node name
    :name => 'local',
    # setup REST-API communication
    :net_remote_ip => '127.0.0.1',
    :ssh_username => 'leandro', # example: root
    :ssh_port => 22,
    :ssh_password => '2404',
    # workmesh parameters
    :workmesh_api_key => '****', # keep this secret - don't push this to your repository. 
    :workmesh_port => 3000, 
})
```

### 1.3. Defining Services

```ruby
BlackStack::Workmesh.add_service({
    # unique service name
    :name => 'micro.emails.timeline',
    # Define the tasks table: each record is a task.
    #
    # In this example, each account in our saas is assigned to a micr-service node.
    # In other words, the work is assigned at an account-level.
    #
    # Each account is stored in a row in the `account` table.
    # 
    :entity_table => BlackStack::MySaaS::Account,
    # Define what is the column in the table where I store the name of the assigned node.
    :entity_field_assignation => :'node_for_micro_emails_timeline',
})
```

Deciding at which is the right entity for distributing your work is an important design desicion.

### 1.4. Assigning your Entities

```ruby
account = BlackStack::MySaaS::Account.where(:node_for_micro_emails_timeline=>nil).first
BlackStack::Workmesh.assign(account, :'micro.emails.timeline')
```

## 2. Re-Assigning your Entities

This code works for:

- When removing a node, you need to re-assign its entitties.

- When adding a new node, you may want to re-distribute your entities.

Simply call the `assign` method again, with the `:reassign` modifier.

```ruby
BlackStack::Workmesh.assign(account, :'micro.emails.timeline', {:reassign=>true})
```

## 3. Defining Protocol

The protocol is defining:

- How one or more different objects are pushed to the micro-service.
- How one or more different objects are updated from the micro-service.

The protocol for push data to the micro-serivce is like the code below.

```ruby
BlackStack::Workmesh.add_service({
    # unique service name
    :name => 'micro.emails.timeline',
    # Define the tasks table: each record is a task.
    #
    # In this example, each account in our saas is assigned to a micr-service node.
    # In other words, the work is assigned at an account-level.
    #
    # Each account is stored in a row in the `account` table.
    # 
    :entity_table => BlackStack::MySaaS::Account,
    # Define what is the column in the table where I store the name of the assigned node.
    :entity_field_assignation => :'node_for_micro_emails_timeline',

    # Defining micro-service protocol.
    # This is the list of entities at the SaaS side.
    :protocol => [{
        # I need to push all the emails delivered and received, including bounce reports.
        :entity_table => BlackStack::Emails::Delivery,
        :entity_field_id => :id, # identify each record in the table uniquely
        :entity_field_sort => :create_time # push/process/pull entities in this order - Workmesh uses this field to know which was the latest record pushed/processed/pulled.
        :push_function => Proc.new do |entity, l, *args|
            # TODO: Code Me!
            # Write a REST-API call here. 
        end,
    }, {
        # I need to push all the emails opens
        :entity_table => BlackStack::Emails::Open,
        :entity_field_id => :id, # identify each record in the table uniquely
        :entity_field_sort => :create_time # push/process/pull entities in this order - Workmesh uses this field to know which was the latest record pushed/processed/pulled.
        :push_function => Proc.new do |entity, l, *args|
            # TODO: Code Me!
            # Write a REST-API call here. 
        end,
    }, {
        # I need to push all the clicks
        :entity_table => BlackStack::Emails::Click,
        :entity_field_id => :id, # identify each record in the table uniquely
        :entity_field_sort => :create_time # push/process/pull entities in this order - Workmesh uses this field to know which was the latest record pushed/processed/pulled.
        :push_function => Proc.new do |entity, l, *args|
            # TODO: Code Me!
            # Write a REST-API call here. 
        end,
    }, {
        # I need to push all the unsubscribes
        :entity_table => BlackStack::Emails::Unsubscribe,
        :entity_field_id => :id, # identify each record in the table uniquely
        :entity_field_sort => :create_time # push/process/pull entities in this order - Workmesh uses this field to know which was the latest record pushed/processed/pulled.
        :push_function => Proc.new do |entity, l, *args|
            # TODO: Code Me!
            # Write a REST-API call here. 
        end,
    }],
})
```

The push of data to the micro-service will update some flags: `:entity_field_push_time`, `:entity_field_push_success`, `:entity_field_push_error_description`.

```ruby
BlackStack::Workmesh.add_service({
    # unique service name
    :name => 'micro.emails.timeline',
    # Define the tasks table: each record is a task.
    #
    # In this example, each account in our saas is assigned to a micr-service node.
    # In other words, the work is assigned at an account-level.
    #
    # Each account is stored in a row in the `account` table.
    # 
    :entity_table => BlackStack::MySaaS::Account,
    # Define what is the column in the table where I store the name of the assigned node.
    :entity_field_assignation => :'node_for_micro_emails_timeline',

    # Defining micro-service protocol.
    # This is the list of entities at the SaaS side.
    :protocol => [{
        # I need to push all the emails delivered and received, including bounce reports.
        :entity_table => BlackStack::Emails::Delivery,
        :entity_field_id => :id, # identify each record in the table uniquely
        :entity_field_sort => :create_time # push/process/pull entities in this order - Workmesh uses this field to know which was the latest record pushed/processed/pulled.
        :push_function => Proc.new do |entity, l, *args|
            # TODO: Code Me!
            # Write a REST-API call for push a record. 
        end,
        :entity_field_push_time => :'micro_emails_delivery_push_time',
        :entity_field_push_success => :'micro_emails_delivery_push_success',
        :entity_field_push_error_description => :'micro_emails_delivery_push_error_description',
    }, {
        # ....
    }],
})
```

The protocol for pulling data from the micro-service is like the code below.

```ruby
BlackStack::Workmesh.add_service({
    # unique service name
    :name => 'micro.emails.timeline',
    # Define the tasks table: each record is a task.
    #
    # In this example, each account in our saas is assigned to a micr-service node.
    # In other words, the work is assigned at an account-level.
    #
    # Each account is stored in a row in the `account` table.
    # 
    :entity_table => BlackStack::MySaaS::Account,
    # Define what is the column in the table where I store the name of the assigned node.
    :entity_field_assignation => :'node_for_micro_emails_timeline',

    # Defining micro-service protocol.
    # This is the list of entities at the SaaS side.
    :protocol => [{
        # I need to push all the emails delivered and received, including bounce reports.
        :entity_table => BlackStack::Emails::Delivery,
        :entity_field_id => :id, # identify each record in the table uniquely
        :entity_field_sort => :create_time # push/process/pull entities in this order - Workmesh uses this field to know which was the latest record pushed/processed/pulled.
        :push_function => Proc.new do |entity, l, *args|
            # TODO: Code Me!
            # Write a REST-API call for push a record. 
        end,
        :entity_field_push_time => :'micro_emails_delivery_push_time',
        :entity_field_push_success => :'micro_emails_delivery_push_success',
        :entity_field_push_error_description => :'micro_emails_delivery_push_error_description',

        # defining protocol for pull processed data
        :pull_status_access_point => '/api/1.0/delivery/status.json'
        :pull_function => Proc.new do |entity, l, *args|
            # TODO: Code Me!
            # Write a REST-API call for pull a record.
        end,
    }, {
        # ....
    }],
})
```

Assuming that
1. Workmesh pushes entities in order definined by `:entity_field_sort`, and 
2. Your micro-service will process each entity in the same order, ....
... Workmesh will call the access point `/api/1.0/delivery/status.json` to know what is the ID of the latest processed record, and will run the `pull_function` for all the processed records pending of being pulled.

The pull of data from the micro-service will update some flags too: `:entity_field_pull_time`, `:entity_field_pull_success`, `:entity_field_pull_error_description`.

```ruby
BlackStack::Workmesh.add_service({
    # unique service name
    :name => 'micro.emails.timeline',
    # Define the tasks table: each record is a task.
    #
    # In this example, each account in our saas is assigned to a micr-service node.
    # In other words, the work is assigned at an account-level.
    #
    # Each account is stored in a row in the `account` table.
    # 
    :entity_table => BlackStack::MySaaS::Account,
    # Define what is the column in the table where I store the name of the assigned node.
    :entity_field_assignation => :'node_for_micro_emails_timeline',

    # Defining micro-service protocol.
    # This is the list of entities at the SaaS side.
    :protocol => [{
        # I need to push all the emails delivered and received, including bounce reports.
        :entity_table => BlackStack::Emails::Delivery,
        :entity_field_id => :id, # identify each record in the table uniquely
        :entity_field_sort => :create_time # push/process/pull entities in this order - Workmesh uses this field to know which was the latest record pushed/processed/pulled.
        :push_function => Proc.new do |entity, l, *args|
            # TODO: Code Me!
            # Write a REST-API call for push a record. 
        end,
        :entity_field_push_time => :'micro_emails_delivery_push_time',
        :entity_field_push_success => :'micro_emails_delivery_push_success',
        :entity_field_push_error_description => :'micro_emails_delivery_push_error_description',

        # defining protocol for pull processed data
        :pull_status_access_point => '/api/1.0/delivery/status.json'
        :pull_function => Proc.new do |entity, l, *args|
            # TODO: Code Me!
            # Write a REST-API call for pull a record.
        end,
        :entity_field_pull_time => :'micro_emails_delivery_pull_time',
        :entity_field_pull_success => :'micro_emails_delivery_pull_success',
        :entity_field_pull_error_description => :'micro_emails_delivery_pull_error_description',
    }, {
        # ....
    }],
})
```

When you re-assign an entity to another node, you can choose re-submit (push) all the data to the new new, from the very beginning.

```ruby
BlackStack::Workmesh.assign(account, :'micro.emails.timeline', {:reassign=>true, :repush=>true})
```

## 4. Defining Assignation Criteria

_(only the `:roundrobin` criteria has been developed)_

**Workmesh** can assign entities based on 3 critierias:

1. Round-Robin (default).
2. Number of Entities.
3. Weight of Entities.

Deciding which criteria works better for your micro-service is an important design decision.

```ruby
BlackStack::Workmesh.add_service({
    # unique service name
    :name => 'micro.emails.timeline',
    # Define the tasks table: each record is a task.
    #
    # In this example, each account in our saas is assigned to a micr-service node.
    # In other words, the work is assigned at an account-level.
    #
    # Each account is stored in a row in the `account` table.
    # 
    :entity_table => BlackStack::MySaaS::Account,
    # Define what is the column in the table where I store the name of the assigned node.
    :entity_field_assignation => :'node_for_micro_emails_timeline',

    # Defining assign criteria
    :assign => :entityweight, # other choices are: `:roundrobin` and `:entitynumber`

    # Defining a function deciding the weight of an entity.
    # This function applies only of assign criteria is `:entityweight`.
    :entity_weight => Proc.new do |entity, l, *args|
        # TODO: Code Me!
        return 1
    end,
})
```

You can also define the maximum weight supported by a node.

```ruby
BlackStack::Workmesh.add_node({
    # unique node name
    :name => 'local',
    # setup REST-API communication
    :net_remote_ip => '127.0.0.1',
    :ssh_username => 'leandro', # example: root
    :ssh_port => 22,
    :ssh_password => '2404',
    # workmesh parameters
    :workmesh_api_key => '****', # keep this secret - don't push this to your repository.  
    :workmesh_port => 3000, 
    # max weight supported
    max_weight => {
        # define the max-weight supported for each service with assign criteria `:entityweight`
        :'micro.emails.timeline' => 500,
    },
})
```

You can also define the maximum number of entities supported by a node.

```ruby
BlackStack::Workmesh.add_node({
    # unique node name
    :name => 'local',
    # setup REST-API communication
    :net_remote_ip => '127.0.0.1',
    :ssh_username => 'leandro', # example: root
    :ssh_port => 22,
    :ssh_password => '2404',
    # workmesh parameters
    :workmesh_api_key => '****', # keep this secret - don't push this to your repository. 
    :workmesh_port => 3000,  
    # max weight supported
    max_weight => {
        # define the max-weight supported for each service with assign criteria `:entityweight`
        :'micro.emails.timeline' => 500,
    },
    # max entities supported
    max_entities => {
        # define the max-entities supported for each service with assign criteria `:roundrobin` or `:entitynumber`
        :'micro.emails.appending' => 5000,
    },
})
```

## 5. Running

Pushing entities to the micro-services.

```ruby
BlackStack::Workmesh.push :'micro.emails.timeline'
```

Pulling data from the micro-services.

```ruby
BlackStack::Workmesh.pull :'micro.emails.timeline'
```

## 6. Auto-Scaling

_(this feature has not been developed yet)_

**Auto-Scaling** is adding or removing nodes automatically.

_(this feature has not been developed yet)_

## 7. Workmesh CLI

_(this feature has not been developed yet)_

Getting the status of each node.

```bash
$ ruby mesh.rb --nodes
``` 

```bash
|node       |       workload|
|-----------|---------------|
|node1      |             10|
|node2      |          10000|
```

Getting the status of each service.

```bash
$ ruby mesh.rb --services
``` 

```bash
|node       |          nodes|        pending|         failed|      processed|
|-----------|---------------|---------------|---------------|---------------|
|service1   |             10|             10|             10|             10|
|service2   |           1000|             10|             10|             10|
```