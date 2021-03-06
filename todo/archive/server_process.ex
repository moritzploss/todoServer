# this is a very basic implementation of `GenServer`
# this isn't used anywhere and was only built to deepen my understanding

defmodule Todo.ServerProcess do

  defp loop(callback_module, current_state) do
    receive do
      {:call, request, caller} ->
        {action, response, new_state} =
          callback_module.handle_call(request, current_state)
        send(caller, {:response, response})
        loop(callback_module, new_state)
      {:cast, request} ->
        {action, new_state} = callback_module.handle_cast(request, current_state)
        loop(callback_module, new_state)
    end
  end

  # GenServer

  def start(callback_module, args) do
    spawn(fn ->
      {:ok, initial_state} = callback_module.init(args)
      loop(callback_module, initial_state)
    end)
  end

  def call(server_pid, request) do
    send(server_pid, {:call, request, self()})
    receive do
      {:response, response} -> response
    end
  end

  def cast(server_pid, request) do
    send(server_pid, {:cast, request})
  end
end
