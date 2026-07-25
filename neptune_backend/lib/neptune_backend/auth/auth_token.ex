defmodule NeptuneBackend.Auth.AuthToken do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "auth_tokens" do
    field :token_hash, :string
    field :expires_at, :utc_datetime
    field :revoked_at, :utc_datetime

    belongs_to :user, NeptuneBackend.Accounts.User

    timestamps(type: :utc_datetime)
  end

  def changeset(auth_token, attrs) do
    auth_token
    |> cast(attrs, [:token_hash, :expires_at, :user_id])
    |> validate_required([:token_hash, :expires_at, :user_id])
    |> unique_constraint(:token_hash)
    |> foreign_key_constraint(:user_id)
  end
end
