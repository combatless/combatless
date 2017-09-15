defmodule CombatlessWeb.ProfileView do
  use CombatlessWeb, :view

  alias Combatless.Accounts.Profile

  @display_order ~w(overall cooking woodcutting fletching fishing
                    firemaking crafting smithing mining herblore
                    agility thieving farming runecraft hunter
                    construction)a

  def get_display_order(), do: @display_order

  def get_time_since_least_recent(profile) do
    least_recently_fetched =
      profile.datapoints.least_recent.fetched_at
      |> Timex.diff(profile.times.starting_time, :duration)
      |> Timex.format_duration(:humanized)

    if least_recently_fetched == "", do: "Drops now.", else: "Drops in #{least_recently_fetched}."
  end

  def get_time_since_most_recent(profile) do
    most_recently_fetched =
      profile.datapoints.most_recent.fetched_at
      |> Timex.diff(profile.times.now, :duration)
      |> Timex.format_duration(:humanized)

    if most_recently_fetched == "", do: "Updated just now.", else: "Updated #{most_recently_fetched} ago."
  end

  def get_profile_skill_row_data(skill, sprites, %Profile{} = profile) do
    data = Map.get(profile.hiscores.most_recent, skill)
    content_tag(:tr) do
      [
        content_tag(:td, content_tag(:svg, tag(:use, [{:"xlink:href", "#{sprites}\##{skill}"}]), class: "skill-icon")),
        content_tag(:td, (if data.rank > -1, do: format_integer(data.rank), else: "?"), class: "data"),
        if data.virtual_level == data.level do
          content_tag(:td, data.level, class: "data")
        else
          content_tag(:td, class: "data") do
            content_tag(:abbr, data.virtual_level, class: "virtual-level-tooltip", title: data.level)
          end
        end,
        content_tag(:td, format_integer(data.xp), class: "data"),
        content_tag(:td, get_diff_content(profile, skill, :xp), class: "data"),
        content_tag(:td, get_diff_content(profile, skill, :ehp), class: "data")
      ]
    end
  end

  defp get_diff_content(%Profile{has_diff?: false}, _, _), do: content_tag(:span, "0", class: "diff")
  defp get_diff_content(%Profile{has_diff?: true} = profile, skill, field) do
    profile.hiscores.diff
    |> Map.get(skill)
    |> Map.get(field)
    |> diff_color_tag()
  end

  def diff_color_tag(diff) when is_integer(diff) do
    diff
    |> format_integer()
    |> format_diff(diff)
  end

  def diff_color_tag(diff) when is_float(diff) do
    case diff do
      diff when diff == 0 -> "0"
      diff -> :erlang.float_to_binary diff, decimals: 2
    end
    |> format_diff(diff)
  end

  defp format_diff(diff_str, diff) do
    cond do
      diff == 0 -> content_tag :span, diff_str, class: "diff"
      diff > 0 -> content_tag :span, "+#{diff_str}", class: "diff positive"
      diff < 0 -> content_tag :span, diff_str, class: "diff negative"
    end
  end

  def format_integer(integer) do
    integer
    |> Integer.to_charlist()
    |> Enum.reverse()
    |> partition_integer([])
  end

  defp partition_integer([a, b, c, ?- | _tail], acc) do
    [?-, c, b, a | acc]
  end

  defp partition_integer([a, b, c, d | tail], acc) do
    partition_integer [d | tail], [?,, c, b, a | acc]
  end

  defp partition_integer(rest, acc) do
    Enum.reverse(rest) ++ acc
  end
end
