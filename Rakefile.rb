desc 'Import lunch data into Neo4j'
 	task :populate do
 	  require 'neoWrapper.rb'
 	  
 	  neo = Neo.new 
 	  
 	  menu = neo.create_node('Menu')
 	  questions = neo.create_node('Questions')
 	  customers = neo.create_node('Customers')
 	  
 	  neo.relate_node_to_root(menu) 
 	  neo.relate_node_to_root(questions)
 	  neo.relate_node_to_root(customers)
 	  
 	  tuna = neo.create_node('tuna salad')
 	  nut = neo.create_node("nut salad")
    pasta = neo.create_node("pasta salad")
    
    neo.addToMenu(menu, nut)
    neo.addToMenu(menu, tuna)
    neo.addToMenu(menu, pasta)
    
    #Create questions
    allergies = neo.create_question('What allergies do you have?')
    dislikes = neo.create_question('What dont you like?')
    dietery = neo.create_question('What is your specific diet?')
    
    allergiesRelationship = neo.add_question_to_questions(questions, allergies)
    dislikesRelationship = neo.add_question_to_questions(questions, dislikes)
    dieteryRelationship = neo.add_question_to_questions(questions, dietery)
    
    neo.set_relationship_properties(allergiesRelationship, {"mandatory" => "true"})
    neo.set_relationship_properties(allergiesRelationship, {"sequence" => "1"})
    
    neo.set_relationship_properties(dieteryRelationship, {"sequence" => "1"})
    
    
    nutAns = neo.create_node('nut')
    fishAns = neo.create_node('fish')
    wheatAns = neo.create_node('wheat')
    
    vegan = neo.create_node("vegan")
    veggie = neo.create_node("veggie")
    kosher = neo.create_node("kosher")
    
    neo.add_answers_to_question(allergies, nutAns)
    neo.add_answers_to_question(allergies, fishAns)
    neo.add_answers_to_question(allergies, wheatAns)
    
    neo.add_answers_to_question(dietery, vegan)
    neo.add_answers_to_question(dietery, veggie)
    neo.add_answers_to_question(dietery, kosher) 
    
    neo.answer_excludes_menu_item(nutAns, nut)
    neo.answer_excludes_menu_item(fishAns, tuna)
    
    neo.answer_excludes_menu_item(veggie, tuna)
    neo.answer_excludes_menu_item(vegan, tuna)

  end
  
  task :stop do 
    exec '/Users/cnoppani/myOpt/neo4j-community-1.4.M01/bin/neo4j stop' 
  end
  
  task :remove do  
    exec 'rm -r /Users/cnoppani/myOpt/neo4j-community-1.4.M01/data/*'
  end
  
  task :start do
    exec 'nohup /Users/cnoppani/myOpt/neo4j-community-1.4.M01/bin/neo4j start &'
  end 
  
