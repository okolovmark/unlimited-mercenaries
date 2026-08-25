# Unlimited Mercenaries (Player Only)

[**Steam Workshop page**](https://steamcommunity.com/sharedfiles/filedetails/?id=3789976964)

A Total War: Warhammer III mod that removes the artificial scarcity from every
mercenary-pool mechanic in the game — for the human player only. AI factions
are untouched.

**Effects for the player's faction:**

* Every mercenary-pool unit gets an extra pool capacity of **+30**
  (shown on the unit card as vanilla cap + 30)
* Stock is refilled to cap on **every save load**
* Native replenishment: 100% chance, +1/turn, plus a scripted +2/turn top-up
* Scripted unlock conditions (fealty, technology, building, mission locks)
  are lifted — units are hireable from turn one
* Per-army mercenary limit raised by **+17** (e.g. 3 → 20, 5 → 22)
* Faction-wide caps of capped special units (Eltharion's Mistwalkers,
  Cathay's tiger warriors, etc.) raised by **+17**
* Hire costs are untouched: gold and special-resource prices stay vanilla

Safe to add to or remove from an existing campaign.

## Covered mechanics — 332 units across 23 pools

| Mechanic | Faction / LL | Pool | Units |
|---|---|---|---|
| Book of Grudges reconcilers | Dwarfs (all) | `wh3_dlc25_dwf_book_of_grudges_mercenary_pool` | 8 |
| Adventure units | Malakai Makaisson | `wh3_dlc25_dwf_malakai_feature_mercenary_pool` | 8 |
| Waaagh! bands | Greenskins | `wh2_dlc15_grn_waaagh_pool` | 6 |
| Elector Counts units | Empire | `wh2_dlc13_emp_elector_counts_merc_pool` (+`_volkmar`, `_non_replenish`) | 13×3 |
| Imperial Supply | Markus Wulfhart | `wh2_dlc13_emp_imperial_supply_pool` | 18 |
| Amethyst units | Elspeth von Draken | `wh3_dlc25_emp_amethyst_unit_pool` | 4 |
| State troops locks | Elspeth / Gelt | (unlock records lifted) | — |
| Blessed Spawnings | Lizardmen (all, incl. Cult of Sotek rites) | `wh2_main_lzd_spawnings_pool` | 21 |
| Monster Pen | Rakarth | `wh2_twa03_def_rakarth_merc_pool` | 17 |
| Flesh Lab | Throt the Unclean | `wh2_dlc16_skv_throt_flesh_lab_pool` | 8 |
| Forbidden Workshop prototypes | Ikit Claw | `wh2_dlc12_skv_tech_lab_pool` | 5 |
| Doppelganger triads | Snikch (Clan Eshin) | `wh2_dlc14_skv_units_of_renown_doppelgang_pool` | 1 |
| Mistwalkers (Defense of Yvresse) | Eltharion | regular recruitment — unit caps +17 (up to +34 for units in two vanilla cap groups) | 5 |
| Daemonic summoning | Warriors of Chaos | `wh3_dlc20_chs_faction_pool`, `wh3_dlc20_coc_faction_pool` | 40×2 |
| Daemonic summoning | Be'lakor | `wh3_main_belakor_faction_pool` | 44 |
| Nurgle unit pools | Nurgle | `wh3_main_nur_units` | 32 |
| Daemonic attraction | Slaanesh (The Dechala update) | `wh3_dlc27_sla_daemonic_attraction` | 7 |
| Ogre camps | Ogre Kingdoms | `wh3_main_ogr_merc_pool` | 2 |
| Monstrous Arcanum | Norsca | `wh3_dlc27_nor_monstrous_arcanum` | 12 |
| Shang-Yang support | Cathay (Bhashiva) | `wh3_cp1_cth_bhashiva_shang_yang_support` | 12 |
| Zealous Conscription | Kislev | `wh3_main_ksl_zealous_conscription` | 3 |

### Intentionally NOT covered

* **Regiments of Renown** (all races) — unique named regiments, cap 1 by design
* **Raise-dead pools** (Vampire Counts, Vampire Coast, Drycha, Chaos province
  pool) — province-bound mechanics; the faction-level API does not reach them
* **Tamurkhan's chieftains** — story companions; touching them can break the
  narrative mechanic
* Units that are already unlimited in vanilla (cap −1, e.g. camp Monstrous
  Arcanum monsters) are left as-is

## Install

Drop `dist/unlimited_mercenaries.pack` into
`Total War WARHAMMER III/data/` and enable "Unlimited Mercenaries" in the
launcher's mod manager.

## How it works (the interesting part)

Built without the Assembly Kit or RPFM — a small PowerShell toolchain reads
the game's own data and generates the mod:

1. **Pack file reader** (`tools/zstd_tools.ps1`) — parses the PFH5 pack format
   directly and decompresses the zstd-packed db tables via `libzstd.dll`
   P/Invoked from PowerShell.
2. **Schema reverse-engineering** — the mercenary db tables
   (`mercenary_pools`, `mercenary_pool_to_groups_junctions`,
   `mercenary_unit_groups`, `faction_to_mercenary_set_junctions`,
   `campaign_difficulty_handicap_effects`,
   `effect_bonus_value_ids_unit_sets`) were decoded byte-by-byte; every parse
   is validated by requiring it to land exactly on EOF.
3. **Code generation** (`tools/generate_lua.ps1`) — walks pool → group → unit
   junctions and emits Lua data tables with per-faction/per-subculture
   eligibility, so a faction is never given units it should not see.
4. **Runtime** (`src/unlimited_mercenaries.lua`) — key discoveries:
   * pool state (caps, stock) is snapshotted into the *savegame*, so db edits
     alone cannot change existing pools — the runtime re-registers entries
     through the same script API CA uses (`wh2_twa03_rakarth.lua`, signature
     copied verbatim);
   * pool entries are keyed by *(unit, recruitment source)* and are immutable
     once created — the mod registers its entries on load, *before* vanilla
     scripts grant units, under the pool's own source, so hire costs (which
     derive from unit + source) stay exactly vanilla;
   * scripted unit locks are `event restricted unit records` — lifted with
     the mirror API call.
5. **Caps** — the `military_force_mercenary_cap_mod` (per-army) and
   `faction_mercenary_cap_mod` (faction-wide) bonus values are bound to the
   vanilla `all_units` unit set via `effect_bonus_value_ids_unit_sets` rows,
   and the carrying effect is granted at every difficulty through
   `campaign_difficulty_handicap_effects` rows.
6. **Packaging** (`tools/build_final.ps1`) — writes the .pack byte-by-byte
   (PFH5 header, index, payload), mirroring the format of known-good
   Workshop mods.

## Build from source

```bash
powershell -File tools/generate_lua.ps1   # parse game db -> generated_data.lua
powershell -File tools/build_final.ps1    # assemble lua + db rows -> .pack
```

Requires the game installed (tables are read from `data/db.pack`) and any
`libzstd.dll` (the one shipped with Git for Windows works).

## Known quirks

* The per-army limit label shows the base value (e.g. "6/3") — the enforced
  limit includes the +17 bonus; the label is a UI template and cannot be
  fixed from a data mod.
* Units granted by vanilla scripts at the very moment a campaign is created
  (e.g. Elspeth's state troops, starter Blessed Spawnings) keep their vanilla
  pool cap — entries are immutable once created. Their stock is still topped
  up every turn.
* Unit cards can show *vanilla cap + 30* when both a vanilla and a mod entry
  exist for the same unit. Cosmetic.
* Character-level hire restrictions (some units need a high-level lord) are
  vanilla behaviour and are kept.

## Disclaimer

Not affiliated with Creative Assembly or Games Workshop. Single-player
convenience mod; unbalancing by design.
