defmodule CombatlessWeb.HiscoreView do
  use CombatlessWeb, :view

  import Scrivener.HTML
  import Combatless.Utils, only: [format_integer: 1]
  import Combatless.Accounts, only: [printable_account_name: 1]

  @allowed_skills ~w(ehp overall cooking woodcutting fletching fishing
                    firemaking crafting smithing mining herblore
                    agility thieving farming runecraft hunter
                    construction)

  def build_skill_icon_items(conn, skill) do
    sprites = static_path(conn, "/images/skill_icons.svg")
    for s <- @allowed_skills do
      content_tag(:li) do
        content_tag(:a, href: hiscore_path(conn, :index, skill: s)) do
          active? = if s == skill, do: " hiscore-active"
          content_tag(:svg, tag(:use, [{:"xlink:href", "#{sprites}\##{s}"}]), class: "skill-icon#{active?}")
        end
      end
    end
  end

  def build_hiscore_list(conn, %Scrivener.Page{} = page, skill) do
    base_index = (page.page_size * (page.page_number - 1)) + 1
    for {hiscore, rank} <- Enum.with_index(page.entries, base_index) do
      name = hiscore.account.name
      content_tag(:tr) do
        [
          content_tag(:td, "#{rank}.", class: "hiscore-rank data"),
          content_tag(
            :td,
            content_tag(:a, printable_account_name(name), href: profile_path(conn, :show, name)),
            class: "hiscore-name"
          ),
          content_tag(:td, hiscore_value(hiscore.skill_datapoint, skill), class: "data")
        ]
      end
    end
  end

  defp hiscore_value(data, skill) do
    case skill do
      "overall" ->
        format_integer(data.virtual_level)
      "ehp" ->
        value =
          data.ehp
          |> trunc()
          |> format_integer()
      _ ->
        format_integer(data.xp)
    end
  end
end
