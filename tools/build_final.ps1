$ErrorActionPreference = 'Stop'
$scratch = "C:\Users\okolo\AppData\Local\Temp\claude\C--Program-Files--x86--Steam-steamapps-common-Europa-Universalis-V\3bda4f82-c64b-4f39-8a87-f75b557a77f7\scratchpad"

# ============ 1. assemble final lua ============
$headerLua = @'
-------------------------------------------------------------------------
-- Unlimited Mercenaries (player only)
-- For every faction with a mercenary pool mechanic (Book of Grudges,
-- Malakai adventures, Waaagh bands, Monster Pen, Imperial Supply,
-- Flesh Lab, daemonic summoning, ogre camps, monstrous arcanum, ...):
--   * pool cap per unit raised to 30 (or vanilla cap if higher)
--   * stock refilled to cap on every load
--   * +1/turn native replenishment, +2/turn scripted top-up
-- Affects HUMAN factions only. AI is untouched.
--
-- Data below is generated from the game's own db (mercenary_pools,
-- mercenary_pool_to_groups_junctions, mercenary_unit_groups,
-- faction_to_mercenary_set_junctions). Pool/unit API call signature
-- copied from CA scripts (wh2_twa03_rakarth.lua).
-------------------------------------------------------------------------

local TOP_UP_PER_TURN = 2
local REPLEN_CHANCE = 100
local REPLEN_PER_TURN = 1
local STOCK_ON_LOAD = 30

'@

$runtimeLua = @'

-- caps bundle: applied to the player's faction only, vanilla pattern copied
-- from wh3_campaign_bonus_values.lua (ogr ally trade income)
local function apply_cap_bundle(faction)
	local ok = pcall(function()
		local bundle = cm:create_new_custom_effect_bundle("wh3_main_tech_effect_ogr_ally_trade_bonus")
		bundle:add_effect("wh3_main_effect_ogr_mercenary_cap_mod_1", "faction_to_force_own", 17)
		bundle:add_effect("wh2_dlc15_effect_unit_cap_mistwalkers_melee", "faction_to_faction_own", 17)
		bundle:add_effect("wh2_dlc15_effect_unit_cap_mistwalkers_melee_knights", "faction_to_faction_own", 17)
		bundle:add_effect("wh2_dlc15_effect_unit_cap_mistwalkers_tier1", "faction_to_faction_own", 17)
		bundle:add_effect("wh2_dlc15_effect_unit_cap_mistwalkers_tier2", "faction_to_faction_own", 17)
		bundle:set_duration(0)
		if faction:has_effect_bundle(bundle:key()) then
			cm:remove_effect_bundle(bundle:key(), faction:name())
		end
		cm:apply_custom_effect_bundle_to_faction(bundle, faction)
	end)
	if not ok then
		out("unlimited_mercenaries: cap bundle failed")
	end
end

local function eligible_pools(faction)
	local pools = {}
	local fname = faction:name()
	local sub = faction:subculture()
	for pool, t in pairs(pool_factions) do
		if t[fname] then pools[pool] = true end
	end
	for pool, t in pairs(pool_subcultures) do
		if t[sub] then pools[pool] = true end
	end
	return pools
end

local function setup_faction(faction)
	if faction:is_null_interface() or not faction:is_human() then return end
	apply_cap_bundle(faction)
	local pools = eligible_pools(faction)
	local fname = faction:name()
	for i = 1, #entries do
		local e = entries[i]
		if pools[e.p] then
			-- register under the pool's OWN recruitment source: hire costs are
			-- derived from (unit, source), so vanilla prices are kept. Entries
			-- registered here (on load, before vanilla scripts grant units)
			-- carry our cap; units granted by vanilla before the mod first ran
			-- keep their vanilla cap but still get the stock top-up.
			pcall(function()
				cm:add_unit_to_faction_mercenary_pool(
					faction, e.u, pool_source[e.p] or "",
					STOCK_ON_LOAD, REPLEN_CHANCE, e.m, REPLEN_PER_TURN,
					"", "", "", true, e.g)
			end)
			-- lift scripted unlock conditions (fealty/tech/building locks)
			pcall(function()
				cm:remove_event_restricted_unit_record_for_faction(e.u, fname)
			end)
		end
	end
end

local function top_up_faction(faction)
	if faction:is_null_interface() or not faction:is_human() then return end
	local pools = eligible_pools(faction)
	local cqi = faction:command_queue_index()
	local fname = faction:name()
	for i = 1, #entries do
		local e = entries[i]
		if pools[e.p] then
			pcall(function()
				cm:add_units_to_faction_mercenary_pool(cqi, e.u, TOP_UP_PER_TURN)
			end)
			-- vanilla scripts may re-lock units on their own events; lift again
			pcall(function()
				cm:remove_event_restricted_unit_record_for_faction(e.u, fname)
			end)
		end
	end
