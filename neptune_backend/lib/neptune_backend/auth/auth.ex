defmodule NeptuneBackend.Auth do
  import Ecto.Query

  alias NeptuneBackend.Repo
  alias NeptuneBackend.Auth.{AuthToken, Token}

  @ttl_days 30

  def issue_token(user_id) do
    raw_token = Token.sign(user_id)
    token_hash = hash(raw_token)
    expires_at = DateTime.utc_now() |> DateTime.add(@ttl_days, :day) |> DateTime.truncate(:second)

    result =
      %AuthToken{}
      |> AuthToken.changeset(%{token_hash: token_hash, expires_at: expires_at, user_id: user_id})
      |> Repo.insert()

    case result do
      {:ok, _} -> {:ok, raw_token}
      error -> error
    end
  end

  def verify_token(raw_token) do
    token_hash = hash(raw_token)

    with {:ok, user_id} <- Token.verify(raw_token),
         %AuthToken{} = record <- Repo.get_by(AuthToken, token_hash: token_hash),
         true <- is_nil(record.revoked_at),
         :gt <- DateTime.compare(record.expires_at, DateTime.utc_now()) do
      {:ok, user_id}
    else
      nil -> {:error, :not_found}
      false -> {:error, :revoked}
      :lt -> {:error, :expired}
      :eq -> {:error, :expired}
      error -> error
    end
  end

  def revoke_token(raw_token) do
    token_hash = hash(raw_token)

    case Repo.get_by(AuthToken, token_hash: token_hash) do
      nil ->
        {:error, :not_found}

      record ->
        record
        |> Ecto.Changeset.change(revoked_at: DateTime.utc_now() |> DateTime.truncate(:second))
        |> Repo.update()
        |> case do
          {:ok, _} -> :ok
          error -> error
        end
    end
  end

  def prune_expired do
    Repo.delete_all(from t in AuthToken, where: t.expires_at < ^DateTime.utc_now())
  end

  defp hash(raw_token) do
    :crypto.hash(:sha256, raw_token) |> Base.encode16(case: :lower)
  end
end
