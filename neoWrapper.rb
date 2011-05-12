#neoWrapper.rb
require 'rubygems'
require 'neography'
 	
class Neo
  def neo
    @neo ||= Neography::Rest.new({:server => 'localhost'})
  end
  
  def create_customer(name)

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
  
  def get_question(id)
    return neo.get_node(id)
  end
  
  def get_answers_for_question(question)
    neo.traverse(question, "nodes", {"relationships" => [{"type" => "answers", "direction" => "all"}], "depth" => 1})
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
                                                          
end
