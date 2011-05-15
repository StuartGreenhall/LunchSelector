Feature: Get customers
	In order to avoid missing customers
	As a developer
	I want to know that the number of customers is one
	
	Scenario: Get all the customers
		Given I have get all the customers
		When I load the customers page
		Then the result should be only one customer