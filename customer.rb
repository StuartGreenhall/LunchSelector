require 'rubygems'
require 'neography'

class Customer
  
  def neo
    @neo ||= Neography::Rest.new({:server => 'localhost'})
  end
  
  def get_all_customers
    customers = neo.get_index('fredsIndex', 'name', 'Customers')
    neo.traverse(customers, "nodes", {"relationships" => [{"type" => "customer", "direction" => "all"}], "depth" => 1})
  end
end