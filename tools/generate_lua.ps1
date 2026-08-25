$ErrorActionPreference = 'Stop'
$scratch = "C:\Users\okolo\AppData\Local\Temp\claude\C--Program-Files--x86--Steam-steamapps-common-Europa-Universalis-V\3bda4f82-c64b-4f39-8a87-f75b557a77f7\scratchpad"
$dec = "$scratch\decompressed"

function Read-Str([byte[]]$b, [ref]$p) {
    $len = [BitConverter]::ToUInt16($b, $p.Value); $p.Value += 2
    $s = [Text.Encoding]::UTF8.GetString($b, $p.Value, $len); $p.Value += $len
    return $s
}
function Read-Opt([byte[]]$b, [ref]$p) {
    $flag = $b[$p.Value]; $p.Value += 1
    if ($flag -eq 1) { return (Read-Str $b $p) }
    return $null
}
function Skip-Header([byte[]]$b, [ref]$p) {
    if ($b[0] -eq 0xfd) { $glen = [BitConverter]::ToUInt16($b,4); $p.Value = 6 + $glen*2 }
    if ($b[$p.Value] -eq 0xfc) { $p.Value += 8 }
    $p.Value += 1
    $count = [BitConverter]::ToUInt32($b, $p.Value); $p.Value += 4
    return $count
}

# --- 1. mercenary_pools: pool -> source (optA if present else optB) ---
$b = [IO.File]::ReadAllBytes("$dec\db__mercenary_pools_tables__data__")
$p = [ref]0; $count = Skip-Header $b $p
$poolSource = @{}
for ($i=0; $i -lt $count; $i++) {
    $key = Read-Str $b $p
    $optA = Read-Opt $b $p
    $optB = Read-Opt $b $p
    if ($optA) { $poolSource[$key] = $optA } elseif ($optB) { $poolSource[$key] = $optB }
}
if ($p.Value -ne $b.Length) { throw "mercenary_pools parse mismatch: $($p.Value)/$($b.Length)" }
Write-Host "pools: $($poolSource.Count)"
# keep the source the user's save already uses for grudges
$poolSource['wh3_dlc25_dwf_book_of_grudges_mercenary_pool'] = 'dwarf_grudges_units'

# --- 2. pool_to_groups junction: group -> pool (+faction/subculture restriction) ---
$b = [IO.File]::ReadAllBytes("$dec\db__mercenary_pool_to_groups_junctions_tables__data__")
$junc = $null
foreach ($variant in @('A','B')) {
    $p = [ref]0; $count = Skip-Header $b $p
    $rows = New-Object System.Collections.Generic.List[object]
    $ok = $true
    try {
        for ($i=0; $i -lt $count; $i++) {
            $group = Read-Str $b $p
            $u32 = [BitConverter]::ToUInt32($b,$p.Value); $p.Value += 4
            $f4 = [BitConverter]::ToSingle($b,$p.Value); $p.Value += 4
            $pool = Read-Str $b $p
            $optA = Read-Opt $b $p
            $optB = Read-Opt $b $p
            if ($variant -eq 'B') { $p.Value += 1 }
            $rows.Add([PSCustomObject]@{Group=$group; Pool=$pool; OptA=$optA; OptB=$optB})
        }
    } catch { $ok = $false }
    if ($ok -and $p.Value -eq $b.Length) { $junc = $rows; Write-Host "pool_to_groups: variant $variant OK, $($rows.Count) rows"; break }
    Write-Host "pool_to_groups: variant $variant failed (pos $($p.Value)/$($b.Length))"
}
if (-not $junc) { throw "pool_to_groups: no variant matched" }

