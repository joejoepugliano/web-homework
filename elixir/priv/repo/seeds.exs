# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
alias Homework.{Companies, Merchants, Transactions, Users}

###
# Companies
#
{:ok, divvy} = Companies.create(%{name: "Divvy", credit_line: 1000})
{:ok, google} = Companies.create(%{name: "Google", credit_line: 100})
{:ok, nike} = Companies.create(%{name: "Nike", credit_line: 500})

##
# Merchants
#
{:ok, marco_polo} = Merchants.create_merchant(%{name: "Marco Polo", description: "The original merchant"})
{:ok, walmart} = Merchants.create_merchant(%{name: "Walmart", description: "Great Value"})
{:ok, amazon} = Merchants.create_merchant(%{name: "Amazon", description: "Online Merchant"})

##
# Users
#
{:ok, ronaldo} = Users.create_user(%{first_name: "Cristiano", last_name: "Ronaldo", dob: "02-05-1985", company_id: nike.id})
{:ok, joe} = Users.create_user(%{first_name: "Joe", last_name: "Pugliano", dob: "06-19-1990", company_id: divvy.id})
{:ok, sundar} = Users.create_user(%{first_name: "Sundar", last_name: "Pichai", dob: "06-10-1972", company_id: google.id})
{:ok, _user} = Users.create_user(%{first_name: "Fake", last_name: "User", dob: "12-25-2000", company_id: divvy.id})

##
# Transactions 
#
{:ok, _transaction} = Transactions.create(%{amount: 10, credit: false, debit: true, description: "shoes", company_id: nike.id, merchant_id: walmart.id, user_id: ronaldo.id})
{:ok, _transaction} = Transactions.create(%{amount: 5, credit: true, debit: false, description: "keyboard", company_id: divvy.id, merchant_id: amazon.id, user_id: joe.id})
{:ok, _transaction} = Transactions.create(%{amount: 3, credit: true, debit: false, description: "mouse", company_id: google.id, merchant_id: walmart.id, user_id: joe.id})
{:ok, _transaction} = Transactions.create(%{amount: 36, credit: false, debit: true, description: "gold", company_id: google.id, merchant_id: marco_polo.id, user_id: sundar.id})
{:ok, _transaction} = Transactions.create(%{amount: 100, credit: true, debit: false, description: "computer", company_id: divvy.id, merchant_id: amazon.id, user_id: sundar.id})
{:ok, _transaction} = Transactions.create(%{amount: 10, credit: true, debit: false, description: "hat", company_id: nike.id, merchant_id: marco_polo.id, user_id: ronaldo.id})
