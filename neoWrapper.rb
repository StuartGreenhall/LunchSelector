#neoWrapper.rb
require 'rubygems'
require 'neography'
 	
class Neo

  def neo
    @neo ||= Neography::Rest.new({:server => 'localhost'})
  end
  
  def create_customer(name)
    customer = neo.create_node('name' => name)
    neo.add_to_index('customersIndex', 'name', name, customer)
    
    customers = neo.get_index('fredsIndex', 'name', 'Customers')
    add_customer_to_customers(customers, customer)
  end
  
  def add_answer_to_customer(customer_name, answered_node_id)
    customer = neo.get_index('customersIndex', 'name', customer_name)
    answer = neo.get_node(answered_node_id)
    neo.create_relationship('answered', customer, answer)
  end
  
  def add_customer_completed_question(customer_name, completed_question_id)
    completed_question = neo.get_node(completed_question_id)
    customer = neo.get_index('customersIndex', 'name', customer_name)
    neo.create_relationship('completed', customer, completed_question)
  end
    
  def add_customer_to_customers(customers, customer)
    relationship = neo.create_relationship('customer', customers, customer)
  end
  
  def create_node(name)
    node = neo.create_node('name' => name)
    neo.add_to_index('fredsIndex', 'name', name, node)
  end
  
  def addToMenu(menu, item)
    neo.create_relationship("dish", menu, item)
  end
  
  def find_menu_items()
    #neo.get_node_relationships(menu, 'all', 'MenuItem')
    menu = neo.get_index('fredsIndex', 'name', 'Menu')
    nodes = neo.traverse(menu, "nodes", {"relationships" => [{"type"=> "dish", "direction" => "all"}], "depth" => 1})      
    return nodes
  end
  
  def get_node_properties(node, args)
    neo.get_node_properties(node, args)
  end
  
  def add_answers_to_question(question, answer)
    neo.create_relationship("answers", question, answer)
  end
  
  def create_question(name)
    question = neo.create_node('name' => name, 'type' => 'question')
    neo.add_to_index('questions', 'name', name, question)
  end
  
  def get_questions()
    questionRoot = neo.get_index('fredsIndex', 'name', 'Questions')
    questions = neo.traverse(questionRoot, "nodes", {"relationships" => [{"type"=> "question", "direction" => "all"}], "depth" => 1})
    return questions
  end
  
  def get_mandatory_questions()
    questionRoot = neo.get_index('fredsIndex', 'name', 'Questions')
    mandatoryQuestions = neo.traverse(questionRoot, "nodes", {"relationships" => [{"type"=> "question" , "direction" => "all"}], "return filter"=> {"language" => "javascript", 
      "body" => "position.length() > 0 && position.lastRelationship().hasProperty('mandatory')"}, "depth" => 1})
    return mandatoryQuestions
  end
  
  def get_first_questions()
    questionRoot = neo.get_index('fredsIndex', 'name', 'Questions')
    firstQuestions = neo.traverse(questionRoot, "nodes", {"relationships" => [{"type"=> "question" , "direction" => "all"}], "return filter"=> {"language" => "javascript", 
      "body" => "position.length() > 0 && 
          position.lastRelationship().hasProperty('sequence') && 
          position.lastRelationship().getProperty('sequence') == 1"}, "depth" => 1})
    return firstQuestions
  end
  
  def get_completed_questions(customer_name)
    customer = neo.get_index('customersIndex', 'name', customer_name)
    completed_questions = @neo.traverse(customer, "nodes", {"relationships" => [{"type"=> "completed", "direction" => "all"}], "depth" => 1}) 
  end
  
  def get_uncompleted_questions(customer_name)

  end
  
  def get_question(id)
    return neo.get_node(id)
  end
  
  def get_answers_for_question(question)
    neo.traverse(question, "nodes", {"relationships" => [{"type" => "answers", "direction" => "all"}], "depth" => 1})
  end
  
  def relate_node_to_root(node)
    root = neo.get_root()
    neo.create_relationship("contains", root, node)
  end
  
  def add_question_to_questions(questions, question)
    return relationship = neo.create_relationship('question', questions, question)
  end
  
  def set_relationship_properties(relationship, args)
    neo.set_relationship_properties(relationship, args)
  end
    
  def answer_excludes_menu_item(answer, menuItem)
    neo.create_relationship("excludes", answer, menuItem)
  end
  
  def get_all_customers
    customers = neo.get_index('fredsIndex', 'name', 'Customers')
    neo.traverse(customers, "nodes", {"relationships" => [{"type" => "customer", "direction" => "all"}], "depth" => 1})
  end
  
  def get_excluded_dishes()
    menu = neo.get_index('fredsIndex', 'name', 'Menu')
    dishes = neo.traverse(menu, "nodes", {"relationships" => [{"type" => "dish" , "direction" => "all"}], "return filter"=> {"language"=> "javascript", 
      "body"=> "
        (function shouldReturn(pos) 
        {
          var node = pos.endNode();
          var rels = node.getRelationships();
          var relIterator = rels.iterator();
          var rel = null;
          while(relIterator.hasNext()) 
          {
            rel = relIterator.next();
            if(rel.getType() == 'excludes')
            {
              return true;
            }
          }
          return false;
        })(position);"}})
    return dishes
  end
  
  def get_excluded_dishes_based_on_answer(answer)
    menu = neo.get_index('fredsIndex', 'name', 'Menu')
    dishes = neo.traverse(menu, "nodes", {"relationships" => [{"type" => "dish" , "direction" => "all"}], "return filter"=> {"language"=> "javascript", 
      "body"=> "
        (function shouldReturn(pos) 
        {
          var node = pos.endNode();
          var rels = node.getRelationships();
          var relIterator = rels.iterator();
          var rel = null;
          while(relIterator.hasNext()) 
          {
            rel = relIterator.next();
            if(rel.getType() == 'excludes' &&  rel.getStartNode().getProperty('name') == '#{answer}')
            {
              return true;
            }
          }
          return false;
        })(position);"}})
    return dishes
  end
  
  def get_excluded_dishes_based_on_two_answers(answerA, answerB)
    menu = neo.get_index('fredsIndex', 'name', 'Menu')
    dishes = neo.traverse(menu, "nodes", {"relationships" => [{"type" => "dish" , "direction" => "all"}], "return filter"=> {"language"=> "javascript", 
      "body"=> "
        (function shouldReturn(pos) 
        {
          var node = pos.endNode();
          var rels = node.getRelationships();
          var relIterator = rels.iterator();
          var rel = null; 
          var answerA = false; 
          var answerB = false; 
          while(relIterator.hasNext()) 
          {
            rel = relIterator.next();  
            if(rel.getType() == 'excludes' &&  rel.getStartNode().getProperty('name') == '#{answerA}') 
            { 
              answerA = true 
            } 
            if(rel.getType() == 'excludes' && rel.getStartNode().getProperty('name') == '#{answerB}') 
            {
              answerB = true; 
            } 
            if(answerA && answerB) 
              return true;
          }
          return false;
        })(position);"}})
    return dishes
  end
  
  def get_all_dishes
    menu = neo.get_index('fredsIndex', 'name', 'Menu')
    #customer = neo.get_index('customersIndex', 'name', "Mary")
    #puts neo.get_path(menu, customer, [{"type"=> "answered", "direction" => "all"}], depth=10, algorithm="shortestPath")
    nodes = neo.traverse(menu, "nodes", {"relationships" => [{"type"=> "dish", "direction" => "all"}]})   
  end
  
  def get_excluded_dishes_for_customer(customer_name)
    customer = neo.get_index('customersIndex', 'name', customer_name)
    answered_dishes = neo.traverse(customer, "nodes", {"relationships" => [{"type"=> "answered", "direction" => "all"}], "depth" => 1})
    
    @array_of_answered_dishes = prepares_data(answered_dishes)
    
    @array_of_excluded_dishes = Array.new
    
    @array_of_answered_dishes.each do |answered_dish|
      a_dish = neo.get_index('fredsIndex', 'name', answered_dish[:text])
      excluded_dishes = neo.traverse(a_dish, "nodes", {"relationships" => [{"type"=> "excludes", "direction" => "all"}], "depth" => 1})

      prepared_excluded_dishes = prepares_data(excluded_dishes)
      prepared_excluded_dishes.each do |text|
        @array_of_excluded_dishes << text[:text]
      end
    end
    
    #Onle unique dishes
    @array_of_excluded_dishes = @array_of_excluded_dishes.uniq
    
    @all_dishes = prepares_data(get_all_dishes)
    @only_dish_names = Array.new
    
    @all_dishes.each do |text|
      @only_dish_names << text[:text]
    end
    
    @array_of_excluded_dishes = @only_dish_names - @array_of_excluded_dishes
    
    return @array_of_excluded_dishes
  end
  
  def get_first_question()
    first_questions = get_first_questions()
    first_question = first_questions[0]
    return first_question
  end
  
  def prepares_data(hash_nodes)
    @array_of_node = Array.new
    hash_nodes.each do | node |
      nodeId = node.values_at('self')[0].split('/').last
      text = node.values_at('data')[0].values_at('name')
      @array_of_node << { :nodeId => nodeId, :text => text } 
    end

    return @array_of_node
  end
                                                          
end
