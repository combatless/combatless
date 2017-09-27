defmodule CombatlessWeb.ProfileView do
  use CombatlessWeb, :view

  alias Combatless.Utils
  alias Combatless.Accounts.Profile

  @display_order ~w(overall cooking woodcutting fletching fishing
                    firemaking crafting smithing mining herblore
                    agility thieving farming runecraft hunter
                    construction)a

  @allowed_periods ~w(day week month year all)a

  def get_display_order(), do: @display_order

  def get_period_link(conn, profile, period) do
    class = if period == profile.period, do: "nav-link disabled", else: "nav-link"
    link = profile_path(conn, :show, profile.account.name, period: period)
    content_tag(:a, String.capitalize("#{period}"), href: link, class: class)
  end

  def get_period_links(conn, profile) do
    for period <- @allowed_periods do
      get_period_link(conn, profile, period)
    end
  end

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

    if most_recently_fetched == "0 microseconds", do: "Updated just now.", else: "Updated #{most_recently_fetched} ago."
  end

  def get_profile_skill_row_data(conn, skill, %Profile{} = profile) do
    sprites = static_path(conn, "/images/skill_icons.svg")
    data = Map.get(profile.hiscores.most_recent, skill)
    content_tag(:tr) do
      [
        content_tag(
          :td,
          content_tag(:svg, tag(:use, [{:"xlink:href", "#{sprites}\##{skill}"}]), class: "skill-icon"),
          class: "profile-data-icon",
          data: [
            title: skill
                   |> Atom.to_string()
                   |> String.capitalize(),
            toggle: "tooltip",
            placement: "top"
          ]
        ),
        content_tag(:td, Utils.delimit(get_rank(profile, skill)), class: "data"),
        if data.virtual_level == data.level do
          content_tag(:td, Utils.delimit(data.level), class: "data")
        else
          content_tag(:td, class: "data") do
            title = if skill == :overall, do: Utils.delimit(data.level), else: "Virtual Level"
            content_tag(
              :span,
              Utils.delimit(data.virtual_level),
              class: "data virtual-level-tooltip",
              data: [
                title: title,
                toggle: "tooltip",
                placement: "left"
              ]
            )
          end
        end,
        content_tag(:td, Utils.delimit(data.xp), class: "data"),
        content_tag(:td, get_diff(profile, skill, :xp), class: "data"),
        content_tag(:td, get_diff(profile, skill, :ehp), class: "data"),
        content_tag(:td, Utils.delimit(data.ehp), class: "data")
      ]
    end
  end

  defp get_rank(%Profile{ranks: nil}), do: "?"
  defp get_rank(%Profile{ranks: ranks}, :overall), do: if ranks[:ehp] > 0, do: ranks[:ehp], else: "?"
  defp get_rank(%Profile{ranks: ranks}, skill), do: if ranks[skill] > 0, do: ranks[skill], else: "?"

  defp get_diff(%Profile{has_diff?: false}, _, _), do: content_tag(:span, "0", class: "diff")
  defp get_diff(%Profile{has_diff?: true} = profile, skill, value) do
    data =
      profile.hiscores.diff
      |> Map.get(skill)
      |> Map.get(value)

    content_tag(:span, Utils.delimit(data), class: diff_class(data))
  end

  defp diff_class(value) when is_bitstring(value), do: "diff"
  defp diff_class(value) do
    cond do
      value == 0 -> "diff"
      value > 0 -> "diff positive"
      value < 0 -> "diff negative"
    end
  end
end
