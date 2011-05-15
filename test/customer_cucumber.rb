Given /I have get all the customers/ do |n|
  db = Neo.new
  db.get_all_customers
end