end

cm:add_first_tick_callback(
	function()
		local humans = cm:get_human_factions()
		for i = 1, #humans do
			local faction = cm:get_faction(humans[i])
			if faction then setup_faction(faction) end
		end

		core:add_listener(
			"unlimited_mercs_turn_start",
			"FactionTurnStart",
			function(context)
				return context:faction():is_human()
			end,
			function(context)
				top_up_faction(context:faction())
			end,
			true
		)
	end
)
'@

$dataLua = [IO.File]::ReadAllText("$scratch\generated_data.lua")
$finalLua = $headerLua + $dataLua + $runtimeLua
[IO.File]::WriteAllText("$scratch\unlimited_mercenaries.lua", $finalLua)
Write-Host "lua assembled: $($finalLua.Length) chars"

# ============ 2. db additions (army cap effect for merc unit sets) ============
function New-CaString([string]$s) {
    $b = [Text.Encoding]::UTF8.GetBytes($s)
    return ,([BitConverter]::GetBytes([uint16]$b.Length) + $b)
}
function New-TableHeader([int]$rowCount) {
    $guid = [Guid]::NewGuid().ToString()
    return ,([byte[]]@(0xfd,0xfe,0xfc,0xff) + [BitConverter]::GetBytes([uint16]$guid.Length) + [Text.Encoding]::Unicode.GetBytes($guid) + [byte[]]@(1) + [BitConverter]::GetBytes([uint32]$rowCount))
}

# bind the army-cap bonus to the vanilla "all_units" set: covers every race
$capSets = @('all_units')
$capBonuses = @('military_force_mercenary_cap_mod','faction_mercenary_cap_mod')
Write-Host "army-cap unit sets: $($capSets.Count)"; $capSets | ForEach-Object { Write-Host "  $_" }

$junction = New-TableHeader ($capSets.Count * $capBonuses.Count)
foreach ($set in $capSets) {
    foreach ($bonus in $capBonuses) {
        $junction += New-CaString $bonus
        $junction += New-CaString 'wh3_main_effect_ogr_mercenary_cap_mod_1'
        $junction += New-CaString $set
    }
}

# per-unit recruitment caps (bonus value "unit_cap") for capped regular-recruit
# units like Eltharion's Mistwalkers: bind unit_cap to our carrier effect
$unitCapUnits = @(
    'wh2_dlc15_hef_inf_mistwalkers_faithbearers_0',
    'wh2_dlc15_hef_inf_mistwalkers_griffon_knights_0',
    'wh2_dlc15_hef_inf_mistwalkers_sentinels_0',
    'wh2_dlc15_hef_inf_mistwalkers_skyhawks_0',
    'wh2_dlc15_hef_inf_mistwalkers_spireguard_0'
)
# validate vanilla layout: rows = [bonus][effect][unit], must land on EOF
$ur = [IO.File]::ReadAllBytes("$scratch\decompressed\db__effect_bonus_value_unit_record_junctions_tables__data__")
$glen = [BitConverter]::ToUInt16($ur,4); $upos = 6 + $glen*2
if ($ur[$upos] -eq 0xfc) { $upos += 8 }
$upos++
$ucount = [BitConverter]::ToUInt32($ur,$upos); $upos += 4
for ($i=0; $i -lt $ucount; $i++) { for ($j=0; $j -lt 3; $j++) { $len=[BitConverter]::ToUInt16($ur,$upos); $upos += 2 + $len } }
if ($upos -ne $ur.Length) { throw "unit_record junction layout mismatch: $upos vs $($ur.Length)" }
Write-Host "unit_record junction layout validated ($ucount rows)"
$unitCapJunction = New-TableHeader $unitCapUnits.Count
foreach ($u in $unitCapUnits) {
    $unitCapJunction += New-CaString 'unit_cap'
    $unitCapJunction += New-CaString 'wh3_main_effect_ogr_mercenary_cap_mod_1'
    $unitCapJunction += New-CaString $u
}

$hrows = @()
foreach ($diff in @(-1,0,1,2,3)) {
    $hrows += ,@($diff, 'wh3_main_effect_ogr_mercenary_cap_mod_1', 'faction_to_force_own', [single]17.0)
    $hrows += ,@($diff, 'wh3_main_effect_ogr_mercenary_cap_mod_1', 'faction_to_faction_own', [single]17.0)
    # vanilla Yvresse defense cap effects, granted directly (proven carriers)
    $hrows += ,@($diff, 'wh2_dlc15_effect_unit_cap_mistwalkers_melee', 'faction_to_faction_own', [single]17.0)
    $hrows += ,@($diff, 'wh2_dlc15_effect_unit_cap_mistwalkers_melee_knights', 'faction_to_faction_own', [single]17.0)
    $hrows += ,@($diff, 'wh2_dlc15_effect_unit_cap_mistwalkers_tier1', 'faction_to_faction_own', [single]17.0)
    $hrows += ,@($diff, 'wh2_dlc15_effect_unit_cap_mistwalkers_tier2', 'faction_to_faction_own', [single]17.0)
}
$handicap = New-TableHeader $hrows.Count
foreach ($r in $hrows) {
    $handicap += [BitConverter]::GetBytes([int32]$r[0]) + [byte[]]@(0)
    $handicap += New-CaString $r[1]
    $handicap += New-CaString $r[2]
    $handicap += [BitConverter]::GetBytes([single]$r[3]) + [byte[]]@(0)
}

