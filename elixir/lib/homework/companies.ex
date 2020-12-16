defmodule Homework.Companies do
  @moduledoc """
  The Companies context.
  """

  import Ecto.Query, warn: false
  alias Homework.Repo

  alias Homework.Companies.Company

  def create(attrs \\ %{})
  def create(%{credit_line: credit_line} = attrs) do
    available_credit = determine_available_credit(credit_line, [])

    %Company{}
    |> Company.changeset(Map.put(attrs, :available_credit, available_credit))
    |> Repo.insert()
  end

  def create(attrs) do
    %Company{}
    |> Company.changeset(attrs)
    |> Repo.insert()
  end

  def delete(%Company{} = company), do: Repo.delete(company)

  def get!(id), do: Repo.get!(Company, id)

  def list_companies do
    Repo.all(Company)
  end

  def update(%Company{} = company, %{credit_line: credit_line} = attrs, transactions) do
    available_credit = determine_available_credit(credit_line, transactions)

    company
    |> Company.changeset(Map.put(attrs, :available_credit, available_credit))
    |> Repo.update()
  end

  def update(id, transactions) do
    company = get!(id)
    available_credit = determine_available_credit(company.credit_line, transactions)|> IO.inspect(label: "4444")

    company
    |> Company.changeset(%{available_credit: available_credit})
    |> Repo.update()
  end

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
