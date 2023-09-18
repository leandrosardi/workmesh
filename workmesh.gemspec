Gem::Specification.new do |s|
  s.name        = 'workmesh'
  s.version     = '1.0.5'
  s.date        = '2023-09-18'
  s.summary     = "WorkMesh is an open-source micro-services orchestration system for automatng software scaling and work distribution."
  s.description = "WorkMesh is an open-source micro-services orchestration system for automatng software scaling and work distribution.

  Some hints:
  
  - In the **WorkMesh** world, a **micro-service** is an **external web-service** who receives tasks for any kind of offline processing, and returns the result to **master**. Just that. Nothing more.
  
  - This library is for defininng the micro-service protocol at the **master** side.
  
  - For creating your own micro-service, refer to [micro.template](https://github.com/leandrosardi/micro.template) project.
  
  - If you are looking for a multi-threading processing framework, you should refer to [Pampa](https://github.com/leandrosardi/pampa) instead.
  
Find documentation here: https://github.com/leandrosardi/workmesh
"
  s.authors     = ["Leandro Daniel Sardi"]
  s.email       = 'leandro.sardi@expandedventure.com'
  s.files       = [
    'lib/workmesh.rb',
    'deployment-routines/update-config.rb',
    'deployment-routines/update-source.rb',
  ]
  s.homepage    = 'https://rubygems.org/gems/workmesh'
  s.license     = 'MIT'
  s.add_runtime_dependency 'sequel', '~> 5.56.0', '>= 5.56.0'
  s.add_runtime_dependency 'blackstack-core', '~> 1.2.3', '>= 1.2.3'
  s.add_runtime_dependency 'blackstack-nodes', '~> 1.2.11', '>= 1.2.11'
  s.add_runtime_dependency 'simple_command_line_parser', '~> 1.1.2', '>= 1.1.2'
  s.add_runtime_dependency 'simple_cloud_logging', '~> 1.2.2', '>= 1.2.2'
end