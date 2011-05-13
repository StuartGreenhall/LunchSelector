# lunchSelector.rb
require 'rubygems'
require 'sinatra'
require 'neoWrapper.rb'

get '/' do
  haml :index 
end

get '/customers' do
  
  db = Neo.new
  @all_customers = db.get_all_customers
  @all_customers_text = db.prepares_data(@all_customers)
  
  haml :customers
end

#Start the application
get '/selectionprocess' do
  
  haml :selectionprocess
end

post '/selectionprocess' do
  @name = params[:name]
  
  db = Neo.new
  db.create_customer(@name)
  
  redirect "/selectionprocess/#{@name}"
end

get '/selectionprocess/:customername/completedquestions' do
  @name = params[:customername]
  
  db = Neo.new
  
  @completed_questions = db.get_completed_questions(@name)
  @completed_questions_text = db.prepares_data(@completed_questions)
  
  haml :completedquestions
end

get '/selectionprocess/:customername/uncompletedquestions' do
  @name = params[:customername]
  
  db = Neo.new
  
  @uncompleted_questions = db.get_uncompleted_questions(@name)
  @uncompleted_questions_text = db.prepares_data(@uncompleted_questions)
  
  haml :uncompletedquestions
end

get '/selectionprocess/:customername' do
  @name = params[:customername]
  
  db = Neo.new
  @first_question = db.get_first_question
  @answers_for_first_question = db.get_answers_for_question(@first_question)
  
  @first_question_id  = @first_question.values_at('self')[0].split('/').last
  @first_question_text = @first_question.values_at('data')[0].values_at('name')
  
  @answers_for_first_question = db.prepares_data(@answers_for_first_question)
  
  haml :customerpage
end

post '/selectionprocess/:customername' do
  @customer_name = params[:customername]
  @answers = params[:answer]
  @completed_question_id = params[:completed_question_id]
  
  db = Neo.new
  
  @answers.each do |answered_node_id|
    db.add_answer_to_customer(@customer_name, answered_node_id)
  end
  
  db.add_customer_completed_question(@customer_name,@completed_question_id)
  
  redirect "/selectionprocess/#{@customer_name}/menu"
end

get '/selectionprocess/:customername/menu' do
  @customer_name = params[:customername]
  
  db = Neo.new
  
  @personalised_menu_text = db.get_excluded_dishes_for_customer(@customer_name)

  haml :customermenu
end

get '/questionwithanswers' do
  db = Neo.new
  
  @first_question = db.get_first_question
  @answers_for_first_question = db.get_answers_for_question(@first_question)
  
  @first_question_text = @first_question.values_at('data')[0].values_at('name')
  @answers_for_first_question = db.prepares_data(@answers_for_first_question)
  
  haml :questionwithanswers
end





get '/questions' do
  db = Neo.new
  @questions = db.get_questions
  @questionsText = db.prepares_data(@questions)

  haml :questions

end

get '/questions/mandatory' do
  db = Neo.new
  @mandatoryQuestions = db.get_mandatory_questions
  @mandatoryQuestionsText = db.prepares_data(@mandatoryQuestions);
  
  haml :mandatoryQuestions
end

get '/questions/first' do
  db = Neo.new
  @firstQuestions = db.get_first_questions
  @firstQuestionsText = db.prepares_data(@firstQuestions);
  
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
  @excludedDishesText = db.prepares_data(@excludedDishes)
  
  haml :excludedDishes
end

get '/menu/excludeddishes/:answer' do
  db = Neo.new
  @excludedDishesBasedOnAnswer = db.get_excluded_dishes_based_on_answer(params[:answer])
  @excludedDishesBasedOnAnswerText = db.prepares_data(@excludedDishesBasedOnAnswer)
  
  haml :excludedDishesBasedOnAnswer
end

get '/menu/excludeddishes/separatewithamp/:answer' do
  db = Neo.new
  
  answerA = params[:answer].split("&")[0]
  answerB = params[:answer].split("&")[1]
   
  @excludedDishesBasedOnTwoAnswers = db.get_excluded_dishes_based_on_two_answers(answerA, answerB)
  
  @excludedDishesBasedOnTwoAnswersText = db.prepares_data(@excludedDishesBasedOnTwoAnswers)
  haml :excludedDishesBasedOnTwoAnswers
end





