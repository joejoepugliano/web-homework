defmodule HomeworkWeb.MerchantsSchemaTest do
  use Homework.DataCase
  use HomeworkWeb.ConnCase

  alias Homework.{Merchants}

  describe "merchants" do
    @valid_attrs %{description: "some description", name: "some name"}
    @invalid_attrs %{description: nil, name: nil}
    @create_mutation """
    mutation createMerchant($name: String!, $description: String!){
        createMerchant(name: $name, description: $description){
          name
          description
          id
        }
      }
    """
    @delete_mutation """
    mutation deleteMerchant($id: ID!){
        deleteMerchant(id: $id){
          name
        }
      }
    """

    test "create with valid data creates merchant" do
      params = %{query: @create_mutation, variables: @valid_attrs}

      conn =
        build_conn()
        |> put_req_header("content-type", "application/json")
        |> post("/graphiql", params)

      %{"data" => %{"createMerchant" => result}} = conn.resp_body |> Jason.decode!()
      assert result["name"] == @valid_attrs.name
      assert Merchants.get_merchant!(result["id"]) != nil
    end

    test "create with invalid data does not create merchant" do
      params = %{query: @create_mutation, variables: @invalid_attrs}

      build_conn()
      |> put_req_header("content-type", "application/json")
      |> post("/graphiql", params)

      assert Merchants.list_merchants([]) == []
    end

    test "update merchant updates data" do
      {:ok, merchant} = Merchants.create_merchant(@valid_attrs)

      mutation = """
      mutation updateMerchant($name: String!, $description: String!, $id: ID!){
          updateMerchant(name: $name, description: $description, id: $id){
            name
            description
            id
          }
        }
      """

      params = %{
        query: mutation,
        variables: %{
          description: "some updated description",
          name: "some updated name",
          id: merchant.id
        }
      }

      build_conn()
      |> put_req_header("content-type", "application/json")
      |> post("/graphiql", params)

      updated_merchant = Merchants.get_merchant!(merchant.id)
      assert updated_merchant.id == merchant.id
      assert updated_merchant.name == "some updated name"
      assert updated_merchant.description == "some updated description"
    end

    test "delete removes merchant" do
      {:ok, merchant} = Merchants.create_merchant(@valid_attrs)

      params = %{query: @delete_mutation, variables: %{"id" => merchant.id}}

      build_conn()
      |> put_req_header("content-type", "application/json")
      |> post("/graphiql", params)

      assert Merchants.list_merchants([]) == []
    end

    test "delete only deletes one merchant" do
      Merchants.create_merchant(@valid_attrs)
      {:ok, merchant} = Merchants.create_merchant(@valid_attrs)

      params = %{query: @delete_mutation, variables: %{"id" => merchant.id}}

      build_conn()
      |> put_req_header("content-type", "application/json")
      |> post("/graphiql", params)

      assert length(Merchants.list_merchants([])) == 1
    end
  end
end
