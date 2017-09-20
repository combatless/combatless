defmodule CombatlessWeb.HiscoreView do
  use CombatlessWeb, :view
  import Scrivener.HTML

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

  def build_hiscore_list(conn, %Scrivener.Page{} = page) do
    base_index = (page.page_size * (page.page_number - 1)) + 1
    for {hiscore, rank} <- Enum.with_index(page.entries, base_index) do
      content_tag(:li) do
        content_tag(:span) do
          [
            "#{rank}.",
            content_tag(
              :a,
              printable_account_name(hiscore.account.name),
              href: profile_path(conn, :show, hiscore.account.name)
            )
          ]
        end
      end
    end
  end
end
