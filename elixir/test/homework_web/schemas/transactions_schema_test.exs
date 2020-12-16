defmodule HomeworkWeb.TransactionsSchemaTest do
  use Homework.DataCase
  use HomeworkWeb.ConnCase

  alias Homework.{Companies, Merchants, Transactions, Users}

  describe "transactions" do
    setup do
      {:ok, company} = Companies.create(%{name: "Company", credit_line: 500})

      {:ok, merchant1} =
        Merchants.create_merchant(%{description: "some description", name: "some name"})

      {:ok, merchant2} =
        Merchants.create_merchant(%{
          description: "some updated description",
          name: "some updated name"
        })

      {:ok, user1} =
        Users.create_user(%{
          dob: "some dob",
          first_name: "some first_name",
          last_name: "some last_name",
          company_id: company.id
        })

      {:ok, user2} =
        Users.create_user(%{
          dob: "some updated dob",
          first_name: "some updated first_name",
          last_name: "some updated last_name",
          company_id: company.id
        })

      valid_attrs = %{
        amount: 42,
        credit: true,
        debit: false,
        description: "some description",
        merchantId: merchant1.id,
        userId: user1.id,
        companyId: company.id
      }

      valid_snake_attrs = %{
        amount: 42,
        credit: true,
        debit: false,
        description: "some description",
        merchant_id: merchant1.id,
        user_id: user1.id,
        company_id: company.id
      }

      invalid_attrs = %{
        amount: nil,
        credit: nil,
        debit: nil,
        description: nil,
        merchant_id: nil,
        user_id: nil,
        company_id: nil
      }

      create_mutation = """
      mutation createTransaction($userId: ID!, $merchantId: ID!, $amount: Int!, $credit: Boolean!, $debit: Boolean!, $description: String!, $companyId: ID!){
          createTransaction(userId: $userId, merchantId: $merchantId, amount: $amount, credit: $credit, debit: $debit, description: $description, companyId: $companyId){
            amount
            companyId
            userId
            merchantId
            credit
            debit
            id
          }
        }
      """

      delete_mutation = """
      mutation deleteTransaction($companyId: ID!, $id: ID!){
        deleteTransaction(companyId: $companyId, id: $id){
          amount
          companyId
          userId
          merchantId
          credit
          debit 
        }
      }
      """

      {:ok,
       %{
         valid_attrs: valid_attrs,
         valid_snake_attrs: valid_snake_attrs,
         invalid_attrs: invalid_attrs,
         merchant1: merchant1,
         merchant2: merchant2,
         user1: user1,
         user2: user2,
         company: company,
         create_mutation: create_mutation,
         delete_mutation: delete_mutation
       }}
    end

    test "create with valid data creates transaction and updates company available_credit", %{
      company: company,
      create_mutation: create_mutation,
      valid_attrs: valid_attrs
    } do
      params = %{query: create_mutation, variables: valid_attrs}

      conn =
        build_conn()
        |> put_req_header("content-type", "application/json")
        |> post("/graphiql", params)

      %{"data" => %{"createTransaction" => result}} = conn.resp_body |> Jason.decode!()

      assert result["amount"] == valid_attrs.amount
      updated_company = Companies.get!(company.id)
      assert updated_company.available_credit < company.available_credit
      assert Transactions.get_transaction!(result["id"]) != nil
    end

    test "create with invalid data does not create transaction", %{
      create_mutation: create_mutation,
      invalid_attrs: invalid_attrs
    } do
      params = %{query: create_mutation, variables: invalid_attrs}

      build_conn()
      |> put_req_header("content-type", "application/json")
      |> post("/graphiql", params)

      assert Transactions.list_transactions([]) == []
    end

    test "update transaction updates data for transaction and company", %{
      company: company,
      valid_snake_attrs: valid_snake_attrs,
      user1: user1,
      merchant1: merchant1
    } do
      {:ok, transaction} = Transactions.create_transaction(valid_snake_attrs)

      mutation = """
      mutation updateTransaction($userId: ID!, $merchantId: ID!, $amount: Int!, $credit: Boolean!, $debit: Boolean!, $description: String!, $companyId: ID!, $id: ID!){
          updateTransaction(userId: $userId, merchantId: $merchantId, amount: $amount, credit: $credit, debit: $debit, description: $description, companyId: $companyId, id: $id){
            amount
            companyId
            userId
            merchantId
            credit
            debit 
          }
        }
        
      """

      updated_attrs = %{
        userId: user1.id,
        merchantId: merchant1.id,
        amount: 1000,
        credit: true,
        debit: false,
        description: "desc",
        companyId: company.id,
        id: transaction.id
      }

      params = %{
        query: mutation,
        variables: updated_attrs
      }

      build_conn()
      |> put_req_header("content-type", "application/json")
      |> post("/graphiql", params)

      updated_transaction = Transactions.get_transaction!(transaction.id)
      updated_company = Companies.get!(company.id)
      assert updated_company.available_credit < company.available_credit
      assert updated_transaction.id == transaction.id
      assert updated_transaction.amount == updated_attrs.amount
      assert updated_transaction.credit == updated_attrs.credit
      assert updated_transaction.debit == updated_attrs.debit
    end

    test "delete removes transaction", %{
      company: company,
      delete_mutation: delete_mutation,
      valid_snake_attrs: valid_snake_attrs
    } do
      {:ok, transaction} = Transactions.create_transaction(valid_snake_attrs)

      params = %{
        query: delete_mutation,
        variables: %{"id" => transaction.id, "companyId" => company.id}
      }

      build_conn()
      |> put_req_header("content-type", "application/json")
      |> post("/graphiql", params)

      assert Transactions.list_transactions([]) == []
    end

    test "delete only deletes one transaction", %{
      company: company,
      delete_mutation: delete_mutation,
      valid_snake_attrs: valid_snake_attrs
    } do
      Transactions.create_transaction(valid_snake_attrs)
      {:ok, transaction} = Transactions.create_transaction(valid_snake_attrs)

      params = %{
        query: delete_mutation,
        variables: %{"id" => transaction.id, "companyId" => company.id}
      }

      build_conn()
      |> put_req_header("content-type", "application/json")
      |> post("/graphiql", params)

      assert length(Transactions.list_transactions([])) == 1
    end
  end
end
