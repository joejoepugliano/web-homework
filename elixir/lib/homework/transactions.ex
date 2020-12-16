defmodule Homework.Transactions do
  @moduledoc """
  The Transactions context.
  """

  import Ecto.Query, warn: false
  alias Homework.Repo

  alias Homework.Companies
  alias Homework.Transactions.Transaction

  @doc """
  Returns the list of transactions.

  ## Examples

      iex> list_transactions([])
      [%Transaction{}, ...]

  """
  def list_transactions(_args) do
    Repo.all(Transaction)
  end

  @doc """
  Gets a single transaction.

  Raises `Ecto.NoResultsError` if the Transaction does not exist.

  ## Examples

      iex> get_transaction!(123)
      %Transaction{}

      iex> get_transaction!(456)
      ** (Ecto.NoResultsError)

  """
  def get_transaction!(id), do: Repo.get!(Transaction, id)

  def get_transactions_by_company_id(id) do
    query =
      from(t in Transaction,
        where: t.company_id == ^id
      )

    Repo.all(query)
  end

  @doc """
  Creates a transaction.

  ## Examples

      iex> create(%{field: value})
      {:ok, %Transaction{}}

      iex> create(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create(%{company_id: company_id} = args) do
    with {:ok, transaction} <- create_transaction(args),
         {:ok, _company} <- update_company(company_id) do
      {:ok, transaction}
    else
      {:company_error, error} ->
        {:error, "could not update company: #{inspect(error)}"}

      error ->
        {:error, "could not create transaction: #{inspect(error)}"}
    end
  end

  def create_transaction(attrs) do
    %Transaction{}
    |> Transaction.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a transaction.

  ## Examples

      iex> update(transaction, %{field: new_value})
      {:ok, %Transaction{}}

      iex> update(transaction, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update(%{id: id, company_id: company_id} = args) do
    with transaction <- get_transaction!(id),
         {:ok, transaction} <- update_transaction(transaction, args),
         {:ok, _company} <- update_company(company_id) do
      {:ok, transaction}
    else
      {:company_error, error} ->
        {:error, "could not update company: #{inspect(error)}"}

      error ->
        {:error, "could not update transaction: #{inspect(error)}"}
    end
  end

  def update_transaction(%Transaction{} = transaction, attrs) do
    transaction
    |> Transaction.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a transaction.

  ## Examples

      iex> delete(transaction)
      {:ok, %Transaction{}}

      iex> delete(transaction)
      {:error, %Ecto.Changeset{}}

  """
  def delete(%{id: id, company_id: company_id}) do
    with transaction <- get_transaction!(id),
         {:ok, transaction} <- delete_transaction(transaction),
         {:ok, _company} <- update_company(company_id) do
      {:ok, transaction}
    else
      {:company_error, error} ->
        {:error, "could not update company: #{inspect(error)}"}

      error ->
        {:error, "could not delete transaction: #{inspect(error)}"}
    end
  end

  def delete_transaction(%Transaction{} = transaction) do
    Repo.delete(transaction)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking transaction changes.

  ## Examples

      iex> change_transaction(transaction)
      %Ecto.Changeset{data: %Transaction{}}

  """
  def change_transaction(%Transaction{} = transaction, attrs \\ %{}) do
    Transaction.changeset(transaction, attrs)
  end

  defp update_company(company_id) do
    with all_company_transactions <- get_transactions_by_company_id(company_id),
         {:ok, company} <- Companies.update(company_id, all_company_transactions) do
      {:ok, company}
    else
      error -> {:company_error, error}
    end
  end
end