# --- 3. faction_to_mercenary_set junction: faction -> pool ---
$b = [IO.File]::ReadAllBytes("$dec\db__faction_to_mercenary_set_junctions_tables__data__")
$facPool = $null
foreach ($variant in @('lead_u8','none')) {
    $p = [ref]0; $count = Skip-Header $b $p
    $rows = New-Object System.Collections.Generic.List[object]
    $ok = $true
    try {
        for ($i=0; $i -lt $count; $i++) {
            if ($variant -eq 'lead_u8') { $p.Value += 1 }
            $fac = Read-Str $b $p
            $pool = Read-Str $b $p
            $rows.Add([PSCustomObject]@{Faction=$fac; Pool=$pool})
        }
    } catch { $ok = $false }
    if ($ok -and $p.Value -eq $b.Length) { $facPool = $rows; Write-Host "faction_to_set: variant $variant OK, $($rows.Count) rows"; break }
    Write-Host "faction_to_set: variant $variant failed (pos $($p.Value)/$($b.Length))"
}
if (-not $facPool) { throw "faction_to_set: no variant matched" }

# --- 4. province-bound pools (exclude) ---
$b = [IO.File]::ReadAllBytes("$dec\db__province_to_mercenary_set_junctions_tables__data__")
$p = [ref]0; $count = Skip-Header $b $p
$provincePools = @{}
for ($i=0; $i -lt $count; $i++) {
    $pool = Read-Str $b $p
    $prov = Read-Str $b $p
    $provincePools[$pool] = $true
}
if ($p.Value -ne $b.Length) { Write-Host "WARN province junction parse mismatch: $($p.Value)/$($b.Length) (layout guess [pool][province])" } else { Write-Host "province pools (excluded): $($provincePools.Count)" }

# --- 5. unit groups (group -> unit, vanilla max) ---
$groups = @{}
Import-Csv "$scratch\unit_groups.csv" | ForEach-Object { $groups[$_.Group] = $_ }
Write-Host "unit groups: $($groups.Count)"

# --- 6. assemble entries ---
$excludedSources = @('renown','raise_dead')
$entries = New-Object System.Collections.Generic.List[object]
$poolFactions = @{}
$poolSubcultures = @{}
foreach ($r in $facPool) {
    if (-not $poolFactions.ContainsKey($r.Pool)) { $poolFactions[$r.Pool] = @{} }
    $poolFactions[$r.Pool][$r.Faction] = $true
}
foreach ($j in $junc) {
    $src = $poolSource[$j.Pool]
    if (-not $src) { continue }
    if ($excludedSources -contains $src) { continue }
    if ($provincePools.ContainsKey($j.Pool)) { continue }
    $g = $groups[$j.Group]
    if (-not $g) { continue }
    $vmax = [int64]$g.Max
    if ($vmax -eq 4294967295 -or $vmax -eq 0) { continue }   # already unlimited / disabled
    # restrictions: OptA/OptB may be faction key or subculture key
    foreach ($opt in @($j.OptA, $j.OptB)) {
        if (-not $opt) { continue }
        if (-not $poolSubcultures.ContainsKey($j.Pool)) { $poolSubcultures[$j.Pool] = @{} }
        if ($opt -match '_sc_') { $poolSubcultures[$j.Pool][$opt] = $true }
        else { if (-not $poolFactions.ContainsKey($j.Pool)) { $poolFactions[$j.Pool] = @{} }; $poolFactions[$j.Pool][$opt] = $true }
    }
    $max = [Math]::Max(30, $vmax)
    $entries.Add([PSCustomObject]@{Unit=$g.Unit; Group=$j.Group; Pool=$j.Pool; Max=$max})
}
# manual additions: script-granted pools with no db junctions (Ikit's workshop,
# Eltharion's mistwalkers, Snikch's doppelganger triads). Not lore-unique units.
$manualEntries = @(
    @{Pool='wh2_dlc12_skv_tech_lab_pool'; Units=@(
        'wh2_dlc12_skv_art_warplock_jezzails_ror_tech_lab_0',
        'wh2_dlc12_skv_inf_ratling_gun_ror_tech_lab_0',
        'wh2_dlc12_skv_inf_warpfire_thrower_ror_tech_lab_0',
        'wh2_dlc12_skv_veh_doom_flayer_ror_tech_lab_0',
        'wh2_dlc12_skv_veh_doomwheel_ror_tech_lab_0')},
    @{Pool='wh2_dlc14_skv_units_of_renown_doppelgang_pool'; Units=@(
        'wh2_dlc14_skv_inf_eshin_triads_ror_summoned_0')},
    @{Pool='wh3_main_ksl_zealous_conscription'; Units=@(
        'wh3_dlc24_ksl_inf_kislevite_warriors',
        'wh3_main_ksl_inf_kossars_0',
        'wh3_main_ksl_inf_kossars_1')}
)
foreach ($m in $manualEntries) {
    foreach ($u in $m.Units) {
        $entries.Add([PSCustomObject]@{Unit=$u; Group=$u; Pool=$m.Pool; Max=30})
    }
}
if (-not $poolFactions.ContainsKey('wh2_dlc14_skv_units_of_renown_doppelgang_pool')) { $poolFactions['wh2_dlc14_skv_units_of_renown_doppelgang_pool'] = @{} }
$poolFactions['wh2_dlc14_skv_units_of_renown_doppelgang_pool']['wh2_dlc09_skv_clan_eshin'] = $true
if (-not $poolSubcultures.ContainsKey('wh3_main_ksl_zealous_conscription')) { $poolSubcultures['wh3_main_ksl_zealous_conscription'] = @{} }
$poolSubcultures['wh3_main_ksl_zealous_conscription']['wh3_main_sc_ksl_kislev'] = $true

