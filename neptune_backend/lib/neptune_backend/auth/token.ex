defmodule NeptuneBackend.Auth.Token do
  @salt "neptune_auth_token_v1"
  @ttl_seconds 30 * 24 * 60 * 60

  def sign(user_id) do
    Phoenix.Token.sign(NeptuneBackendWeb.Endpoint, @salt, user_id)
  end

  def verify(token) do
    Phoenix.Token.verify(NeptuneBackendWeb.Endpoint, @salt, token, max_age: @ttl_seconds)
  end
end
