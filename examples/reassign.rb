require_relative '../lib/workmesh.rb'
require_relative '../config.rb'

l = BlackStack::Workmesh.logger

l.logs 'Loading order... '
a = BlackStack::Scraper::Order.where(:leadhype_requested=>true, :node_for_micro_dfyl_appending=>['local1', 'local2', 'local3']).limit(10).all
l.logf a.size.to_s.green 

a.each { |o|
    l.logs "Assigning the order #{o.id}... "
    n = BlackStack::Workmesh.assign(o, :'micro.dfyl.appending', {:reassign=>true})
    l.logf n.name.green
}