# dedupe by unit+pool
$entries = $entries | Sort-Object Unit, Pool -Unique
Write-Host "entries: $($entries.Count)"
$usedPools = $entries | Select-Object -ExpandProperty Pool | Sort-Object -Unique
Write-Host "pools covered: $($usedPools.Count)"
$usedPools | ForEach-Object { Write-Host ("  {0} (source: {1})" -f $_, $poolSource[$_]) }

# --- 7. emit lua data module ---
$sb = New-Object System.Text.StringBuilder
[void]$sb.AppendLine('-- generated data: mercenary pool entries per pool, with eligibility links')
[void]$sb.AppendLine('local entries = {')
foreach ($e in $entries) {
    [void]$sb.AppendLine(('	{{ u = "{0}", g = "{1}", p = "{2}", m = {3} }},' -f $e.Unit, $e.Group, $e.Pool, $e.Max))
}
[void]$sb.AppendLine('}')
[void]$sb.AppendLine('local pool_source = {')
foreach ($k in $usedPools) { [void]$sb.AppendLine(('	["{0}"] = "{1}",' -f $k, $poolSource[$k])) }
[void]$sb.AppendLine('}')
[void]$sb.AppendLine('local pool_factions = {')
foreach ($k in $usedPools) {
    if ($poolFactions.ContainsKey($k) -and $poolFactions[$k].Count -gt 0) {
        $list = ($poolFactions[$k].Keys | Sort-Object | ForEach-Object { '["{0}"]=true' -f $_ }) -join ', '
        [void]$sb.AppendLine(('	["{0}"] = {{ {1} }},' -f $k, $list))
    }
}
[void]$sb.AppendLine('}')
[void]$sb.AppendLine('local pool_subcultures = {')
foreach ($k in $usedPools) {
    if ($poolSubcultures.ContainsKey($k) -and $poolSubcultures[$k].Count -gt 0) {
        $list = ($poolSubcultures[$k].Keys | Sort-Object | ForEach-Object { '["{0}"]=true' -f $_ }) -join ', '
        [void]$sb.AppendLine(('	["{0}"] = {{ {1} }},' -f $k, $list))
    }
}
[void]$sb.AppendLine('}')
[IO.File]::WriteAllText("$scratch\generated_data.lua", $sb.ToString())
Write-Host "data written to generated_data.lua ($($sb.Length) chars)"