# ============ 3. build the single mod pack ============
$files = @(
    @{ Path = "db\campaign_difficulty_handicap_effects_tables\!unlimited_mercs"; Data = $handicap },
    @{ Path = "db\effect_bonus_value_ids_unit_sets_tables\!unlimited_mercs"; Data = $junction },
    @{ Path = "db\effect_bonus_value_unit_record_junctions_tables\!unlimited_mercs"; Data = $unitCapJunction },
    @{ Path = "script\campaign\mod\unlimited_mercenaries.lua"; Data = [Text.Encoding]::UTF8.GetBytes($finalLua) }
)
# launcher thumbnail: png named after the pack, in the pack root
$previewPath = "C:\Users\okolo\Downloads\unlimited-mercenaries\preview.png"
if (Test-Path $previewPath) {
    $files += @{ Path = "unlimited_mercenaries.png"; Data = [IO.File]::ReadAllBytes($previewPath) }
}
$index = @(); $data = @()
foreach ($file in $files) {
    $nameBytes = [Text.Encoding]::ASCII.GetBytes($file.Path) + [byte]0
    $index += [BitConverter]::GetBytes([uint32]$file.Data.Length) + [byte[]]@(0) + $nameBytes
    $data += $file.Data
}
$header = [Text.Encoding]::ASCII.GetBytes("PFH5") + [BitConverter]::GetBytes([uint32]3) + [BitConverter]::GetBytes([uint32]0) + [BitConverter]::GetBytes([uint32]0) + [BitConverter]::GetBytes([uint32]$files.Count) + [BitConverter]::GetBytes([uint32]$index.Length) + [BitConverter]::GetBytes([uint32]0x7FFFFFFF)
$pack = $header + $index + $data
[IO.File]::WriteAllBytes("$scratch\unlimited_mercenaries.pack", $pack)
Write-Host "pack built: $($pack.Length) bytes"

# ============ 4. install & switch registrations ============
$dataDir = "C:\Program Files (x86)\Steam\steamapps\common\Total War WARHAMMER III\data"
Copy-Item "$scratch\unlimited_mercenaries.pack" "$dataDir\unlimited_mercenaries.pack" -Force
Remove-Item "$dataDir\malakai_unlimited_mercs.pack" -Force -ErrorAction SilentlyContinue
Remove-Item "$dataDir\claude_dwf_mercs_db.pack" -Force -ErrorAction SilentlyContinue
Write-Host "installed unlimited_mercenaries.pack, removed old packs"

$um = "C:\Program Files (x86)\Steam\steamapps\common\Total War WARHAMMER III\used_mods.txt"
$content = Get-Content $um -Raw
$content = ($content -split "`r?`n" | Where-Object { $_ -notmatch 'claude_dwf_mercs_db|malakai_unlimited_mercs' }) -join "`r`n"
if ($content -notmatch 'unlimited_mercenaries') { $content = $content.TrimEnd() + "`r`nmod `"unlimited_mercenaries.pack`";`r`n" }
[IO.File]::WriteAllText($um, $content, [Text.Encoding]::ASCII)
Write-Host "used_mods.txt updated"

$md = "$env:APPDATA\The Creative Assembly\Launcher\20190104-moddata.dat"
$json = Get-Content $md -Raw
$json = $json -replace '\{"uuid":"claude_dwf_mercs_db\.pack".*?\},?', ''
if ($json -notmatch 'unlimited_mercenaries') {
    $entry = '{"uuid":"unlimited_mercenaries.pack","order":0,"active":true,"game":"warhammer3","packfile":"C:/Program Files (x86)/Steam/steamapps/common/Total War WARHAMMER III/data/unlimited_mercenaries.pack","name":"Unlimited Mercenaries","short":"Player-only mercenary pool caps and replenishment","category":"","owned":true}'
    $json = $json -replace '^\[', "[$entry,"
}
$json = $json -replace ',\s*,', ','
[IO.File]::WriteAllText($md, $json, (New-Object Text.UTF8Encoding($false)))
Write-Host "moddata.dat updated"
