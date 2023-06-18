require 'colorize'
require 'sequel'
require 'blackstack-core'
require 'blackstack-nodes'
require 'blackstack-deployer'
require 'simple_command_line_parser'
require 'simple_cloud_logging'

require_relative '../deployment-routines/update-config'
require_relative '../deployment-routines/update-source'

=begin
# TODO: Move this to a gem with the CRDB module
#
# return a postgresql uuid
#
def guid()
  DB['SELECT gen_random_uuid() AS id'].first[:id]
end
=end

# TODO: Move new() to a gem with the CRDB module
#
# return current datetime with format `%Y-%m-%d %H:%M:%S %Z`, using the timezone of the database (`select current_setting('TIMEZONE')`)
# TODO: I am hardcoding the value of `tz` because for any reason `SELECT current_setting('TIMEZONE')` returns `UTC` instead of 
# `America/Argentina/Buenos_Aires` when I run it from Ruby. Be sure your database is ALWAYS configured with the correct timezone.
#
def now()
  tz = 'America/Argentina/Buenos_Aires' #DB["SELECT current_setting('TIMEZONE') AS tz"].first[:tz]
  DB["SELECT current_timestamp() at TIME ZONE '#{tz}' AS now"].first[:now]
end

module BlackStack
  module Workmesh
    # stub node class
    # stub node class is already defined in the blackstack-nodes gem: https://github.com/leandrosardi/blackstack-nodes
    # we inherit from it to add some extra methods and attributes
    class Node
      # stub node class is already defined in the blackstack-nodes gem: https://github.com/leandrosardi/blackstack-nodes
      # we inherit from it to add some extra methods and attributes
      include BlackStack::Infrastructure::NodeModule
      # array of workers belonging to this node
      attr_accessor :workmesh_api_key
      attr_accessor :workmesh_port
      attr_accessor :workmesh_service
      # add validations to the node descriptor
      def self.descriptor_errors(h)
        errors = BlackStack::Infrastructure::NodeModule.descriptor_errors(h)
        # validate: the key :max_workers exists and is an integer
        errors << "The key :workmesh_api_key is missing" if h[:workmesh_api_key].nil?
        errors << "The key :workmesh_api_key must be an String" unless h[:workmesh_api_key].is_a?(String)
        # validate: the key :workmesh_port exists and is an integer
        errors << "The key :workmesh_port is missing" if h[:workmesh_port].nil?
        errors << "The key :workmesh_port must be an Integer" unless h[:workmesh_port].is_a?(Integer)
        # validate: the key :workmesh_service exists and is an symbol, and its string matches with the name of one of the services in the @@services array
        errors << "The key :workmesh_service is missing" if h[:workmesh_service].nil?
        errors << "The key :workmesh_service must be an Symbol" unless h[:workmesh_service].is_a?(Symbol)
        errors << "The key :workmesh_service must be one of the following: #{BlackStack::Workmesh.services.map { |s| s.name }}" unless BlackStack::Workmesh.services.map { |s| s.name }.include?(h[:workmesh_service].to_s)
        # return list of errors
        errors.uniq
      end
      # initialize the node
      def initialize(h, i_logger=nil)
        errors = BlackStack::Workmesh::Node.descriptor_errors(h)
        raise "The node descriptor is not valid: #{errors.uniq.join(".\n")}" if errors.length > 0
        super(h, i_logger)
        self.workmesh_api_key = h[:workmesh_api_key]
        self.workmesh_port = h[:workmesh_port]
        self.workmesh_service = h[:workmesh_service]
      end # def self.create(h)
      # returh a hash descriptor of the node
      def to_hash()
        ret = super()
        ret[:workmesh_api_key] = self.workmesh_api_key
        ret[:workmesh_port] = self.workmesh_port
        ret[:workmesh_service] = self.workmesh_service
        ret
      end
      # run deployment routines
      def deploy(l=nil)
        l = BlackStack::DummyLogger.new(nil) if l.nil?

        l.logs 'Updating config.rb... '
          BlackStack::Deployer::run_routine(self.name, 'workmesh-update-config')
        l.done

        l.logs 'Updating source... '
          BlackStack::Deployer::run_routine(self.name, 'workmesh-update-source')
        l.done
      end
    end # class Node

    class Protocol
      attr_accessor :name
      attr_accessor :entity_table, :entity_field_id, :entity_field_sort
      attr_accessor :push_function, :entity_field_push_time, :entity_field_push_success, :entity_field_push_error_description
      attr_accessor :pull_status_access_point
      attr_accessor :pull_function, :enttity_field_pull_time, :entity_field_pull_success, :entity_field_pull_error_description 

      def self.descriptor_errors(h)
        errors = []
        # validate: the key :name exists and is a string
        errors << "The key :name is missing" if h[:name].nil?
        errors << "The key :name must be an String" unless h[:name].is_a?(String)
        # validate: the key :entity_table exists and is an symbol
        errors << "The key :entity_table is missing" if h[:entity_table].nil?
        errors << "The key :entity_table must be an Symbol" unless h[:entity_table].is_a?(Symbol)
        # validate: the key :entity_field_id exists and is an symbol
        errors << "The key :entity_field_id is missing" if h[:entity_field_id].nil?
        errors << "The key :entity_field_id must be an Symbol" unless h[:entity_field_id].is_a?(Symbol)
        # validate: the key :entity_field_sort exists and is an symbol
        errors << "The key :entity_field_sort is missing" if h[:entity_field_sort].nil?
        errors << "The key :entity_field_sort must be an Symbol" unless h[:entity_field_sort].is_a?(Symbol)
        
        # validate: the key :push_function is null or it is a procedure
        #errors << "The key :push_function must be an Symbol" unless h[:push_function].nil? || h[:push_function].is_a?()
        # validate: if :push_function exists, the key :entity_field_push_time exists and it is a symbol
        errors << "The key :entity_field_push_time is missing" if h[:push_function] && h[:entity_field_push_time].nil?
        # validate: if :push_function exists, the key :entity_field_push_success exists and it is a symbol
        errors << "The key :entity_field_push_success is missing" if h[:push_function] && h[:entity_field_push_success].nil?
        # validate: if :push_function exists, the key :entity_field_push_error_description exists and it is a symbol
        errors << "The key :entity_field_push_error_description is missing" if h[:push_function] && h[:entity_field_push_error_description].nil?

        # valiudate: if :pull_function exists, the key :pull_status_access_point exists and it is a string
        errors << "The key :pull_status_access_point is missing" if h[:pull_function] && h[:pull_status_access_point].nil?
        errors << "The key :pull_status_access_point must be an String" unless h[:pull_function].nil? || h[:pull_status_access_point].is_a?(String)
        # validate: if :pull_function exists, the key :entity_field_pull_time exists and it is a symbol
        errors << "The key :entity_field_pull_time is missing" if h[:pull_function] && h[:entity_field_pull_time].nil?
        # validate: if :pull_function exists, the key :entity_field_pull_success exists and it is a symbol
        errors << "The key :entity_field_pull_success is missing" if h[:pull_function] && h[:entity_field_pull_success].nil?
        # validate: if :pull_function exists, the key :entity_field_pull_error_description exists and it is a symbol
        errors << "The key :entity_field_pull_error_description is missing" if h[:pull_function] && h[:entity_field_pull_error_description].nil?

        # return list of errors
        errors.uniq
      end

      def initialize(h)
        errors = BlackStack::Workmesh::Protocol.descriptor_errors(h)
        raise "The protocol descriptor is not valid: #{errors.uniq.join(".\n")}" if errors.length > 0
        self.name = h[:name]
        self.entity_table = h[:entity_table]
        self.entity_field_id = h[:entity_field_id]
        self.entity_field_sort = h[:entity_field_sort]
        self.push_function = h[:push_function]
        self.entity_field_push_time = h[:entity_field_push_time]
        self.entity_field_push_success = h[:entity_field_push_success]
        self.entity_field_push_error_description = h[:entity_field_push_error_description]
        self.pull_function = h[:pull_function]
        self.enttity_field_pull_time = h[:entity_field_pull_time]
        self.entity_field_pull_success = h[:entity_field_pull_success]
        self.entity_field_pull_error_description = h[:entity_field_pull_error_description]
      end

      def to_hash()
        ret = super()
        ret[:name] = self.name
        ret[:entity_table] = self.entity_table
        ret[:entity_field_id] = self.entity_field_id
        ret[:entity_field_sort] = self.entity_field_sort
        ret[:push_function] = self.push_function
        ret[:entity_field_push_time] = self.entity_field_push_time
        ret[:entity_field_push_success] = self.entity_field_push_success
        ret[:entity_field_push_error_description] = self.entity_field_push_error_description
        ret[:pull_function] = self.pull_function
        ret[:enttity_field_pull_time] = self.enttity_field_pull_time
        ret[:entity_field_pull_success] = self.entity_field_pull_success
        ret[:entity_field_pull_error_description] = self.entity_field_pull_error_description
        ret
      end

      # execute the push function of this protocol, and update the push flags
      def push(entity, node)
        raise 'The push function is not defined' if self.push_function.nil?
        entity[entity_field_push_time] = now()
        begin
          self.push_function.call(entity, node)
          entity[entity_field_push_success] = true
          entity[entity_field_push_error_description] = nil
          entity.save
        rescue => e
          entity[entity_field_push_success] = false
          entity[entity_field_push_error_description] = e.message
          entity.save
          raise e
        end
      end
    end # class Protocol

    # stub worker class
    class Service
      ASSIGANTIONS = [:entityweight, :roundrobin, :entitynumber]
      # name to identify uniquely the worker
      attr_accessor :name, :entity_table, :entity_field_assignation, :protocols, :assignation
      # return an array with the errors found in the description of the job
      def self.descriptor_errors(h)
        errors = []
        # validate: the key :name exists and is an string
        errors << "The key :name is missing" if h[:name].nil?
        errors << "The key :name must be an String" unless h[:name].is_a?(String)
        # validate: the key :entity_table exists and is an symbol
        errors << "The key :entity_table is missing" if h[:entity_table].nil?
        errors << "The key :entity_table must be an Symbol" unless h[:entity_table].is_a?(Symbol)
        # validate: the key :entity_field_assignation exists and is an symbol
        errors << "The key :entity_field_assignation is missing" if h[:entity_field_assignation].nil?
        errors << "The key :entity_field_assignation must be an Symbol" unless h[:entity_field_assignation].is_a?(Symbol)
        # validate: the key :protocols exists is nil or it is an array of valid hash descritors of the Protocol class.
        errors << "The key :protocols must be an Array" unless h[:protocols].nil? || h[:protocols].is_a?(Array)
        if h[:protocols].is_a?(Array)
          h[:protocols].each do |protocol|
            errors << "The key :protocols must be an Array of valid hash descritors of the Protocol class" unless protocol.is_a?(Hash)
            errors << "The key :protocols must be an Array of valid hash descritors of the Protocol class" unless Protocol.descriptor_errors(protocol).length == 0
          end
        end
        # validate: the key :assignation is nil or it is a symbol belonging the array ASSIGANTIONS
        errors << "The key :assignation must be an Symbol" unless h[:assignation].nil? || h[:assignation].is_a?(Symbol)
        unless h[:assignation].nil?
          errors << "The key :assignation must be one of the following values: #{ASSIGANTIONS.join(", ")}" unless ASSIGANTIONS.include?(h[:assignation])
        end
        # return list of errors
        errors.uniq
      end
      # setup dispatcher configuration here
      def initialize(h)
        errors = BlackStack::Workmesh::Service.descriptor_errors(h)
        raise "The worker descriptor is not valid: #{errors.uniq.join(".\n")}" if errors.length > 0
        self.name = h[:name]
        self.entity_table = h[:entity_table]
        self.entity_field_assignation = h[:entity_field_assignation]
        self.protocols = []
        if h[:protocols]
          h[:protocols].each do |i|
            self.protocols << BlackStack::Workmesh::Protocol.new(i)
          end
        end 
        self.assignation = h[:assignation]     
      end
      # return a hash descriptor of the worker
      def to_hash()
        {
          :name => self.name,
          :entity_table => self.entity_table,
          :entity_field_assignation => self.entity_field_assignation,
          :protocols => self.protocols.map { |p| p.to_hash },
          :assignation => self.assignation
        }
      end
      # get a protocol from its name
      def protocol(name)
        self.protocols.select { |p| p.name.to_s == name.to_s }.first
      end
    end # class Service

    # hash with the round-robin positions per service.
    @@roundrobin = {}

    # infrastructure configuration
    @@nodes = []
    @@services = []

    # logger configuration
    @@log_filename = nil
    @@logger = BlackStack::DummyLogger.new(nil)

    # Connection string to the database. Example: mysql2://user:password@localhost:3306/database
    @@connection_string = nil

    # define a filename for the log file.
    def self.set_log_filename(s)
      @@log_filename = s
      @@logger = BlackStack::LocalLogger.new(s)
    end

    # return the logger.
    def self.logger()
      @@logger
    end

    def self.set_logger(l)
      @@logger = l
    end

    # return the log filename.
    def self.log_filename()
      @@log_filename
    end

    # define the connectionstring to the database.
    def self.set_connection_string(s)
      @@connection_string = s
    end

    # return connection string to the database. Example: mysql2://user:password@localhost:3306/database
    def self.connection_string()
      @@connection_string
    end

    # add_node
    # add a node to the infrastructure
    def self.add_node(h)
      @@nodes << BlackStack::Workmesh::Node.new(h)
      # add to deployer
      BlackStack::Deployer.add_node(h) #if @@integrate_with_blackstack_deployer
    end

    def self.nodes
      @@nodes
    end

    def self.node(name)
      @@nodes.select { |n| n.name.to_s == name.to_s }.first
    end

    # add_service
    # add a service to the infrastructure
    def self.add_service(h)
      @@services << BlackStack::Workmesh::Service.new(h)
    end

    def self.services
      @@services
    end

    def self.service(name)
      @@services.select { |s| s.name.to_s == name.to_s }.first
    end

    # assign object to a node using a round-robin algorithm
    # this method is used when the service assignation is :roundrobin
    # this method is for internal use only, and it should not be called directly.
    def self.roundrobin(o, service_name)
      @@roundrobin[service_name] = 0 if @@roundrobin[service_name].nil?
      # getting the service
      s = @@services.select { |s| s.name.to_s == service_name.to_s }.first
      # getting all the nodes assigned to the service
      nodes = @@nodes.select { |n| n.workmesh_service.to_s == service_name.to_s }.sort_by { |n| n.name.to_s }
      # increase i
      @@roundrobin[service_name] += 1
      @@roundrobin[service_name] = 0 if @@roundrobin[service_name] >= nodes.length
      # assign the object to the node
      n = nodes[@@roundrobin[service_name]]
      o[s.entity_field_assignation] = n.name
      o.save
      # return
      n
    end

    # return the assigned node to an object, for a specific service.
    # if the object has not a node assigned, then return nil.
    def self.assigned_node(o, service_name)
      # getting the service
      s = @@services.select { |s| s.name.to_s == service_name.to_s }.first
      # validate: the service exists
      raise "The service #{service_name} does not exists" if s.nil?
      # validate: the object o is an instance of the Sequel Class mapping the table :entity_table
      raise "The object o is not an instance of :entity_table (#{s.entity_table.to_s})" unless o.is_a?(Sequel::Model) && o.class.table_name.to_s == s.entity_table.to_s
      # if the object has not a node assigned, then return nil.
      return nil if o[s.entity_field_assignation].nil?
      # return the node
      @@nodes.select { |n| n.name.to_s == o[s.entity_field_assignation].to_s }.first
    end

    # assign object to a node
    def self.assign(o, service_name, h = {})
      # getting the service
      s = @@services.select { |s| s.name.to_s == service_name.to_s }.first
      # validate: the service exists
      raise "The service #{service_name} does not exists" if s.nil?
      # validate: the object o is an instance of the Sequel Class mapping the table :entity_table
      raise "The object o is not an instance of :entity_table (#{s.entity_table.to_s})" unless o.is_a?(Sequel::Model) && o.class.table_name.to_s == s.entity_table.to_s
      # reassign
      if h[:reassign] == true
        o[s.entity_field_assignation] = nil
        o.save
      end
      # validate: the object o has not been assigned yet
      raise "The object o has been already assigned to a node. Use the :reassign parameter for reassignation." unless o[s.entity_field_assignation].nil?
      # decide the assignation method
      if s.assignation == :entityweight
        raise 'The assignation method :entityweight is not implemented yet.'
      elsif s.assignation == :roundrobin
        return BlackStack::Workmesh.roundrobin(o, service_name)
      elsif s.assignation == :entitynumber
        raise 'The assignation method :entitynumber is not implemented yet.'
      else
        raise "The assignation method #{s.assignation} is unknown."
      end
    end

  end # module Workmesh
end # module BlackStack