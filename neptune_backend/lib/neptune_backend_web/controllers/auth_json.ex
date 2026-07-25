defmodule NeptuneBackendWeb.AuthJSON do
  def registered(%{token: token, user: user}) do
    %{
      token: token,
      user: %{
        id: user.id,
        pubkey: user.pubkey
      }
    }
  end

  def error(%{message: message}) do
    %{error: message}
  end
end
