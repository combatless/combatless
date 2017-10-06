alias Combatless.Repo
alias Combatless.Datapoints.Skill
alias Combatless.Records.TimePeriod

Repo.insert!(%Skill{slug: "overall", name: "Overall"})
Repo.insert!(%Skill{slug: "attack", name: "Attack"})
Repo.insert!(%Skill{slug: "defence", name: "Defence"})
Repo.insert!(%Skill{slug: "strength", name: "Strength"})
Repo.insert!(%Skill{slug: "hitpoints", name: "Hitpoints"})
Repo.insert!(%Skill{slug: "ranged", name: "Ranged"})
Repo.insert!(%Skill{slug: "prayer", name: "Prayer"})
Repo.insert!(%Skill{slug: "magic", name: "Magic"})
Repo.insert!(%Skill{slug: "cooking", name: "Cooking"})
Repo.insert!(%Skill{slug: "woodcutting", name: "Woodcutting"})
Repo.insert!(%Skill{slug: "fletching", name: "Fletching"})
Repo.insert!(%Skill{slug: "fishing", name: "Fishing"})
Repo.insert!(%Skill{slug: "firemaking", name: "Firemaking"})
Repo.insert!(%Skill{slug: "crafting", name: "Crafting"})
Repo.insert!(%Skill{slug: "smithing", name: "Smithing"})
Repo.insert!(%Skill{slug: "mining", name: "Mining"})
Repo.insert!(%Skill{slug: "herblore", name: "Herblore"})
Repo.insert!(%Skill{slug: "agility", name: "Agility"})
Repo.insert!(%Skill{slug: "thieving", name: "Thieving"})
Repo.insert!(%Skill{slug: "slayer", name: "Slayer"})
Repo.insert!(%Skill{slug: "farming", name: "Farming"})
Repo.insert!(%Skill{slug: "runecraft", name: "Runecraft"})
Repo.insert!(%Skill{slug: "hunter", name: "Hunter"})
Repo.insert!(%Skill{slug: "construction", name: "Construction"})
Repo.insert!(%Skill{slug: "ehp", name: "EHP"})

Repo.insert!(%TimePeriod{slug: "log", name: "6 Hours"})
Repo.insert!(%TimePeriod{slug: "day", name: "Day"})
Repo.insert!(%TimePeriod{slug: "week", name: "Week"})
Repo.insert!(%TimePeriod{slug: "month", name: "Month"})
Repo.insert!(%TimePeriod{slug: "year", name: "Year"})
