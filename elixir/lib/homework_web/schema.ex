defmodule HomeworkWeb.Schema do
  @moduledoc """
  Defines the graphql schema for this project.
  """
  use Absinthe.Schema

  alias HomeworkWeb.Resolvers.{
    CompaniesResolver,
    MerchantsResolver,
    TransactionsResolver,
    UsersResolver
  }

  import_types(HomeworkWeb.Schemas.Types)

  query do
    @desc "Get all Companies"
    field(:companies, list_of(:company)) do
      resolve(&CompaniesResolver.companies/3)
    end

    @desc "Get all Transactions"
    field(:transactions, list_of(:transaction)) do
      resolve(&TransactionsResolver.transactions/3)
    end

    @desc "Get all Transactions between min and max values"
    field(:transactions_between_min_and_max, list_of(:transaction)) do
      arg(:max, non_null(:integer))
      arg(:min, non_null(:integer))

      resolve(&TransactionsResolver.transactions_between_min_and_max/3)
    end

    @desc "Get all Users"
    field(:users, list_of(:user)) do
      resolve(&UsersResolver.users/3)
    end

    @desc "Get all Merchants"
    field(:merchants, list_of(:merchant)) do
      resolve(&MerchantsResolver.merchants/3)
    end
  end

  mutation do
    import_fields(:company_mutations)
    import_fields(:transaction_mutations)
    import_fields(:user_mutations)
    import_fields(:merchant_mutations)
  end
end
