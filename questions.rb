require 'rubygems'
require 'neography'
require 'neoWrapper.rb'

class Question
  def get_completed_questions(customer_name)
    customer = neo.get_index('customersIndex', 'name', customer_name)
    completed_questions = neo.traverse(menu, "nodes", {"relationships" => [{"type"=> "completed", "direction" => "all"}], "depth" => 1}) 
  end
end
