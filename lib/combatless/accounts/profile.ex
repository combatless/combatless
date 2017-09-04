defmodule Combatless.Accounts.Profile do
  defstruct datapoints: %{
              most_recent: nil,
              least_recent: nil,
            },
            hiscores: %{
              most_recent: nil,
              least_recent: nil,
              diff: nil
            },
            has_diff?: false,
            times: %{
              now: Timex.now(),
              starting_time: nil
            },
            account: nil
end
