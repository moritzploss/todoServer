defmodule Todo.Debug do

  def users_in_registry do
    Todo.UserManager
      |> DynamicSupervisor.which_children
      |> Enum.map(fn {_id, list_manager_pid, _type, _modules} ->
          Registry.keys(Registry.TodoUsers, list_manager_pid)
        end)
      |> List.flatten()
  end

end
