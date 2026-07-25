defmodule NeptuneBackend.Accounts do
  alias NeptuneBackend.Repo
  alias NeptuneBackend.Accounts.User

  def register_or_fetch(pubkey) do
    case Repo.get_by(User, pubkey: pubkey) do
      %User{} = user ->
        {:ok, user}

      nil ->
        %User{}
        |> User.changeset(%{pubkey: pubkey})
        |> Repo.insert()
    end
  end

  def get_user(id) do
    case Repo.get(User, id) do
      nil -> {:error, :not_found}
      user -> {:ok, user}
    end
  end

  def get_user_by_pubkey(pubkey) do
    case Repo.get_by(User, pubkey: pubkey) do
      nil -> {:error, :not_found}
      user -> {:ok, user}
    end
  end

  def update_display_name(pubkey, display_name) do
    with {:ok, user} <- get_user_by_pubkey(pubkey) do
      user
      |> User.changeset(%{display_name: display_name})
      |> Repo.update()
    end
  end
end
