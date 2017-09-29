defmodule Combatless.AutoUpdater do
  use GenServer

  alias Combatless.Accounts

  @interval 1 * 500#5 * 1000 # Every 5 seconds
  @minimum_time 30 * 1000#2 * 60 * 60 * 1000 # Two Hours


  def start_link do
    GenServer.start_link(__MODULE__, %{})
  end

  def init(_) do
    schedule_work()
    {:ok, MapSet.new()}
  end

  def handle_info(:work, state) do
    Combatless.Accounts.get_all_accounts_last_fetched_at()
    |> Enum.filter(fn {id, _} -> !MapSet.member?(state, id) end)
    |> Enum.find(:none_qualified, &qualified?/1)
    |> case do
         {id, _} ->
           id
           |> Accounts.get_account!()
           |> Accounts.create_account_datapoint()

           schedule_work()
           {:noreply, MapSet.put(state, id)}
         :none_qualified ->
           schedule_work()
           {:noreply, MapSet.new()}
       end
  end

  defp qualified?({_, fetched_at}) do
    minimum_time = Timex.shift(Timex.now, milliseconds: -@minimum_time)
    Timex.before?(fetched_at, minimum_time)
  end

  defp schedule_work(), do: Process.send_after(self(), :work, @interval)
end
