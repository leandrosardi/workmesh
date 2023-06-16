require_relative '../lib/workmesh.rb'
require_relative '../config.rb'

l = BlackStack::Workmesh.logger

l.logs 'Loading order... '
o = BlackStack::Scraper::Order.where(:node_for_micro_dfyl_appending=>'local', :micro_emails_delivery_push_success=>nil).first
l.logf o.id.green

l.logs 'Loading node... '
n = BlackStack::Workmesh.node(o.node_for_micro_dfyl_appending)
l.logf n.name.green

l.logs "Assigning the order #{o.id}... "
BlackStack::Workmesh.service(:'micro.dfyl.appending').protocol('push_order').push(o, n)
l.done
