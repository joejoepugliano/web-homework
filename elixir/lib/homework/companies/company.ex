defmodule Homework.Companies.Company do
  use Ecto.Schema
  import Ecto.Changeset

  alias Homework.Transactions.Transaction

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "companies" do
    field(:available_credit, :integer, default: 0)
    field(:credit_line, :integer, default: 0)
    field(:name, :string)

    has_many(:transaction, Transaction, foreign_key: :id)

    timestamps()
  end

  @doc false
  def changeset(company, attrs) do
    company
    |> cast(attrs, [:available_credit, :credit_line, :name])
    |> validate_required([:available_credit, :credit_line, :name])
  end
end
