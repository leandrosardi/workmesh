require_relative '../lib/workmesh.rb'
require_relative '../config.rb'

l = BlackStack::Workmesh.logger

l.logs 'Loading an order... '
o = BlackStack::Scraper::Order.where(:leadhype_requested=>true, :node_for_micro_dfyl_appending=>nil).first
l.logf o.id.green 

l.logs 'Assigning the order to a node... '
n = BlackStack::Workmesh.assign(o, :'micro.dfyl.appending')
l.logf n.name.green