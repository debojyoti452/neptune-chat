defmodule NeptuneBackend.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "users" do
    field :pubkey, :string
    field :display_name, :string

    timestamps(type: :utc_datetime)
  end

  def changeset(user, attrs) do
    user
    |> cast(attrs, [:pubkey, :display_name])
    |> validate_required([:pubkey])
    |> validate_length(:pubkey, is: 64)
    |> validate_format(:pubkey, ~r/^[0-9a-f]{64}$/)
    |> unique_constraint(:pubkey)
  end
end
