defmodule HomeworkWeb.Resolvers.CompaniesResolver do
  alias Homework.Companies

  def companies(_root, _args, _info) do
    {:ok, Companies.list_companies()}
  end

  @doc """
  Create a new Company
  """
  def create(_root, args, _info) do
    Companies.create(args)
  end

  def delete(_root, args, _info) do
    Companies.delete(args)
  end

  def update(_root, args, _info) do
    Companies.update(args)
  end
end
