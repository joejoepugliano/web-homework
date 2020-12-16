defmodule HomeworkWeb.Schemas.CompaniesSchema do
  @moduledoc """
  Defines the graphql schema for companies.
  """
  use Absinthe.Schema.Notation

  alias HomeworkWeb.Resolvers.CompaniesResolver

  object :company do
    field(:available_credit, non_null(:integer))
    field(:credit_line, non_null(:integer))
    field(:name, non_null(:string))
    field(:id, non_null(:id))
  end

  object :company_mutations do
    @desc "Create a new company"
    field :create_company, :company do
      arg(:name, non_null(:string))
      arg(:credit_line, :integer)

      resolve(&CompaniesResolver.create/3)
    end

    @desc "Update a company"
    field :update_company, :company do
        arg(:id, non_null(:id))
        arg(:name, non_null(:string))
        arg(:credit_line, non_null(:integer))

        resolve(&CompaniesResolver.update/3)
    end

    @desc "Delete a company"
    field :delete_company, :company do
        arg(:id, non_null(:id))

        resolve(&CompaniesResolver.delete/3)
    end
  end
end
