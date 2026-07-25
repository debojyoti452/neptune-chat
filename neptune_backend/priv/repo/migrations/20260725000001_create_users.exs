defmodule NeptuneBackend.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :pubkey, :string, null: false, size: 64
      add :display_name, :string

      timestamps(type: :utc_datetime)
    end

    create unique_index(:users, [:pubkey])
  end
end
