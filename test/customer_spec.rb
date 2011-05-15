require '../customer.rb'

describe Customer do
  it "should return customers" do
    customer = Customer.new
    customers = customer.get_all_customers
    customers.size.should == 2
  end
end
