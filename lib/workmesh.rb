require 'sequel'
require 'blackstack-core'
require 'blackstack-nodes'
require 'blackstack-deployer'
require 'simple_command_line_parser'
require 'simple_cloud_logging'

module BlackStack
  # stub node class
  # stub node class is already defined in the blackstack-nodes gem: https://github.com/leandrosardi/blackstack-nodes
  # we inherit from it to add some extra methods and attributes
  class Node
    # stub node class is already defined in the blackstack-nodes gem: https://github.com/leandrosardi/blackstack-nodes
    # we inherit from it to add some extra methods and attributes
    include BlackStack::Infrastructure::NodeModule
    # array of workers belonging to this node
    attr_accessor :workmesh_api_key
    # add validations to the node descriptor
    def self.descriptor_errors(h)
      errors = BlackStack::Infrastructure::NodeModule.descriptor_errors(h)
      # validate: the key :max_workers exists and is an integer
      errors << "The key :workmesh_api_key is missing" if h[:max_workers].nil?
      errors << "The key :workmesh_api_key must be an String" unless h[:max_workers].is_a?(String)
      # return list of errors
      errors.uniq
    end
    # initialize the node
    def initialize(h, i_logger=nil)
      errors = BlackStack::Pampa::Node.descriptor_errors(h)
      raise "The node descriptor is not valid: #{errors.uniq.join(".\n")}" if errors.length > 0
      super(h, i_logger)
      self.workmesh_api_key = h[:workmesh_api_key]
    end # def self.create(h)
    # returh a hash descriptor of the node
    def to_hash()
      ret = super()
      ret[:workmesh_api_key] = self.workmesh_api_key
      ret
    end
  end # class Node

  class Protocol
    attr_accessor :entity_table, :entity_field_id, :entity_field_sort, 
    attr_accessor :push_function, :entity_field_push_time, :entity_field_push_success, :entity_field_push_error_description
    attr_accessor :pull_status_access_point
    attr_accessor :pull_function, :enttity_field_pull_time, :entity_field_pull_success, :entity_field_pull_error_description 

    def self.descriptor_errors(h)
      errors = []
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

    def initialze(h)
      errors = BlackStack::Pampa::Protocol.descriptor_errors(h)
      raise "The protocol descriptor is not valid: #{errors.uniq.join(".\n")}" if errors.length > 0
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
        errors << "The key :assignation must be one of the following values: #{ASSIGANTIONS.join(", ")}" unless ASSIGANTIONS.include?(h[:protocol])
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
      self.protocols = h[:protocols]
      self.assignation = h[:assignation]     
    end
    # return a hash descriptor of the worker
    def to_hash()
      {
        :name => self.name,
        :entity_table => self.entity_table,
        :entity_field_assignation => self.entity_field_assignation,
        :protocols => self.protocols,
        :assignation => self.assignation
      }
    end
  end # class Service

  module Workmesh
    # infrastructure configuration
    @@nodes = []
    @@services = []

    # logger configuration
    @@log_filename = nil
    @@logger = BlackStack::DummyLogger.new(nil)

    # Connection string to the database. Example: mysql2://user:password@localhost:3306/database
    @@connection_string = nil

  end # module Workmesh
end # module BlackStack