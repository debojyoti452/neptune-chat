defmodule NeptuneBackendWeb.AuthController do
  use NeptuneBackendWeb, :controller

  alias NeptuneBackend.Accounts
  alias NeptuneBackend.Auth

  def register(conn, %{"pubkey" => pubkey}) do
    with :ok <- validate_pubkey_format(pubkey),
         {:ok, user} <- Accounts.register_or_fetch(pubkey),
         {:ok, token} <- Auth.issue_token(user.id) do
      conn
      |> put_status(:created)
      |> render(:registered, token: token, user: user)
    else
      {:error, :invalid_pubkey} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(:error, message: "pubkey must be a 64-character lowercase hex string")

      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(:error, message: format_changeset_errors(changeset))
    end
  end

  def register(conn, _params) do
    conn
    |> put_status(:unprocessable_entity)
    |> render(:error, message: "missing required field: pubkey")
  end

  def revoke(conn, _params) do
    case get_req_header(conn, "authorization") do
      ["Bearer " <> token] ->
        Auth.revoke_token(token)
        send_resp(conn, :no_content, "")

      _ ->
        conn
        |> put_status(:unauthorized)
        |> render(:error, message: "missing authorization header")
    end
  end

  defp validate_pubkey_format(pubkey)
       when is_binary(pubkey) and byte_size(pubkey) == 64 do
    if String.match?(pubkey, ~r/^[0-9a-f]{64}$/) do
      :ok
    else
      {:error, :invalid_pubkey}
    end
  end

  defp validate_pubkey_format(_), do: {:error, :invalid_pubkey}

  defp format_changeset_errors(changeset) do
    changeset
    |> Ecto.Changeset.traverse_errors(fn {msg, _opts} -> msg end)
    |> Enum.map_join("; ", fn {field, errors} -> "#{field}: #{Enum.join(errors, ", ")}" end)
  end
end
