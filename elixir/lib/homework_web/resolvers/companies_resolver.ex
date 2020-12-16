defmodule HomeworkWeb.Resolvers.CompaniesResolver do
  alias Homework.{Companies, Transactions}

  def companies(_root, _args, _info) do
    {:ok, Companies.list_companies()}
  end

  @doc """
  Create a new Company
  """
  def create(_root, args, _info) do
    case Companies.create(args) do
      {:ok, company} ->
        {:ok, company}

      error ->
        {:error, "could not create company: #{inspect(error)}"}
    end
  end

  def delete(_root, %{id: id}, _info) do
    company = Companies.get!(id)

    case Companies.delete(company) do
        {:ok, company} ->
            {:ok, company}
    
          error ->
            {:error, "could not delete company: #{inspect(error)}"}
    end
  end

  def update(_root, %{id: id} = args, _info) do
    company = Companies.get!(id)
    transactions = Transactions.by_company_id(id)
    
    case Companies.update(company, args, transactions) do
        {:ok, company} -> {:ok, company}

        error -> {:error, "could not update company: #{inspect(error)}"}
    end
  end
end
