defmodule HomeworkWeb.Resolvers.TransactionsResolver do
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
  def create_transaction(_root, args, _info) do
    Transactions.create(args)
  end

  @doc """
  Updates a transaction for an id with args specified.
  """
  def update_transaction(_root, args, _info) do
    Transactions.update(args)
  end

  @doc """
  Deletes a transaction for an id
  """
  def delete_transaction(_root, args, _info) do
    Transactions.delete(args)
  end
end
