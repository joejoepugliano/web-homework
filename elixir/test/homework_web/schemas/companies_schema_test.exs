defmodule HomeworkWeb.CompaniesSchemaTest do
  use Homework.DataCase
  use HomeworkWeb.ConnCase

  alias Homework.Companies

  describe "companies" do
    @valid_attrs %{"name" => "divvy", "creditLine" => 100}
    @invalid_attrs %{"name" => nil, "creditLine" => nil}
    @create_mutation """
    mutation createCompany($name: String!, $creditLine: Int!){
        createCompany(name: $name, creditLine: $creditLine){
          name
          availableCredit
          creditLine
          id
        }
      }
    """
    @delete_mutation """
    mutation deleteCompany($id: ID!){
        deleteCompany(id: $id){
          name
        }
      }
    """

    test "create with valid data creates company" do
      params = %{query: @create_mutation, variables: @valid_attrs}

      conn =
        build_conn()
        |> put_req_header("content-type", "application/json")
        |> post("/graphiql", params)

      %{"data" => %{"createCompany" => result}} = conn.resp_body |> Jason.decode!()
      assert result["name"] == @valid_attrs["name"]
      assert Companies.get!(result["id"]) != nil
    end

    test "create with invalid data does not create company" do
      params = %{query: @create_mutation, variables: @invalid_attrs}

      build_conn()
      |> put_req_header("content-type", "application/json")
      |> post("/graphiql", params)

      assert Companies.list_companies() == []
    end

    test "update company updates data" do
      {:ok, company} = Companies.create_company(%{name: "name"})

      mutation = """
      mutation updateCompany($name: String!, $creditLine: Int!, $id: ID!){
          updateCompany(name: $name, creditLine: $creditLine, id: $id){
            name
            availableCredit
            creditLine
          }
        }
      """

      params = %{
        query: mutation,
        variables: %{"name" => "updated", "creditLine" => 10, "id" => company.id}
      }

      build_conn()
      |> put_req_header("content-type", "application/json")
      |> post("/graphiql", params)

      updated_company = Companies.get!(company.id)
      assert updated_company.id == company.id
      assert updated_company.name == "updated"
      assert updated_company.credit_line == 10
    end

    test "delete removes company" do
      {:ok, company} = Companies.create_company(%{name: "name"})

      params = %{query: @delete_mutation, variables: %{"id" => company.id}}

      build_conn()
      |> put_req_header("content-type", "application/json")
      |> post("/graphiql", params)

      assert Companies.list_companies() == []
    end

    test "delete only deletes one company" do
      Companies.create_company(%{name: "first"})
      {:ok, company} = Companies.create_company(%{name: "second"})

      params = %{query: @delete_mutation, variables: %{"id" => company.id}}

      build_conn()
      |> put_req_header("content-type", "application/json")
      |> post("/graphiql", params)

      assert length(Companies.list_companies()) == 1
    end
  end
end
