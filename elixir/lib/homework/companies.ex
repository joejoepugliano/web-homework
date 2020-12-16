defmodule Homework.Companies do
  @moduledoc """
  The Companies context.
  """

  import Ecto.Query, warn: false
  alias Homework.Repo

  alias Homework.Companies.Company
  alias Homework.Transactions

  @doc """
  Creates a company and calculates the available_credit
  """
  def create(%{credit_line: credit_line} = args) do
    available_credit = determine_available_credit(credit_line, [])

    case create_company(Map.put(args, :available_credit, available_credit)) do
      {:ok, company} -> {:ok, company}
      error -> {:error, "could not create company: #{inspect(error)}"}
    end
  end

  @doc """
  Creates Company
  """
  def create_company(args) do
    %Company{}
    |> Company.changeset(args)
    |> Repo.insert()
  end

  @doc """
  Fetches and calls Deletes company
  """
  def delete(%{id: id}) do
    with company <- get!(id),
         {:ok, deleted_company} <- delete_company(company) do
      {:ok, deleted_company}
    else
      error ->
        {:error, "could not delete company: #{inspect(error)}"}
    end
  end

  @doc """
  Delets Company
  """
  def delete_company(%Company{} = company), do: Repo.delete(company)

  @doc """
  Fetches Company with given id
  """
  def get!(id), do: Repo.get!(Company, id)

  @doc """
  Fetches all companies
  """
  def list_companies do
    Repo.all(Company)
  end

  @doc """
  Updates a Company and recalculates the available_credit
  """
  def update(%{credit_line: credit_line, id: id} = args) do
    with company <- get!(id),
         transactions <- Transactions.get_transactions_by_company_id(id),
         available_credit <- determine_available_credit(credit_line, transactions),
         {:ok, company} <-
           update_company(company, Map.put(args, :available_credit, available_credit)) do
      {:ok, company}
    else
      error -> {:error, "could not update company: #{inspect(error)}"}
    end
  end

  @doc """
  Updates company's available_credit when a new transaction is received
  """
  def update(id, transactions) do
    with company <- get!(id),
         available_credit <- determine_available_credit(company.credit_line, transactions),
         {:ok, company} <- update_company(company, %{available_credit: available_credit}) do
      {:ok, company}
    else
      error -> error
    end
  end

  @doc """
  Updates company
  """
  def update_company(company, args) do
    company
    |> Company.changeset(args)
    |> Repo.update()
  end

  @doc """
  Calculates how much credit the company has remaining
  """
  defp determine_available_credit(credit_line, transactions) do
    Enum.reduce(transactions, credit_line, fn transaction, acc ->
      if transaction.credit do
        acc - transaction.amount
      else
        acc
      end
    end)
  end
end
