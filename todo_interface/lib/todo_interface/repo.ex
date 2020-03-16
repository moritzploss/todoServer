defmodule TodoInterface.Repo do
  use Ecto.Repo,
    otp_app: :todo_interface,
    adapter: Ecto.Adapters.Postgres
end
