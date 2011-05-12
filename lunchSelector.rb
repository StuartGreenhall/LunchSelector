# lunchSelector.rb
require 'rubygems'
require 'sinatra'
require 'neoWrapper.rb'

get '/' do
  haml :index 
end

#Start the application
get '/selectionprocess' do
  
  haml :selectionprocess
end

post '/selectionprocess' do
  @name = params[:name]
  
  db = Neo.new
  db.create_customer("John")
  "Successful"
end

get '/questions' do
  db = Neo.new
  @questions = db.get_questions
  @questionsText = prepares_data(@questions);

  haml :questions

end

get '/questions/mandatory' do
  db = Neo.new
  @mandatoryQuestions = db.get_mandatory_questions
  @mandatoryQuestionsText = prepares_data(@mandatoryQuestions);
  
  haml :mandatoryQuestions
end

get '/questions/first' do
  db = Neo.new
  @firstQuestions = db.get_first_questions
  @firstQuestionsText = prepares_data(@firstQuestions);
  
  haml :firstQuestions
end

get '/questions/:question' do
  db = Neo.new
  @question = db.get_question(params[:question])
  @answers = db.get_answers_for_question(params[:question])
  
  @question = @question.values_at('data')[0].values_at('name')
  
  @answersText = Array.new
  @answers.each do | answer |
    @answersText << answer.values_at('data')[0].values_at('name')
  end
  haml :question
end

get '/menu' do
  db = Neo.new  
  @items = db.find_menu_items
  @results = Array.new
  @items.each do | item |
    @results << db.get_node_properties(item, ["name"])["name"]
  end 
  haml :menu
end

get '/menu/excludeddishes' do
  db = Neo.new
  @excludedDishes = db.get_excluded_dishes
  @excludedDishesText = prepares_data(@excludedDishes)
  
  haml :excludedDishes
end

get '/menu/excludeddishes/:answer' do
  db = Neo.new
  @excludedDishesBasedOnAnswer = db.get_excluded_dishes_based_on_answer(params[:answer])
  @excludedDishesBasedOnAnswerText = prepares_data(@excludedDishesBasedOnAnswer)
  
  haml :excludedDishesBasedOnAnswer
end

get '/menu/excludeddishes/separatewithamp/:answer' do
  db = Neo.new
  
  answerA = params[:answer].split("&")[0]
  answerB = params[:answer].split("&")[1]
   
  @excludedDishesBasedOnTwoAnswers = db.get_excluded_dishes_based_on_two_answers(answerA, answerB)
  
  @excludedDishesBasedOnTwoAnswersText = prepares_data(@excludedDishesBasedOnTwoAnswers)
  haml :excludedDishesBasedOnTwoAnswers
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




