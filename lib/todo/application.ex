defmodule Todo.Application do
  use Application

  def start(_type, _args) do
    children = [
      {Registry, keys: :unique, name: Registry.TodoLists}
    ]
    options = [strategy: :one_for_one, name: Todo.Supervisor]
    Supervisor.start_link(children, options)
  end
end
