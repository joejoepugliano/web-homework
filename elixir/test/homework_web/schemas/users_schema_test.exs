defmodule HomeworkWeb.UsersSchemaTest do
  use Homework.DataCase
  use HomeworkWeb.ConnCase

  alias Homework.{Companies, Users}

  describe "Users" do
    setup do
      {:ok, company} = Companies.create_company(%{name: "Company"})

      valid_attrs = %{
        dob: "some dob",
        firstName: "some first_name",
        lastName: "some last_name",
        companyId: company.id
      }

      valid_snake_attrs = %{
        dob: "some dob",
        first_name: "some first_name",
        last_name: "some last_name",
        company_id: company.id
      }

      invalid_attrs = %{
        dob: nil,
        first_name: nil,
        last_name: nil,
        company_id: nil
      }

      create_mutation = """
      mutation createUser($dob: String!, $firstName: String!, $lastName: String!, $companyId: ID!){
        createUser(dob: $dob, firstName: $firstName, lastName: $lastName, companyId: $companyId){
          firstName
          lastName
          id
          dob
        }
      }
      """

      delete_mutation = """
      mutation deleteUser($id: ID!){
          deleteUser(id: $id){
            id
          }
        }
      """

      {:ok,
       %{
         company: company,
         valid_attrs: valid_attrs,
         valid_snake_attrs: valid_snake_attrs,
         invalid_attrs: invalid_attrs,
         create_mutation: create_mutation,
         delete_mutation: delete_mutation
       }}
    end

    test "create with valid data creates user", %{
      create_mutation: create_mutation,
      valid_attrs: valid_attrs
    } do
      params = %{query: create_mutation, variables: valid_attrs}

      conn =
        build_conn()
        |> put_req_header("content-type", "application/json")
        |> post("/graphiql", params)

      %{"data" => %{"createUser" => result}} = conn.resp_body |> Jason.decode!()
      assert result["firstName"] == valid_attrs.firstName
      assert Users.get_user!(result["id"]) != nil
    end

    test "create with invalid data does not create user", %{
      create_mutation: create_mutation,
      invalid_attrs: invalid_attrs
    } do
      params = %{query: create_mutation, variables: invalid_attrs}

      build_conn()
      |> put_req_header("content-type", "application/json")
      |> post("/graphiql", params)

      assert Users.list_users([]) == []
    end

    test "update user updates data", %{company: company, valid_snake_attrs: valid_snake_attrs} do
      {:ok, user} = Users.create_user(valid_snake_attrs)

      mutation = """
      mutation updateUser($firstName: String!, $lastName: String!, $dob: String!, $id: ID!){
          updateUser(firstName: $firstName, lastName: $lastName,  dob: $dob, id: $id){
            firstName
            lastName
            dob
            id
          }
        }
      """

      updated_attrs = %{
        dob: "some updated dob",
        firstName: "some updated first_name",
        lastName: "some updated last_name",
        companyId: company.id,
        id: user.id
      }

      params = %{
        query: mutation,
        variables: updated_attrs
      }

      build_conn()
      |> put_req_header("content-type", "application/json")
      |> post("/graphiql", params)

      updated_user = Users.get_user!(user.id)
      assert updated_user.id == user.id
      assert updated_user.first_name == updated_attrs.firstName
      assert updated_user.last_name == updated_attrs.lastName
      assert updated_user.dob == updated_attrs.dob
    end

    test "delete removes user", %{
      delete_mutation: delete_mutation,
      valid_snake_attrs: valid_snake_attrs
    } do
      {:ok, user} = Users.create_user(valid_snake_attrs)

      params = %{query: delete_mutation, variables: %{"id" => user.id}}

      build_conn()
      |> put_req_header("content-type", "application/json")
      |> post("/graphiql", params)

      assert Users.list_users([]) == []
    end

    test "delete only deletes one user", %{
      delete_mutation: delete_mutation,
      valid_snake_attrs: valid_snake_attrs
    } do
      Users.create_user(valid_snake_attrs)
      {:ok, user} = Users.create_user(valid_snake_attrs)

      params = %{query: delete_mutation, variables: %{"id" => user.id}}

      build_conn()
      |> put_req_header("content-type", "application/json")
      |> post("/graphiql", params)

      assert length(Users.list_users([])) == 1
    end
  end
end
