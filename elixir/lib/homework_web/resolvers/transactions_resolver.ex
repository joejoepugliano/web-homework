defmodule HomeworkWeb.Resolvers.TransactionsResolver do
  alias Homework.Companies
  alias Homework.Merchants
  alias Homework.Transactions
  alias Homework.Users

  @doc """
  Get a list of transcations
  """
  def transactions(_root, args, _info) do
    {:ok, Transactions.list_transactions(args)}
  end

  @doc """
  Get the user associated with a transaction
  """
  def user(_root, _args, %{source: %{user_id: user_id}}) do
    {:ok, Users.get_user!(user_id)}
  end

  @doc """
  Get the merchant associated with a transaction
  """
  def merchant(_root, _args, %{source: %{merchant_id: merchant_id}}) do
    {:ok, Merchants.get_merchant!(merchant_id)}
  end

  @doc """
  Create a new transaction
  """
  def create_transaction(_root, %{company_id: company_id} = args, _info) do
    with {:ok, transaction} <- Transactions.create_transaction(args),
    {:ok, _company} <- update_company(company_id) do
      {:ok, transaction}

    else
      {:company_error, error} -> {:error, "could not update company: #{inspect(error)}"}
      error ->
        {:error, "could not create transaction: #{inspect(error)}"}
    end
  end

  @doc """
  Updates a transaction for an id with args specified.
  """
  def update_transaction(_root, %{id: id, company_id: company_id} = args, _info) do
    with transaction <- Transactions.get_transaction!(id),
    {:ok, transaction} <- Transactions.update_transaction(transaction, args),
    {:ok, _company} <- update_company(company_id) do
      {:ok, transaction}
    else
      {:company_error, error} -> {:error, "could not update company: #{inspect(error)}"}

      error ->
        {:error, "could not update transaction: #{inspect(error)}"}
    end
  end

  @doc """
  Deletes a transaction for an id
  """
  def delete_transaction(_root, %{id: id, company_id: company_id}, _info) do
    with transaction <- Transactions.get_transaction!(id),
    {:ok, transaction} <- Transactions.delete_transaction(transaction),
    {:ok, _company} <- update_company(company_id) do
      {:ok, transaction}
    else
      {:company_error, error} -> {:error, "could not update company: #{inspect(error)}"}

      error ->
        {:error, "could not delete transaction: #{inspect(error)}"}
    end
  end

  defp update_company(company_id) do
    with all_company_transactions <- Transactions.by_company_id(company_id),
    {:ok, company} <- Companies.update(company_id, all_company_transactions) do
      {:ok, company}
    else
      error -> {:company_error, error}
    end
  end
end
