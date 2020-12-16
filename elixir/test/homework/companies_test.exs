defmodule Homework.CompaniesTest do
  use Homework.DataCase
  alias Homework.Companies
  alias Homework.Companies.Company

  describe "companies" do
    @valid_attrs %{name: "divvy", credit_line: 100}
    @invalid_attrs %{name: nil, credit_line: nil}

    def company_fixture(attrs \\ %{}) do
      {:ok, company} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Companies.create()

      company
    end

    test "create/1" do
      {:ok, company} = Companies.create(@valid_attrs)
      assert company.name == @valid_attrs.name
      assert company.credit_line == @valid_attrs.credit_line
    end

    test "create/1 with invalid parameters" do
      assert {:error, _error} = Companies.create(@invalid_attrs)
    end

    test "delete/1" do
      company = company_fixture()
      assert {:ok, %Company{}} = Companies.delete(company)
      assert_raise Ecto.NoResultsError, fn -> Companies.get!(company.id) end
    end

    test "list_companies/0" do
      company = company_fixture()
      assert Companies.list_companies() == [company]
    end

    test "get/1" do
      company = company_fixture()
      assert Companies.get!(company.id) == company
    end

    test "update/1" do
      company = company_fixture()

      assert {:ok, %Company{} = company} =
               Companies.update(%{name: "updated", credit_line: 10, id: company.id})

      assert company.name == "updated"
      assert company.credit_line == 10
    end

    test "update/2" do
      company = company_fixture()
      transactions = [%{amount: 2, credit: true}]
      assert {:ok, %Company{}} = Companies.update(company.id, transactions)
    end
  end
end
