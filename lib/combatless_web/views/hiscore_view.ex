defmodule CombatlessWeb.HiscoreView do
  use CombatlessWeb, :view

  import Scrivener.HTML
  alias Combatless.Utils
  import Combatless.Accounts, only: [printable_account_name: 1]

  @allowed_skills ~w(ehp overall cooking woodcutting fletching fishing
                    firemaking crafting smithing mining herblore
                    agility thieving farming runecraft hunter
                    construction)

  @default_sizes [25, 50, 100, 200]

  def allowed_skills(), do: @allowed_skills
  def active_class(current_skill, page_skill) do
    if current_skill == page_skill, do: "nav-link active", else: "nav-link"
  end

  def list_skill_links(conn, page, page_skill) do
    sprites_url = static_path(conn, "/images/skill_icons.svg")
    for skill <- @allowed_skills do
      content_tag(
        :a,
        href: hiscore_path(conn, :index, skill: skill, page_size: page.page_size),
        class: active_class(skill, page_skill)
      ) do
        content_tag(:svg, tag(:use, [{:"xlink:href", sprites_url <> "#" <> skill}]), class: "skill-icon")
      end
    end
  end

  def build_hiscore_list(conn, %Scrivener.Page{} = page, skill) do
    base_index = (page.page_size * (page.page_number - 1)) + 1
    for {hiscore, rank} <- Enum.with_index(page.entries, base_index) do
      name = hiscore.account.name
      content_tag(:tr) do
        [
          content_tag(:td, "#{rank}.", class: "data"),
          content_tag(
            :td,
            content_tag(:a, printable_account_name(name), href: profile_path(conn, :show, name)),
            class: "hiscore-name"
          ),
          content_tag(
            :td,
            hiscore_value(hiscore, skill),
            class: "data",
            data: [
              title: hiscore_alt_value(hiscore, skill),
              toggle: "tooltip",
              placement: "left"
            ]
          ),
          content_tag(:td, Utils.delimit(hiscore.current), class: "data diff #{if hiscore.current > 0, do: "positive"}")
        ]
      end
    end
  end

  defp hiscore_value(hiscore, skill) do
    hiscore.value
    |> trunc()
    |> Utils.delimit()
  end

  defp hiscore_alt_value(hiscore, skill) do
    hiscore.alt_value
    |> trunc()
    |> Utils.delimit()
    |> Kernel.<> if skill == "ehp", do: " xp", else: " EHP"
  end

  def hiscore_size_navs(conn, skill, page_size) do
    for size <- @default_sizes do
      content_tag(
        :a,
        size,
        href: hiscore_path(conn, :index, skill: skill, page_size: size),
        class: (if size == page_size, do: "nav-link disabled", else: "nav-link")
      )
    end
  end
end
