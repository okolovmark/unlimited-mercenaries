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
-- generated data: mercenary pool entries per pool, with eligibility links
local entries = {
	{ u = "wh_dlc01_chs_mon_dragon_ogre_shaggoth", g = "wh_dlc01_chs_mon_dragon_ogre_shaggoth_warriors_faction_pool", p = "wh3_dlc20_chs_faction_pool", m = 30 },
	{ u = "wh_dlc01_chs_mon_dragon_ogre_shaggoth", g = "wh_dlc01_chs_mon_dragon_ogre_shaggoth_warriors_faction_pool", p = "wh3_dlc20_coc_faction_pool", m = 30 },
	{ u = "wh_dlc01_chs_mon_dragon_ogre_shaggoth", g = "wh_dlc01_chs_mon_dragon_ogre_shaggoth_warriors_faction_pool", p = "wh3_main_belakor_faction_pool", m = 30 },
	{ u = "wh_dlc06_grn_inf_squig_explosive_0", g = "wh_dlc06_grn_inf_squig_explosive_0", p = "wh2_dlc15_grn_waaagh_pool", m = 30 },
	{ u = "wh_dlc08_nor_cav_marauder_horsemasters_0", g = "wh3_dlc27_nor_cav_marauder_horsemasters_0", p = "wh3_dlc27_nor_monstrous_arcanum", m = 30 },
	{ u = "wh_dlc08_nor_inf_marauder_champions_0", g = "wh3_dlc27_nor_inf_marauder_champions_0", p = "wh3_dlc27_nor_monstrous_arcanum", m = 30 },
	{ u = "wh_dlc08_nor_inf_marauder_hunters_1", g = "wh3_dlc27_nor_inf_marauder_hunters_1", p = "wh3_dlc27_nor_monstrous_arcanum", m = 30 },
	{ u = "wh_dlc15_grn_mon_arachnarok_spider_waaagh_0", g = "wh_dlc15_grn_mon_arachnarok_spider_waaagh_0", p = "wh2_dlc15_grn_waaagh_pool", m = 30 },
	{ u = "wh_main_chs_art_hellcannon", g = "wh_main_chs_art_hellcannon_warriors_faction_pool", p = "wh3_dlc20_chs_faction_pool", m = 30 },
	{ u = "wh_main_chs_art_hellcannon", g = "wh_main_chs_art_hellcannon_warriors_faction_pool", p = "wh3_dlc20_coc_faction_pool", m = 30 },
	{ u = "wh_main_chs_art_hellcannon", g = "wh_main_chs_art_hellcannon_warriors_faction_pool", p = "wh3_main_belakor_faction_pool", m = 30 },
	{ u = "wh_main_chs_mon_chaos_warhounds_1", g = "wh_main_chs_mon_chaos_warhounds_1", p = "wh3_main_nur_units", m = 30 },
	{ u = "wh_main_dwf_art_cannon_malakai", g = "wh3_dlc25_dwf_malakai_feature_cannons", p = "wh3_dlc25_dwf_malakai_feature_mercenary_pool", m = 30 },
	{ u = "wh_main_dwf_art_flame_cannon_grudge_reward", g = "wh3_dlc25_dwf_grudges_flame_cannon", p = "wh3_dlc25_dwf_book_of_grudges_mercenary_pool", m = 30 },
	{ u = "wh_main_dwf_art_flame_cannon_malakai", g = "wh3_dlc25_dwf_malakai_feature_flame_cannons", p = "wh3_dlc25_dwf_malakai_feature_mercenary_pool", m = 30 },
	{ u = "wh_main_dwf_art_organ_gun_malakai", g = "wh3_dlc25_dwf_malakai_feature_organ_guns", p = "wh3_dlc25_dwf_malakai_feature_mercenary_pool", m = 30 },
	{ u = "wh_main_dwf_inf_hammerers_grudge_reward", g = "wh3_dlc25_dwf_grudges_hammerers", p = "wh3_dlc25_dwf_book_of_grudges_mercenary_pool", m = 30 },
	{ u = "wh_main_dwf_inf_irondrakes_0_grudge_reward", g = "wh3_dlc25_dwf_grudges_irondrakes_0", p = "wh3_dlc25_dwf_book_of_grudges_mercenary_pool", m = 30 },
	{ u = "wh_main_dwf_inf_longbeards_1_grudge_reward", g = "wh3_dlc25_dwf_grudges_longbeards_1", p = "wh3_dlc25_dwf_book_of_grudges_mercenary_pool", m = 30 },
	{ u = "wh_main_dwf_inf_quarrellers_1_grudge_reward", g = "wh3_dlc25_dwf_grudges_quarrellers_1", p = "wh3_dlc25_dwf_book_of_grudges_mercenary_pool", m = 30 },
	{ u = "wh_main_dwf_inf_slayers_grudge_reward", g = "wh3_dlc25_dwf_grudges_slayers", p = "wh3_dlc25_dwf_book_of_grudges_mercenary_pool", m = 30 },
	{ u = "wh_main_dwf_veh_gyrobomber_malakai", g = "wh3_dlc25_dwf_malakai_feature_gyrobomber", p = "wh3_dlc25_dwf_malakai_feature_mercenary_pool", m = 30 },
	{ u = "wh_main_dwf_veh_gyrocopter_0_malakai", g = "wh3_dlc25_dwf_malakai_feature_gyrocopter_0", p = "wh3_dlc25_dwf_malakai_feature_mercenary_pool", m = 30 },
	{ u = "wh_main_dwf_veh_gyrocopter_1_grudge_reward", g = "wh3_dlc25_dwf_grudges_gyrocopter_1", p = "wh3_dlc25_dwf_book_of_grudges_mercenary_pool", m = 30 },
	{ u = "wh_main_dwf_veh_gyrocopter_1_malakai", g = "wh3_dlc25_dwf_malakai_feature_gyrocopter_1", p = "wh3_dlc25_dwf_malakai_feature_mercenary_pool", m = 30 },
	{ u = "wh_twa03_def_inf_squig_explosive_0", g = "wh2_twa03_squig_explosive", p = "wh2_twa03_def_rakarth_merc_pool", m = 30 },
	{ u = "wh2_dlc10_def_mon_feral_manticore_0", g = "wh2_twa03_mon_feral_manticore_0", p = "wh2_twa03_def_rakarth_merc_pool", m = 30 },
	{ u = "wh2_dlc10_def_mon_kharibdyss_0", g = "wh2_twa03_mon_kharibdyss_0", p = "wh2_twa03_def_rakarth_merc_pool", m = 30 },
	{ u = "wh2_dlc12_lzd_cav_ripperdactyl_riders_0_blessed", g = "wh2_dlc12_lzd_cav_ripperdactyl_riders_0_blessed", p = "wh2_main_lzd_spawnings_pool", m = 30 },
	{ u = "wh2_dlc12_lzd_mon_ancient_salamander_0_blessed", g = "wh2_dlc12_lzd_mon_ancient_salamander_0_blessed", p = "wh2_main_lzd_spawnings_pool", m = 30 },
	{ u = "wh2_dlc12_lzd_mon_salamander_pack_0_blessed", g = "wh2_dlc12_lzd_mon_salamander_pack_0_blessed", p = "wh2_main_lzd_spawnings_pool", m = 30 },
	{ u = "wh2_dlc12_skv_art_warplock_jezzails_ror_tech_lab_0", g = "wh2_dlc12_skv_art_warplock_jezzails_ror_tech_lab_0", p = "wh2_dlc12_skv_tech_lab_pool", m = 30 },
	{ u = "wh2_dlc12_skv_inf_ratling_gun_ror_tech_lab_0", g = "wh2_dlc12_skv_inf_ratling_gun_ror_tech_lab_0", p = "wh2_dlc12_skv_tech_lab_pool", m = 30 },
	{ u = "wh2_dlc12_skv_inf_warpfire_thrower_ror_tech_lab_0", g = "wh2_dlc12_skv_inf_warpfire_thrower_ror_tech_lab_0", p = "wh2_dlc12_skv_tech_lab_pool", m = 30 },
	{ u = "wh2_dlc12_skv_veh_doom_flayer_ror_tech_lab_0", g = "wh2_dlc12_skv_veh_doom_flayer_ror_tech_lab_0", p = "wh2_dlc12_skv_tech_lab_pool", m = 30 },
	{ u = "wh2_dlc12_skv_veh_doomwheel_ror_tech_lab_0", g = "wh2_dlc12_skv_veh_doomwheel_ror_tech_lab_0", p = "wh2_dlc12_skv_tech_lab_pool", m = 30 },
	{ u = "wh2_dlc13_emp_art_great_cannon_imperial_supply", g = "wh2_dlc13_emp_art_great_cannon_imperial_supply", p = "wh2_dlc13_emp_imperial_supply_pool", m = 30 },
	{ u = "wh2_dlc13_emp_art_helblaster_volley_gun_imperial_supply", g = "wh2_dlc13_emp_art_helblaster_volley_gun_imperial_supply", p = "wh2_dlc13_emp_imperial_supply_pool", m = 30 },
	{ u = "wh2_dlc13_emp_art_helstorm_rocket_battery_imperial_supply", g = "wh2_dlc13_emp_art_helstorm_rocket_battery_imperial_supply", p = "wh2_dlc13_emp_imperial_supply_pool", m = 30 },
	{ u = "wh2_dlc13_emp_art_mortar_ror_0", g = "wh2_dlc13_emp_art_mortar_ror_0", p = "wh2_dlc13_emp_elector_counts_merc_pool", m = 30 },
	{ u = "wh2_dlc13_emp_art_mortar_ror_0", g = "wh2_dlc13_emp_art_mortar_ror_0_non_replenish", p = "wh2_dlc13_emp_elector_counts_merc_pool_non_replenish", m = 30 },
	{ u = "wh2_dlc13_emp_art_mortar_ror_0", g = "wh2_dlc13_emp_art_mortar_ror_0", p = "wh2_dlc13_emp_elector_counts_merc_pool_volkmar", m = 30 },
	{ u = "wh2_dlc13_emp_cav_demigryph_knights_0_imperial_supply", g = "wh2_dlc13_emp_cav_demigryph_knights_0_imperial_supply", p = "wh2_dlc13_emp_imperial_supply_pool", m = 30 },
	{ u = "wh2_dlc13_emp_cav_demigryph_knights_1_imperial_supply", g = "wh2_dlc13_emp_cav_demigryph_knights_1_imperial_supply", p = "wh2_dlc13_emp_imperial_supply_pool", m = 30 },
	{ u = "wh2_dlc13_emp_cav_empire_knights_imperial_supply", g = "wh2_dlc13_emp_cav_empire_knights_imperial_supply", p = "wh2_dlc13_emp_imperial_supply_pool", m = 30 },
	{ u = "wh2_dlc13_emp_cav_empire_knights_ror_0", g = "wh2_dlc13_emp_cav_empire_knights_ror_0", p = "wh2_dlc13_emp_elector_counts_merc_pool", m = 30 },
	{ u = "wh2_dlc13_emp_cav_empire_knights_ror_0", g = "wh2_dlc13_emp_cav_empire_knights_ror_0_non_replenish", p = "wh2_dlc13_emp_elector_counts_merc_pool_non_replenish", m = 30 },
	{ u = "wh2_dlc13_emp_cav_empire_knights_ror_0", g = "wh2_dlc13_emp_cav_empire_knights_ror_0", p = "wh2_dlc13_emp_elector_counts_merc_pool_volkmar", m = 30 },
	{ u = "wh2_dlc13_emp_cav_empire_knights_ror_1", g = "wh2_dlc13_emp_cav_empire_knights_ror_1", p = "wh2_dlc13_emp_elector_counts_merc_pool", m = 30 },
	{ u = "wh2_dlc13_emp_cav_empire_knights_ror_1", g = "wh2_dlc13_emp_cav_empire_knights_ror_1_non_replenish", p = "wh2_dlc13_emp_elector_counts_merc_pool_non_replenish", m = 30 },
	{ u = "wh2_dlc13_emp_cav_empire_knights_ror_1", g = "wh2_dlc13_emp_cav_empire_knights_ror_1", p = "wh2_dlc13_emp_elector_counts_merc_pool_volkmar", m = 30 },
	{ u = "wh2_dlc13_emp_cav_empire_knights_ror_2", g = "wh2_dlc13_emp_cav_empire_knights_ror_2", p = "wh2_dlc13_emp_elector_counts_merc_pool", m = 30 },
	{ u = "wh2_dlc13_emp_cav_empire_knights_ror_2", g = "wh2_dlc13_emp_cav_empire_knights_ror_2_non_replenish", p = "wh2_dlc13_emp_elector_counts_merc_pool_non_replenish", m = 30 },
	{ u = "wh2_dlc13_emp_cav_empire_knights_ror_2", g = "wh2_dlc13_emp_cav_empire_knights_ror_2", p = "wh2_dlc13_emp_elector_counts_merc_pool_volkmar", m = 30 },
	{ u = "wh2_dlc13_emp_cav_outriders_1_imperial_supply", g = "wh2_dlc13_emp_cav_outriders_1_imperial_supply", p = "wh2_dlc13_emp_imperial_supply_pool", m = 30 },
	{ u = "wh2_dlc13_emp_cav_outriders_ror_0", g = "wh2_dlc13_emp_cav_outriders_ror_0", p = "wh2_dlc13_emp_elector_counts_merc_pool", m = 30 },
	{ u = "wh2_dlc13_emp_cav_outriders_ror_0", g = "wh2_dlc13_emp_cav_outriders_ror_0_non_replenish", p = "wh2_dlc13_emp_elector_counts_merc_pool_non_replenish", m = 30 },
	{ u = "wh2_dlc13_emp_cav_outriders_ror_0", g = "wh2_dlc13_emp_cav_outriders_ror_0", p = "wh2_dlc13_emp_elector_counts_merc_pool_volkmar", m = 30 },
	{ u = "wh2_dlc13_emp_cav_pistoliers_1_imperial_supply", g = "wh2_dlc13_emp_cav_pistoliers_1_imperial_supply", p = "wh2_dlc13_emp_imperial_supply_pool", m = 30 },
	{ u = "wh2_dlc13_emp_cav_pistoliers_ror_0", g = "wh2_dlc13_emp_cav_pistoliers_ror_0", p = "wh2_dlc13_emp_elector_counts_merc_pool", m = 30 },
	{ u = "wh2_dlc13_emp_cav_pistoliers_ror_0", g = "wh2_dlc13_emp_cav_pistoliers_ror_0_non_replenish", p = "wh2_dlc13_emp_elector_counts_merc_pool_non_replenish", m = 30 },
	{ u = "wh2_dlc13_emp_cav_pistoliers_ror_0", g = "wh2_dlc13_emp_cav_pistoliers_ror_0", p = "wh2_dlc13_emp_elector_counts_merc_pool_volkmar", m = 30 },
	{ u = "wh2_dlc13_emp_cav_reiksguard_imperial_supply", g = "wh2_dlc13_emp_cav_reiksguard_imperial_supply", p = "wh2_dlc13_emp_imperial_supply_pool", m = 30 },
	{ u = "wh2_dlc13_emp_inf_crossbowmen_ror_0", g = "wh2_dlc13_emp_inf_crossbowmen_ror_0", p = "wh2_dlc13_emp_elector_counts_merc_pool", m = 30 },
	{ u = "wh2_dlc13_emp_inf_crossbowmen_ror_0", g = "wh2_dlc13_emp_inf_crossbowmen_ror_0_non_replenish", p = "wh2_dlc13_emp_elector_counts_merc_pool_non_replenish", m = 30 },
	{ u = "wh2_dlc13_emp_inf_crossbowmen_ror_0", g = "wh2_dlc13_emp_inf_crossbowmen_ror_0", p = "wh2_dlc13_emp_elector_counts_merc_pool_volkmar", m = 30 },
	{ u = "wh2_dlc13_emp_inf_greatswords_imperial_supply", g = "wh2_dlc13_emp_inf_greatswords_imperial_supply", p = "wh2_dlc13_emp_imperial_supply_pool", m = 30 },
	{ u = "wh2_dlc13_emp_inf_greatswords_ror_0", g = "wh2_dlc13_emp_inf_greatswords_ror_0", p = "wh2_dlc13_emp_elector_counts_merc_pool", m = 30 },
	{ u = "wh2_dlc13_emp_inf_greatswords_ror_0", g = "wh2_dlc13_emp_inf_greatswords_ror_0_non_replenish", p = "wh2_dlc13_emp_elector_counts_merc_pool_non_replenish", m = 30 },
	{ u = "wh2_dlc13_emp_inf_greatswords_ror_0", g = "wh2_dlc13_emp_inf_greatswords_ror_0", p = "wh2_dlc13_emp_elector_counts_merc_pool_volkmar", m = 30 },
	{ u = "wh2_dlc13_emp_inf_halberdiers_imperial_supply", g = "wh2_dlc13_emp_inf_halberdiers_imperial_supply", p = "wh2_dlc13_emp_imperial_supply_pool", m = 30 },
	{ u = "wh2_dlc13_emp_inf_halberdiers_ror_0", g = "wh2_dlc13_emp_inf_halberdiers_ror_0", p = "wh2_dlc13_emp_elector_counts_merc_pool", m = 30 },
	{ u = "wh2_dlc13_emp_inf_halberdiers_ror_0", g = "wh2_dlc13_emp_inf_halberdiers_ror_0_non_replenish", p = "wh2_dlc13_emp_elector_counts_merc_pool_non_replenish", m = 30 },
	{ u = "wh2_dlc13_emp_inf_halberdiers_ror_0", g = "wh2_dlc13_emp_inf_halberdiers_ror_0", p = "wh2_dlc13_emp_elector_counts_merc_pool_volkmar", m = 30 },
	{ u = "wh2_dlc13_emp_inf_handgunners_imperial_supply", g = "wh2_dlc13_emp_inf_handgunners_imperial_supply", p = "wh2_dlc13_emp_imperial_supply_pool", m = 30 },
	{ u = "wh2_dlc13_emp_inf_handgunners_ror_0", g = "wh2_dlc13_emp_inf_handgunners_ror_0", p = "wh2_dlc13_emp_elector_counts_merc_pool", m = 30 },
	{ u = "wh2_dlc13_emp_inf_handgunners_ror_0", g = "wh2_dlc13_emp_inf_handgunners_ror_0_non_replenish", p = "wh2_dlc13_emp_elector_counts_merc_pool_non_replenish", m = 30 },
	{ u = "wh2_dlc13_emp_inf_handgunners_ror_0", g = "wh2_dlc13_emp_inf_handgunners_ror_0", p = "wh2_dlc13_emp_elector_counts_merc_pool_volkmar", m = 30 },
	{ u = "wh2_dlc13_emp_inf_huntsmen_0_imperial_supply", g = "wh2_dlc13_emp_inf_huntsmen_0_imperial_supply", p = "wh2_dlc13_emp_imperial_supply_pool", m = 30 },
	{ u = "wh2_dlc13_emp_inf_spearmen_ror_0", g = "wh2_dlc13_emp_inf_spearmen_ror_0", p = "wh2_dlc13_emp_elector_counts_merc_pool", m = 30 },
	{ u = "wh2_dlc13_emp_inf_spearmen_ror_0", g = "wh2_dlc13_emp_inf_spearmen_ror_0_non_replenish", p = "wh2_dlc13_emp_elector_counts_merc_pool_non_replenish", m = 30 },
	{ u = "wh2_dlc13_emp_inf_spearmen_ror_0", g = "wh2_dlc13_emp_inf_spearmen_ror_0", p = "wh2_dlc13_emp_elector_counts_merc_pool_volkmar", m = 30 },
	{ u = "wh2_dlc13_emp_inf_swordsmen_ror_0", g = "wh2_dlc13_emp_inf_swordsmen_ror_0", p = "wh2_dlc13_emp_elector_counts_merc_pool", m = 30 },
	{ u = "wh2_dlc13_emp_inf_swordsmen_ror_0", g = "wh2_dlc13_emp_inf_swordsmen_ror_0_non_replenish", p = "wh2_dlc13_emp_elector_counts_merc_pool_non_replenish", m = 30 },
	{ u = "wh2_dlc13_emp_inf_swordsmen_ror_0", g = "wh2_dlc13_emp_inf_swordsmen_ror_0", p = "wh2_dlc13_emp_elector_counts_merc_pool_volkmar", m = 30 },
	{ u = "wh2_dlc13_emp_veh_luminark_of_hysh_0_imperial_supply", g = "wh2_dlc13_emp_veh_luminark_of_hysh_0_imperial_supply", p = "wh2_dlc13_emp_imperial_supply_pool", m = 30 },
	{ u = "wh2_dlc13_emp_veh_steam_tank_imperial_supply", g = "wh2_dlc13_emp_veh_steam_tank_imperial_supply", p = "wh2_dlc13_emp_imperial_supply_pool", m = 30 },
	{ u = "wh2_dlc13_emp_veh_steam_tank_ror_0", g = "wh2_dlc13_emp_veh_steam_tank_ror_0", p = "wh2_dlc13_emp_elector_counts_merc_pool", m = 30 },
	{ u = "wh2_dlc13_emp_veh_steam_tank_ror_0", g = "wh2_dlc13_emp_veh_steam_tank_ror_0_non_replenish", p = "wh2_dlc13_emp_elector_counts_merc_pool_non_replenish", m = 30 },
	{ u = "wh2_dlc13_emp_veh_steam_tank_ror_0", g = "wh2_dlc13_emp_veh_steam_tank_ror_0", p = "wh2_dlc13_emp_elector_counts_merc_pool_volkmar", m = 30 },
	{ u = "wh2_dlc13_emp_veh_war_wagon_0_imperial_supply", g = "wh2_dlc13_emp_veh_war_wagon_0_imperial_supply", p = "wh2_dlc13_emp_imperial_supply_pool", m = 30 },
	{ u = "wh2_dlc13_emp_veh_war_wagon_1_imperial_supply", g = "wh2_dlc13_emp_veh_war_wagon_1_imperial_supply", p = "wh2_dlc13_emp_imperial_supply_pool", m = 30 },
	{ u = "wh2_dlc13_huntmarshall_veh_obsinite_gyrocopter_0", g = "wh2_dlc13_huntmarshall_veh_obsinite_gyrocopter_0", p = "wh2_dlc13_emp_imperial_supply_pool", m = 30 },
	{ u = "wh2_dlc13_lzd_mon_razordon_pack_0_blessed", g = "wh2_dlc13_lzd_mon_razordon_pack_0_blessed", p = "wh2_main_lzd_spawnings_pool", m = 30 },
	{ u = "wh2_dlc13_lzd_mon_sacred_kroxigors_0_blessed", g = "wh2_dlc13_lzd_mon_sacred_kroxigors_0_blessed", p = "wh2_main_lzd_spawnings_pool", m = 30 },
	{ u = "wh2_dlc14_def_mon_bloodwrack_medusa_0", g = "wh2_twa03_mon_bloodwrack_medusa_0", p = "wh2_twa03_def_rakarth_merc_pool", m = 30 },
	{ u = "wh2_dlc14_skv_inf_eshin_triads_ror_summoned_0", g = "wh2_dlc14_skv_inf_eshin_triads_ror_summoned_0", p = "wh2_dlc14_skv_units_of_renown_doppelgang_pool", m = 30 },
	{ u = "wh2_dlc15_grn_cav_forest_goblin_spider_riders_waaagh_0", g = "wh2_dlc15_grn_cav_forest_goblin_spider_riders_waaagh_0", p = "wh2_dlc15_grn_waaagh_pool", m = 30 },
	{ u = "wh2_dlc15_grn_cav_squig_hoppers_waaagh_0", g = "wh2_dlc15_grn_cav_squig_hoppers_waaagh_0", p = "wh2_dlc15_grn_waaagh_pool", m = 30 },
	{ u = "wh2_dlc15_grn_mon_feral_hydra_waaagh_0", g = "wh2_dlc15_grn_mon_feral_hydra_waaagh_0", p = "wh2_dlc15_grn_waaagh_pool", m = 30 },
	{ u = "wh2_dlc15_grn_mon_wyvern_waaagh_0", g = "wh2_dlc15_grn_mon_wyvern_waaagh_0", p = "wh2_dlc15_grn_waaagh_pool", m = 30 },
	{ u = "wh2_dlc16_skv_inf_skavenslave_spearmen_0_flesh_lab", g = "wh2_dlc16_skv_inf_skavenslave_spearmen_0_flesh_lab", p = "wh2_dlc16_skv_throt_flesh_lab_pool", m = 30 },
	{ u = "wh2_dlc16_skv_inf_skavenslaves_0_flesh_lab", g = "wh2_dlc16_skv_inf_skavenslaves_0_flesh_lab", p = "wh2_dlc16_skv_throt_flesh_lab_pool", m = 30 },
	{ u = "wh2_dlc16_skv_mon_brood_horror_0_flesh_lab", g = "wh2_dlc16_skv_mon_brood_horror_0_flesh_lab", p = "wh2_dlc16_skv_throt_flesh_lab_pool", m = 30 },
	{ u = "wh2_dlc16_skv_mon_hell_pit_abomination_flesh_lab", g = "wh2_dlc16_skv_mon_hell_pit_abomination_flesh_lab", p = "wh2_dlc16_skv_throt_flesh_lab_pool", m = 30 },
	{ u = "wh2_dlc16_skv_mon_rat_ogre_mutant_flesh_lab", g = "wh2_dlc16_skv_mon_rat_ogre_mutant_flesh_lab", p = "wh2_dlc16_skv_throt_flesh_lab_pool", m = 30 },
	{ u = "wh2_dlc16_skv_mon_rat_ogres_flesh_lab", g = "wh2_dlc16_skv_mon_rat_ogres_flesh_lab", p = "wh2_dlc16_skv_throt_flesh_lab_pool", m = 30 },
	{ u = "wh2_dlc16_skv_mon_wolf_rats_0_flesh_lab", g = "wh2_dlc16_skv_mon_wolf_rats_0_flesh_lab", p = "wh2_dlc16_skv_throt_flesh_lab_pool", m = 30 },
	{ u = "wh2_dlc16_skv_mon_wolf_rats_1_flesh_lab", g = "wh2_dlc16_skv_mon_wolf_rats_1_flesh_lab", p = "wh2_dlc16_skv_throt_flesh_lab_pool", m = 30 },
	{ u = "wh2_dlc16_wef_mon_giant_spiders_0", g = "wh2_twa03_mon_monster_giant_spider", p = "wh2_twa03_def_rakarth_merc_pool", m = 30 },
	{ u = "wh2_dlc17_lzd_inf_chameleon_stalkers_0_blessed", g = "wh2_dlc17_lzd_inf_chameleon_stalkers_0_blessed", p = "wh2_main_lzd_spawnings_pool", m = 30 },
	{ u = "wh2_main_def_inf_harpies", g = "wh2_twa03_inf_harpies", p = "wh2_twa03_def_rakarth_merc_pool", m = 30 },
	{ u = "wh2_main_def_mon_black_dragon", g = "wh2_twa03_black_dragon", p = "wh2_twa03_def_rakarth_merc_pool", m = 30 },
	{ u = "wh2_main_def_mon_war_hydra", g = "wh2_twa03_mon_war_hydra", p = "wh2_twa03_def_rakarth_merc_pool", m = 30 },
	{ u = "wh2_main_lzd_cav_cold_one_spearriders_blessed_0", g = "wh2_main_lzd_cav_cold_one_spearriders_blessed_0", p = "wh2_main_lzd_spawnings_pool", m = 30 },
	{ u = "wh2_main_lzd_cav_cold_ones_feral_0", g = "wh2_twa03_cold_ones", p = "wh2_twa03_def_rakarth_merc_pool", m = 30 },
	{ u = "wh2_main_lzd_cav_horned_ones_blessed_0", g = "wh2_main_lzd_cav_horned_ones_blessed_0", p = "wh2_main_lzd_spawnings_pool", m = 30 },
	{ u = "wh2_main_lzd_cav_terradon_riders_0_blessed", g = "wh2_main_lzd_cav_terradon_riders_0_blessed", p = "wh2_main_lzd_spawnings_pool", m = 30 },
	{ u = "wh2_main_lzd_cav_terradon_riders_blessed_1", g = "wh2_main_lzd_cav_terradon_riders_blessed_1", p = "wh2_main_lzd_spawnings_pool", m = 30 },
	{ u = "wh2_main_lzd_inf_chameleon_skinks_blessed_0", g = "wh2_main_lzd_inf_chameleon_skinks_blessed_0", p = "wh2_main_lzd_spawnings_pool", m = 30 },
	{ u = "wh2_main_lzd_inf_saurus_spearmen_blessed_1", g = "wh2_main_lzd_inf_saurus_spearmen_blessed_1", p = "wh2_main_lzd_spawnings_pool", m = 30 },
	{ u = "wh2_main_lzd_inf_saurus_warriors_blessed_1", g = "wh2_main_lzd_inf_saurus_warriors_blessed_1", p = "wh2_main_lzd_spawnings_pool", m = 30 },
	{ u = "wh2_main_lzd_inf_skink_cohort_1_blessed", g = "wh2_main_lzd_inf_skink_cohort_1_blessed", p = "wh2_main_lzd_spawnings_pool", m = 30 },
	{ u = "wh2_main_lzd_inf_skink_skirmishers_blessed_0", g = "wh2_main_lzd_inf_skink_skirmishers_blessed_0", p = "wh2_main_lzd_spawnings_pool", m = 30 },
	{ u = "wh2_main_lzd_inf_temple_guards_blessed", g = "wh2_main_lzd_inf_temple_guards_blessed", p = "wh2_main_lzd_spawnings_pool", m = 30 },
	{ u = "wh2_main_lzd_mon_ancient_stegadon_blessed", g = "wh2_main_lzd_mon_ancient_stegadon_blessed", p = "wh2_main_lzd_spawnings_pool", m = 30 },
	{ u = "wh2_main_lzd_mon_bastiladon_blessed_2", g = "wh2_main_lzd_mon_bastiladon_blessed_2", p = "wh2_main_lzd_spawnings_pool", m = 30 },
	{ u = "wh2_main_lzd_mon_carnosaur_0", g = "wh2_twa03_mon_carnosaur_0", p = "wh2_twa03_def_rakarth_merc_pool", m = 30 },
	{ u = "wh2_main_lzd_mon_carnosaur_blessed_0", g = "wh2_main_lzd_mon_carnosaur_blessed_0", p = "wh2_main_lzd_spawnings_pool", m = 30 },
	{ u = "wh2_main_lzd_mon_kroxigors_blessed", g = "wh2_main_lzd_mon_kroxigors_blessed", p = "wh2_main_lzd_spawnings_pool", m = 30 },
	{ u = "wh2_main_lzd_mon_stegadon_0", g = "wh2_twa03_feral_stegadon", p = "wh2_twa03_def_rakarth_merc_pool", m = 30 },
	{ u = "wh2_main_lzd_mon_stegadon_blessed_1", g = "wh2_main_lzd_mon_stegadon_blessed_1", p = "wh2_main_lzd_spawnings_pool", m = 30 },
	{ u = "wh2_twa03_def_mon_war_mammoth_0", g = "wh2_twa03_mon_war_mammoth_0", p = "wh2_twa03_def_rakarth_merc_pool", m = 30 },
	{ u = "wh2_twa03_def_mon_wolves_0", g = "wh2_twa03_def_mon_wolves_0", p = "wh2_twa03_def_rakarth_merc_pool", m = 30 },
	{ u = "wh2_twa03_grn_mon_wyvern_0", g = "wh2_twa03_mon_monster_feral_wyvern", p = "wh2_twa03_def_rakarth_merc_pool", m = 30 },
	{ u = "wh3_dlc20_chs_cav_chaos_chariot_mnur", g = "wh3_dlc20_chs_cav_chaos_chariot_mnur", p = "wh3_main_nur_units", m = 30 },
	{ u = "wh3_dlc20_chs_cav_chaos_knights_mnur", g = "wh3_dlc20_chs_cav_chaos_knights_mnur", p = "wh3_main_nur_units", m = 30 },
	{ u = "wh3_dlc20_chs_cav_chaos_knights_mnur_lances", g = "wh3_dlc20_chs_cav_chaos_knights_mnur_lances", p = "wh3_main_nur_units", m = 30 },
	{ u = "wh3_dlc20_chs_cav_marauder_horsemen_mnur_throwing_axes", g = "wh3_dlc20_chs_cav_marauder_horsemen_mnur_throwing_axes", p = "wh3_main_nur_units", m = 30 },
	{ u = "wh3_dlc20_chs_inf_chaos_marauders_mnur", g = "wh3_dlc20_chs_inf_chaos_marauders_mnur", p = "wh3_main_nur_units", m = 30 },
	{ u = "wh3_dlc20_chs_inf_chaos_marauders_mnur_greatweapons", g = "wh3_dlc20_chs_inf_chaos_marauders_mnur_greatweapons", p = "wh3_main_nur_units", m = 30 },
	{ u = "wh3_dlc20_chs_inf_chaos_warriors_mnur", g = "wh3_dlc20_chs_inf_chaos_warriors_mnur", p = "wh3_main_nur_units", m = 30 },
	{ u = "wh3_dlc20_chs_inf_chaos_warriors_mnur_greatweapons", g = "wh3_dlc20_chs_inf_chaos_warriors_mnur_greatweapons", p = "wh3_main_nur_units", m = 30 },
	{ u = "wh3_dlc20_chs_inf_chosen_mnur", g = "wh3_dlc20_chs_inf_chosen_mnur", p = "wh3_main_nur_units", m = 30 },
	{ u = "wh3_dlc20_chs_inf_chosen_mnur_greatweapons", g = "wh3_dlc20_chs_inf_chosen_mnur_greatweapons", p = "wh3_main_nur_units", m = 30 },
	{ u = "wh3_dlc20_chs_mon_warshrine", g = "wh3_dlc20_chs_mon_warshrine_faction_pool", p = "wh3_dlc20_chs_faction_pool", m = 30 },
	{ u = "wh3_dlc20_chs_mon_warshrine", g = "wh3_dlc20_chs_mon_warshrine_faction_pool", p = "wh3_dlc20_coc_faction_pool", m = 30 },
	{ u = "wh3_dlc20_chs_mon_warshrine", g = "wh3_dlc20_chs_mon_warshrine_faction_pool", p = "wh3_main_belakor_faction_pool", m = 30 },
	{ u = "wh3_dlc20_chs_mon_warshrine_mkho", g = "wh3_dlc20_chs_mon_warshrine_mkho_faction_pool", p = "wh3_dlc20_chs_faction_pool", m = 30 },
	{ u = "wh3_dlc20_chs_mon_warshrine_mkho", g = "wh3_dlc20_chs_mon_warshrine_mkho_faction_pool", p = "wh3_dlc20_coc_faction_pool", m = 30 },
	{ u = "wh3_dlc20_chs_mon_warshrine_mkho", g = "wh3_dlc20_chs_mon_warshrine_mkho_faction_pool", p = "wh3_main_belakor_faction_pool", m = 30 },
	{ u = "wh3_dlc20_chs_mon_warshrine_mnur", g = "wh3_dlc20_chs_mon_warshrine_mnur_faction_pool", p = "wh3_dlc20_chs_faction_pool", m = 30 },
	{ u = "wh3_dlc20_chs_mon_warshrine_mnur", g = "wh3_dlc20_chs_mon_warshrine_mnur_faction_pool", p = "wh3_dlc20_coc_faction_pool", m = 30 },
	{ u = "wh3_dlc20_chs_mon_warshrine_mnur", g = "wh3_dlc20_chs_mon_warshrine_mnur_faction_pool", p = "wh3_main_belakor_faction_pool", m = 30 },
	{ u = "wh3_dlc20_chs_mon_warshrine_mnur", g = "wh3_dlc20_chs_mon_warshrine_mnur", p = "wh3_main_nur_units", m = 30 },
	{ u = "wh3_dlc20_chs_mon_warshrine_msla", g = "wh3_dlc20_chs_mon_warshrine_msla_faction_pool", p = "wh3_dlc20_chs_faction_pool", m = 30 },
	{ u = "wh3_dlc20_chs_mon_warshrine_msla", g = "wh3_dlc20_chs_mon_warshrine_msla_faction_pool", p = "wh3_dlc20_coc_faction_pool", m = 30 },
	{ u = "wh3_dlc20_chs_mon_warshrine_msla", g = "wh3_dlc20_chs_mon_warshrine_msla_faction_pool", p = "wh3_main_belakor_faction_pool", m = 30 },
	{ u = "wh3_dlc20_chs_mon_warshrine_mtze", g = "wh3_dlc20_chs_mon_warshrine_mtze_faction_pool", p = "wh3_dlc20_chs_faction_pool", m = 30 },
	{ u = "wh3_dlc20_chs_mon_warshrine_mtze", g = "wh3_dlc20_chs_mon_warshrine_mtze_faction_pool", p = "wh3_dlc20_coc_faction_pool", m = 30 },
	{ u = "wh3_dlc20_chs_mon_warshrine_mtze", g = "wh3_dlc20_chs_mon_warshrine_mtze_faction_pool", p = "wh3_main_belakor_faction_pool", m = 30 },
	{ u = "wh3_dlc24_cth_inf_onyx_crowmen", g = "wh3_cp1_cth_bhashiva_shang_yang_support_onyx_crowmen", p = "wh3_cp1_cth_bhashiva_shang_yang_support", m = 30 },
	{ u = "wh3_dlc24_cth_mon_jade_lion", g = "wh3_cp1_cth_bhashiva_shang_yang_support_jade_lion", p = "wh3_cp1_cth_bhashiva_shang_yang_support", m = 30 },
	{ u = "wh3_dlc24_cth_mon_jet_lion", g = "wh3_cp1_cth_bhashiva_shang_yang_support_jet_lion", p = "wh3_cp1_cth_bhashiva_shang_yang_support", m = 30 },
	{ u = "wh3_dlc24_cth_veh_zhangu_war_drum", g = "wh3_cp1_cth_bhashiva_shang_yang_support_zhangu_war_drum", p = "wh3_cp1_cth_bhashiva_shang_yang_support", m = 30 },
	{ u = "wh3_dlc24_ksl_inf_kislevite_warriors", g = "wh3_dlc24_ksl_inf_kislevite_warriors", p = "wh3_main_ksl_zealous_conscription", m = 30 },
	{ u = "wh3_dlc24_tze_mon_cockatrice", g = "wh3_dlc24_tze_mon_cockatrice_faction_pool", p = "wh3_dlc20_chs_faction_pool", m = 30 },
	{ u = "wh3_dlc24_tze_mon_cockatrice", g = "wh3_dlc24_tze_mon_cockatrice_faction_pool", p = "wh3_dlc20_coc_faction_pool", m = 30 },
	{ u = "wh3_dlc24_tze_mon_cockatrice", g = "wh3_dlc24_tze_mon_cockatrice_faction_pool", p = "wh3_main_belakor_faction_pool", m = 30 },
	{ u = "wh3_dlc24_tze_mon_flamers_changebringers", g = "wh3_dlc24_tze_mon_flamers_changebringers_faction_pool", p = "wh3_dlc20_chs_faction_pool", m = 30 },
	{ u = "wh3_dlc24_tze_mon_flamers_changebringers", g = "wh3_dlc24_tze_mon_flamers_changebringers_faction_pool", p = "wh3_dlc20_coc_faction_pool", m = 30 },
	{ u = "wh3_dlc24_tze_mon_flamers_changebringers", g = "wh3_dlc24_tze_mon_flamers_changebringers_faction_pool", p = "wh3_main_belakor_faction_pool", m = 30 },
	{ u = "wh3_dlc24_tze_mon_mutalith_vortex_beast", g = "wh3_dlc24_tze_mon_mutalith_vortex_beast_faction_pool", p = "wh3_dlc20_chs_faction_pool", m = 30 },
	{ u = "wh3_dlc24_tze_mon_mutalith_vortex_beast", g = "wh3_dlc24_tze_mon_mutalith_vortex_beast_faction_pool", p = "wh3_dlc20_coc_faction_pool", m = 30 },
	{ u = "wh3_dlc24_tze_mon_mutalith_vortex_beast", g = "wh3_dlc24_tze_mon_mutalith_vortex_beast_faction_pool", p = "wh3_main_belakor_faction_pool", m = 30 },
	{ u = "wh3_dlc25_dwf_art_goblin_hewer_malakai", g = "wh3_dlc25_dwf_malakai_feature_goblin_hewer", p = "wh3_dlc25_dwf_malakai_feature_mercenary_pool", m = 30 },
	{ u = "wh3_dlc25_dwf_art_grudge_thrower_grudge_reward", g = "wh3_dlc25_dwf_grudges_grudge_thrower", p = "wh3_dlc25_dwf_book_of_grudges_mercenary_pool", m = 30 },
	{ u = "wh3_dlc25_dwf_veh_thunderbarge_malakai", g = "wh3_dlc25_dwf_malakai_feature_thunderbarge", p = "wh3_dlc25_dwf_malakai_feature_mercenary_pool", m = 30 },
	{ u = "wh3_dlc25_emp_art_helstorm_rocket_battery_morr", g = "wh3_dlc25_emp_art_helstorm_rocket_battery_morr", p = "wh3_dlc25_emp_amethyst_unit_pool", m = 30 },
	{ u = "wh3_dlc25_emp_cav_outriders_morr", g = "wh3_dlc25_emp_cav_outriders_morr", p = "wh3_dlc25_emp_amethyst_unit_pool", m = 30 },
	{ u = "wh3_dlc25_emp_inf_nuln_ironsides_morr", g = "wh3_dlc25_emp_inf_nuln_ironsides_morr", p = "wh3_dlc25_emp_amethyst_unit_pool", m = 30 },
	{ u = "wh3_dlc25_emp_veh_marienburg_land_ship_morr", g = "wh3_dlc25_emp_veh_marienburg_land_ship_morr", p = "wh3_dlc25_emp_amethyst_unit_pool", m = 30 },
	{ u = "wh3_dlc25_nur_cav_rot_knights", g = "wh3_dlc25_nur_cav_rot_knights", p = "wh3_main_nur_units", m = 30 },
	{ u = "wh3_dlc25_nur_inf_pestigors", g = "wh3_dlc25_nur_inf_pestigors", p = "wh3_main_nur_units", m = 30 },
	{ u = "wh3_dlc25_nur_inf_plague_ogres", g = "wh3_dlc25_nur_inf_plague_ogres_warriors_faction_pool", p = "wh3_dlc20_chs_faction_pool", m = 30 },
	{ u = "wh3_dlc25_nur_inf_plague_ogres", g = "wh3_dlc25_nur_inf_plague_ogres", p = "wh3_dlc20_coc_faction_pool", m = 30 },
	{ u = "wh3_dlc25_nur_inf_plague_ogres", g = "wh3_dlc25_nur_inf_plague_ogres_warriors_faction_pool", p = "wh3_main_belakor_faction_pool", m = 30 },
	{ u = "wh3_dlc25_nur_inf_plague_ogres", g = "wh3_dlc25_nur_inf_plague_ogres", p = "wh3_main_nur_units", m = 30 },
	{ u = "wh3_dlc25_nur_inf_plague_ogres_great_weapons", g = "wh3_dlc25_nur_inf_plague_ogres_great_weapons_warriors_faction_pool", p = "wh3_dlc20_chs_faction_pool", m = 30 },
	{ u = "wh3_dlc25_nur_inf_plague_ogres_great_weapons", g = "wh3_dlc25_nur_inf_plague_ogres_great_weapons", p = "wh3_dlc20_coc_faction_pool", m = 30 },
	{ u = "wh3_dlc25_nur_inf_plague_ogres_great_weapons", g = "wh3_dlc25_nur_inf_plague_ogres_great_weapons_warriors_faction_pool", p = "wh3_main_belakor_faction_pool", m = 30 },
	{ u = "wh3_dlc25_nur_inf_plague_ogres_great_weapons", g = "wh3_dlc25_nur_inf_plague_ogres_great_weapons", p = "wh3_main_nur_units", m = 30 },
	{ u = "wh3_dlc25_nur_mon_bile_trolls", g = "wh3_dlc25_nur_mon_bile_trolls_warriors_faction_pool", p = "wh3_dlc20_chs_faction_pool", m = 30 },
	{ u = "wh3_dlc25_nur_mon_bile_trolls", g = "wh3_dlc25_nur_mon_bile_trolls", p = "wh3_dlc20_coc_faction_pool", m = 30 },
	{ u = "wh3_dlc25_nur_mon_bile_trolls", g = "wh3_dlc25_nur_mon_bile_trolls_warriors_faction_pool", p = "wh3_main_belakor_faction_pool", m = 30 },
	{ u = "wh3_dlc25_nur_mon_bile_trolls", g = "wh3_dlc25_nur_mon_bile_trolls", p = "wh3_main_nur_units", m = 30 },
	{ u = "wh3_dlc25_nur_mon_toad_dragon", g = "wh3_dlc25_nur_mon_toad_dragon_warriors_faction_pool", p = "wh3_dlc20_chs_faction_pool", m = 30 },
	{ u = "wh3_dlc25_nur_mon_toad_dragon", g = "wh3_dlc25_nur_mon_toad_dragon_warriors_faction_pool", p = "wh3_dlc20_coc_faction_pool", m = 30 },
	{ u = "wh3_dlc25_nur_mon_toad_dragon", g = "wh3_dlc25_nur_mon_toad_dragon_warriors_faction_pool", p = "wh3_main_belakor_faction_pool", m = 30 },
	{ u = "wh3_dlc25_nur_mon_toad_dragon", g = "wh3_dlc25_nur_mon_toad_dragon", p = "wh3_main_nur_units", m = 30 },
	{ u = "wh3_dlc26_kho_mon_bloodbeast_of_khorne", g = "wh3_dlc26_kho_mon_bloodbeast_of_khorne_warriors_faction_pool", p = "wh3_dlc20_chs_faction_pool", m = 30 },
	{ u = "wh3_dlc26_kho_mon_bloodbeast_of_khorne", g = "wh3_dlc26_kho_mon_bloodbeast_of_khorne_warriors_faction_pool", p = "wh3_dlc20_coc_faction_pool", m = 30 },
	{ u = "wh3_dlc26_kho_mon_bloodbeast_of_khorne", g = "wh3_dlc26_kho_mon_bloodbeast_of_khorne_warriors_faction_pool", p = "wh3_main_belakor_faction_pool", m = 30 },
	{ u = "wh3_dlc26_kho_mon_slaughterbrute", g = "wh3_dlc26_kho_mon_slaughterbrute_warriors_faction_pool", p = "wh3_dlc20_chs_faction_pool", m = 30 },
	{ u = "wh3_dlc26_kho_mon_slaughterbrute", g = "wh3_dlc26_kho_mon_slaughterbrute_warriors_faction_pool", p = "wh3_dlc20_coc_faction_pool", m = 30 },
	{ u = "wh3_dlc26_kho_mon_slaughterbrute", g = "wh3_dlc26_kho_mon_slaughterbrute_warriors_faction_pool", p = "wh3_main_belakor_faction_pool", m = 30 },
	{ u = "wh3_dlc27_bst_inf_cygor_monst_arcanum_reward", g = "wh3_dlc27_bst_inf_cygor", p = "wh3_dlc27_nor_monstrous_arcanum", m = 30 },
	{ u = "wh3_dlc27_bst_mon_ghorgon_monst_arcanum_reward", g = "wh3_dlc27_bst_mon_ghorgon", p = "wh3_dlc27_nor_monstrous_arcanum", m = 30 },
	{ u = "wh3_dlc27_bst_mon_jabberslythe_monst_arcanum_reward", g = "wh3_dlc27_bst_mon_jabberslythe", p = "wh3_dlc27_nor_monstrous_arcanum", m = 30 },
	{ u = "wh3_dlc27_chs_feral_manticore_monst_arcanum_reward", g = "wh3_dlc27_nor_feral_manticore", p = "wh3_dlc27_nor_monstrous_arcanum", m = 30 },
	{ u = "wh3_dlc27_chs_mon_dragon_ogre_shaggoth_monst_arcanum_reward", g = "wh3_dlc27_chs_mon_dragon_ogre_shaggoth", p = "wh3_dlc27_nor_monstrous_arcanum", m = 30 },
	{ u = "wh3_dlc27_nor_mon_chimera_monst_arcanum_reward", g = "wh3_dlc27_nor_mon_chimera", p = "wh3_dlc27_nor_monstrous_arcanum", m = 30 },
	{ u = "wh3_dlc27_nur_mon_toad_dragon_monst_arcanum_reward", g = "wh3_dlc27_nur_mon_toad_dragon", p = "wh3_dlc27_nor_monstrous_arcanum", m = 30 },
	{ u = "wh3_dlc27_sla_cav_heartseekers_of_slaanesh_dechala", g = "wh3_dlc27_sla_dechala_daemons_heartseekers", p = "wh3_dlc27_sla_daemonic_attraction", m = 30 },
	{ u = "wh3_dlc27_sla_cav_pleasureseekers", g = "wh3_dlc27_sla_cav_pleasureseekers_warriors_faction_pool", p = "wh3_dlc20_chs_faction_pool", m = 30 },
	{ u = "wh3_dlc27_sla_cav_pleasureseekers", g = "wh3_dlc27_sla_cav_pleasureseekers_warriors_faction_pool", p = "wh3_dlc20_coc_faction_pool", m = 30 },
	{ u = "wh3_dlc27_sla_cav_pleasureseekers", g = "wh3_dlc27_sla_cav_pleasureseekers_warriors_faction_pool", p = "wh3_main_belakor_faction_pool", m = 30 },
	{ u = "wh3_dlc27_sla_cav_pleasureseekers_dechala", g = "wh3_dlc27_sla_dechala_daemons_pleasureseekers", p = "wh3_dlc27_sla_daemonic_attraction", m = 30 },
	{ u = "wh3_dlc27_sla_inf_chaos_furies_dechala", g = "wh3_dlc27_sla_dechala_daemons_furies", p = "wh3_dlc27_sla_daemonic_attraction", m = 30 },
	{ u = "wh3_dlc27_sla_inf_daemonette_1_dechala", g = "wh3_dlc27_sla_dechala_daemons_daemonette_1", p = "wh3_dlc27_sla_daemonic_attraction", m = 30 },
	{ u = "wh3_dlc27_sla_mon_champions_of_slaanesh", g = "wh3_dlc27_sla_mon_champions_of_slaanesh_warriors_faction_pool", p = "wh3_dlc20_chs_faction_pool", m = 30 },
	{ u = "wh3_dlc27_sla_mon_champions_of_slaanesh", g = "wh3_dlc27_sla_mon_champions_of_slaanesh_warriors_faction_pool", p = "wh3_dlc20_coc_faction_pool", m = 30 },
	{ u = "wh3_dlc27_sla_mon_champions_of_slaanesh", g = "wh3_dlc27_sla_mon_champions_of_slaanesh_warriors_faction_pool", p = "wh3_main_belakor_faction_pool", m = 30 },
	{ u = "wh3_dlc27_sla_mon_fiends_of_slaanesh_dechala", g = "wh3_dlc27_sla_dechala_daemons_fiends", p = "wh3_dlc27_sla_daemonic_attraction", m = 30 },
	{ u = "wh3_dlc27_sla_mon_keeper_of_secrets_dechala", g = "wh3_dlc27_sla_dechala_daemons_keeper_of_secrets", p = "wh3_dlc27_sla_daemonic_attraction", m = 30 },
	{ u = "wh3_dlc27_sla_mon_preyton_monst_arcanum_reward", g = "wh3_dlc27_sla_mon_preyton", p = "wh3_dlc27_nor_monstrous_arcanum", m = 30 },
	{ u = "wh3_dlc27_sla_veh_exalted_seeker_chariot_dechala", g = "wh3_dlc27_sla_dechala_daemons_exalted_seeker_chariot", p = "wh3_dlc27_sla_daemonic_attraction", m = 30 },
	{ u = "wh3_dlc27_tze_mon_cockatrice_monst_arcanum_reward", g = "wh3_dlc27_tze_mon_cockatrice", p = "wh3_dlc27_nor_monstrous_arcanum", m = 30 },
	{ u = "wh3_main_cth_art_fire_rain_rocket_battery_0", g = "wh3_cp1_cth_bhashiva_shang_yang_support_rocket_battery", p = "wh3_cp1_cth_bhashiva_shang_yang_support", m = 30 },
	{ u = "wh3_main_cth_inf_dragon_guard_0", g = "wh3_cp1_cth_bhashiva_shang_yang_support_dragon_guard", p = "wh3_cp1_cth_bhashiva_shang_yang_support", m = 30 },
	{ u = "wh3_main_cth_inf_dragon_guard_crossbowmen_0", g = "wh3_cp1_cth_bhashiva_shang_yang_support_dragon_guard_crossbowmen", p = "wh3_cp1_cth_bhashiva_shang_yang_support", m = 30 },
	{ u = "wh3_main_cth_inf_grenadiers", g = "wh3_cp1_cth_bhashiva_shang_yang_support_grenadiers", p = "wh3_cp1_cth_bhashiva_shang_yang_support", m = 30 },
	{ u = "wh3_main_cth_inf_iron_hail_gunners_0", g = "wh3_cp1_cth_bhashiva_shang_yang_support_iron_hail_gunners", p = "wh3_cp1_cth_bhashiva_shang_yang_support", m = 30 },
	{ u = "wh3_main_cth_inf_jade_warrior_crossbowmen_1", g = "wh3_cp1_cth_bhashiva_shang_yang_support_jade_warriors_cross_shield", p = "wh3_cp1_cth_bhashiva_shang_yang_support", m = 30 },
	{ u = "wh3_main_cth_inf_jade_warriors_1", g = "wh3_cp1_cth_bhashiva_shang_yang_support_jade_warriors_halberds", p = "wh3_cp1_cth_bhashiva_shang_yang_support", m = 30 },
	{ u = "wh3_main_cth_veh_war_compass_0", g = "wh3_cp1_cth_bhashiva_shang_yang_support_war_compass", p = "wh3_cp1_cth_bhashiva_shang_yang_support", m = 30 },
	{ u = "wh3_main_dae_inf_chaos_furies_0", g = "wh3_main_dae_inf_chaos_furies_0_faction_pool", p = "wh3_dlc20_chs_faction_pool", m = 30 },
	{ u = "wh3_main_dae_inf_chaos_furies_0", g = "wh3_main_dae_inf_chaos_furies_0_faction_pool", p = "wh3_dlc20_coc_faction_pool", m = 30 },
	{ u = "wh3_main_dae_inf_chaos_furies_0", g = "wh3_main_dae_inf_chaos_furies_0_faction_pool", p = "wh3_main_belakor_faction_pool", m = 30 },
	{ u = "wh3_main_kho_inf_bloodletters_0", g = "wh3_main_kho_inf_bloodletters_0_warriors_faction_pool", p = "wh3_dlc20_chs_faction_pool", m = 30 },
	{ u = "wh3_main_kho_inf_bloodletters_0", g = "wh3_main_kho_inf_bloodletters_0_warriors_faction_pool", p = "wh3_dlc20_coc_faction_pool", m = 30 },
	{ u = "wh3_main_kho_inf_bloodletters_0", g = "wh3_main_kho_inf_bloodletters_0_warriors_faction_pool", p = "wh3_main_belakor_faction_pool", m = 30 },
	{ u = "wh3_main_kho_inf_bloodletters_1", g = "wh3_main_kho_inf_bloodletters_1_belakor_faction_pool", p = "wh3_main_belakor_faction_pool", m = 30 },
	{ u = "wh3_main_kho_inf_flesh_hounds_of_khorne_0", g = "wh3_main_kho_inf_flesh_hounds_of_khorne_0_warriors_faction_pool", p = "wh3_dlc20_chs_faction_pool", m = 30 },
	{ u = "wh3_main_kho_inf_flesh_hounds_of_khorne_0", g = "wh3_main_kho_inf_flesh_hounds_of_khorne_0_warriors_faction_pool", p = "wh3_dlc20_coc_faction_pool", m = 30 },
	{ u = "wh3_main_kho_inf_flesh_hounds_of_khorne_0", g = "wh3_main_kho_inf_flesh_hounds_of_khorne_0_warriors_faction_pool", p = "wh3_main_belakor_faction_pool", m = 30 },
	{ u = "wh3_main_kho_mon_bloodthirster_0", g = "wh3_main_kho_mon_bloodthirster_0_warriors_faction_pool", p = "wh3_dlc20_chs_faction_pool", m = 30 },
	{ u = "wh3_main_kho_mon_bloodthirster_0", g = "wh3_main_kho_mon_bloodthirster_0_warriors_faction_pool", p = "wh3_dlc20_coc_faction_pool", m = 30 },
	{ u = "wh3_main_kho_mon_bloodthirster_0", g = "wh3_main_kho_mon_bloodthirster_0_warriors_faction_pool", p = "wh3_main_belakor_faction_pool", m = 30 },
	{ u = "wh3_main_kho_mon_soul_grinder_0", g = "wh3_main_kho_mon_soul_grinder_0_warriors_faction_pool", p = "wh3_dlc20_chs_faction_pool", m = 30 },
	{ u = "wh3_main_kho_mon_soul_grinder_0", g = "wh3_main_kho_mon_soul_grinder_0_warriors_faction_pool", p = "wh3_dlc20_coc_faction_pool", m = 30 },
	{ u = "wh3_main_kho_mon_soul_grinder_0", g = "wh3_main_kho_mon_soul_grinder_0_warriors_faction_pool", p = "wh3_main_belakor_faction_pool", m = 30 },
	{ u = "wh3_main_kho_veh_skullcannon_0", g = "wh3_main_kho_veh_skullcannon_0_warriors_faction_pool", p = "wh3_dlc20_chs_faction_pool", m = 30 },
	{ u = "wh3_main_kho_veh_skullcannon_0", g = "wh3_main_kho_veh_skullcannon_0_warriors_faction_pool", p = "wh3_dlc20_coc_faction_pool", m = 30 },
	{ u = "wh3_main_kho_veh_skullcannon_0", g = "wh3_main_kho_veh_skullcannon_0_warriors_faction_pool", p = "wh3_main_belakor_faction_pool", m = 30 },
	{ u = "wh3_main_ksl_inf_kossars_0", g = "wh3_main_ksl_inf_kossars_0", p = "wh3_main_ksl_zealous_conscription", m = 30 },
	{ u = "wh3_main_ksl_inf_kossars_1", g = "wh3_main_ksl_inf_kossars_1", p = "wh3_main_ksl_zealous_conscription", m = 30 },
	{ u = "wh3_main_monster_feral_bears", g = "wh2_twa03_mon_monster_feral_bear", p = "wh2_twa03_def_rakarth_merc_pool", m = 30 },
	{ u = "wh3_main_monster_feral_ice_bears", g = "wh2_twa03_mon_monster_feral_ice_bear", p = "wh2_twa03_def_rakarth_merc_pool", m = 30 },
	{ u = "wh3_main_nur_cav_plague_drones_0", g = "wh3_main_nur_cav_plague_drones_0_warriors_faction_pool", p = "wh3_dlc20_chs_faction_pool", m = 30 },
	{ u = "wh3_main_nur_cav_plague_drones_0", g = "wh3_main_nur_cav_plague_drones_0_warriors_faction_pool", p = "wh3_dlc20_coc_faction_pool", m = 30 },
	{ u = "wh3_main_nur_cav_plague_drones_0", g = "wh3_main_nur_cav_plague_drones_0_warriors_faction_pool", p = "wh3_main_belakor_faction_pool", m = 30 },
	{ u = "wh3_main_nur_cav_plague_drones_0", g = "wh3_main_nur_cav_plague_drones_0", p = "wh3_main_nur_units", m = 30 },
	{ u = "wh3_main_nur_cav_plague_drones_1", g = "wh3_main_nur_cav_plague_drones_1", p = "wh3_main_nur_units", m = 30 },
	{ u = "wh3_main_nur_cav_pox_riders_of_nurgle_0", g = "wh3_main_nur_cav_pox_riders_of_nurgle_0", p = "wh3_main_nur_units", m = 30 },
	{ u = "wh3_main_nur_inf_chaos_furies_0", g = "wh3_main_nur_inf_chaos_furies_0", p = "wh3_main_nur_units", m = 30 },
	{ u = "wh3_main_nur_inf_forsaken_0", g = "wh3_main_nur_inf_forsaken_0", p = "wh3_main_nur_units", m = 30 },
	{ u = "wh3_main_nur_inf_nurglings_0", g = "wh3_main_nur_inf_nurglings_0_warriors_faction_pool", p = "wh3_dlc20_chs_faction_pool", m = 30 },
	{ u = "wh3_main_nur_inf_nurglings_0", g = "wh3_main_nur_inf_nurglings_0_warriors_faction_pool", p = "wh3_dlc20_coc_faction_pool", m = 30 },
	{ u = "wh3_main_nur_inf_nurglings_0", g = "wh3_main_nur_inf_nurglings_0_warriors_faction_pool", p = "wh3_main_belakor_faction_pool", m = 30 },
	{ u = "wh3_main_nur_inf_nurglings_0", g = "wh3_main_nur_inf_nurglings_0", p = "wh3_main_nur_units", m = 30 },
	{ u = "wh3_main_nur_inf_plaguebearers_0", g = "wh3_main_nur_inf_plaguebearers_0_warriors_faction_pool", p = "wh3_dlc20_chs_faction_pool", m = 30 },
	{ u = "wh3_main_nur_inf_plaguebearers_0", g = "wh3_main_nur_inf_plaguebearers_0_warriors_faction_pool", p = "wh3_dlc20_coc_faction_pool", m = 30 },
	{ u = "wh3_main_nur_inf_plaguebearers_0", g = "wh3_main_nur_inf_plaguebearers_0_warriors_faction_pool", p = "wh3_main_belakor_faction_pool", m = 30 },
	{ u = "wh3_main_nur_inf_plaguebearers_0", g = "wh3_main_nur_inf_plaguebearers_0", p = "wh3_main_nur_units", m = 30 },
	{ u = "wh3_main_nur_inf_plaguebearers_1", g = "wh3_main_nur_inf_plaguebearers_1_belakor_faction_pool", p = "wh3_main_belakor_faction_pool", m = 30 },
	{ u = "wh3_main_nur_inf_plaguebearers_1", g = "wh3_main_nur_inf_plaguebearers_1", p = "wh3_main_nur_units", m = 30 },
	{ u = "wh3_main_nur_mon_beast_of_nurgle_0", g = "wh3_main_nur_mon_beast_of_nurgle_0_warriors_faction_pool", p = "wh3_dlc20_chs_faction_pool", m = 30 },
	{ u = "wh3_main_nur_mon_beast_of_nurgle_0", g = "wh3_main_nur_mon_beast_of_nurgle_0_warriors_faction_pool", p = "wh3_dlc20_coc_faction_pool", m = 30 },
	{ u = "wh3_main_nur_mon_beast_of_nurgle_0", g = "wh3_main_nur_mon_beast_of_nurgle_0_warriors_faction_pool", p = "wh3_main_belakor_faction_pool", m = 30 },
	{ u = "wh3_main_nur_mon_beast_of_nurgle_0", g = "wh3_main_nur_mon_beast_of_nurgle_0", p = "wh3_main_nur_units", m = 30 },
	{ u = "wh3_main_nur_mon_great_unclean_one_0", g = "wh3_main_nur_mon_great_unclean_one_0_warriors_faction_pool", p = "wh3_dlc20_chs_faction_pool", m = 30 },
	{ u = "wh3_main_nur_mon_great_unclean_one_0", g = "wh3_main_nur_mon_great_unclean_one_0_warriors_faction_pool", p = "wh3_dlc20_coc_faction_pool", m = 30 },
	{ u = "wh3_main_nur_mon_great_unclean_one_0", g = "wh3_main_nur_mon_great_unclean_one_0_warriors_faction_pool", p = "wh3_main_belakor_faction_pool", m = 30 },
	{ u = "wh3_main_nur_mon_great_unclean_one_0", g = "wh3_main_nur_mon_great_unclean_one_0", p = "wh3_main_nur_units", m = 30 },
	{ u = "wh3_main_nur_mon_plague_toads_0", g = "wh3_main_nur_mon_plague_toads_0", p = "wh3_main_nur_units", m = 30 },
	{ u = "wh3_main_nur_mon_rot_flies_0", g = "wh3_main_nur_mon_rot_flies_0", p = "wh3_main_nur_units", m = 30 },
	{ u = "wh3_main_nur_mon_soul_grinder_0", g = "wh3_main_nur_mon_soul_grinder_0_warriors_faction_pool", p = "wh3_dlc20_chs_faction_pool", m = 30 },
	{ u = "wh3_main_nur_mon_soul_grinder_0", g = "wh3_main_nur_mon_soul_grinder_0_warriors_faction_pool", p = "wh3_dlc20_coc_faction_pool", m = 30 },
	{ u = "wh3_main_nur_mon_soul_grinder_0", g = "wh3_main_nur_mon_soul_grinder_0_warriors_faction_pool", p = "wh3_main_belakor_faction_pool", m = 30 },
	{ u = "wh3_main_nur_mon_soul_grinder_0", g = "wh3_main_nur_mon_soul_grinder_0", p = "wh3_main_nur_units", m = 30 },
	{ u = "wh3_main_nur_mon_spawn_of_nurgle_0", g = "wh3_main_nur_mon_spawn_of_nurgle_0", p = "wh3_main_nur_units", m = 30 },
	{ u = "wh3_main_ogr_inf_ogres_0", g = "wh3_main_ogr_inf_ogres_0", p = "wh3_main_ogr_merc_pool", m = 30 },
	{ u = "wh3_main_ogr_inf_ogres_1", g = "wh3_main_ogr_inf_ogres_1", p = "wh3_main_ogr_merc_pool", m = 30 },
	{ u = "wh3_main_ogr_mon_sabretusk_pack_0", g = "wh2_twa03_mon_monster_sabretusk", p = "wh2_twa03_def_rakarth_merc_pool", m = 30 },
	{ u = "wh3_main_sla_inf_daemonette_0", g = "wh3_main_sla_inf_daemonette_0_warriors_faction_pool", p = "wh3_dlc20_chs_faction_pool", m = 30 },
	{ u = "wh3_main_sla_inf_daemonette_0", g = "wh3_main_sla_inf_daemonette_0_warriors_faction_pool", p = "wh3_dlc20_coc_faction_pool", m = 30 },
	{ u = "wh3_main_sla_inf_daemonette_0", g = "wh3_main_sla_inf_daemonette_0_warriors_faction_pool", p = "wh3_main_belakor_faction_pool", m = 30 },
	{ u = "wh3_main_sla_inf_daemonette_1", g = "wh3_main_sla_inf_daemonette_1_belakor_faction_pool", p = "wh3_main_belakor_faction_pool", m = 30 },
	{ u = "wh3_main_sla_mon_fiends_of_slaanesh_0", g = "wh3_main_sla_mon_fiends_of_slaanesh_0_warriors_faction_pool", p = "wh3_dlc20_chs_faction_pool", m = 30 },
	{ u = "wh3_main_sla_mon_fiends_of_slaanesh_0", g = "wh3_main_sla_mon_fiends_of_slaanesh_0_warriors_faction_pool", p = "wh3_dlc20_coc_faction_pool", m = 30 },
	{ u = "wh3_main_sla_mon_fiends_of_slaanesh_0", g = "wh3_main_sla_mon_fiends_of_slaanesh_0_warriors_faction_pool", p = "wh3_main_belakor_faction_pool", m = 30 },
	{ u = "wh3_main_sla_mon_keeper_of_secrets_0", g = "wh3_main_sla_mon_keeper_of_secrets_0_warriors_faction_pool", p = "wh3_dlc20_chs_faction_pool", m = 30 },
	{ u = "wh3_main_sla_mon_keeper_of_secrets_0", g = "wh3_main_sla_mon_keeper_of_secrets_0_warriors_faction_pool", p = "wh3_dlc20_coc_faction_pool", m = 30 },
	{ u = "wh3_main_sla_mon_keeper_of_secrets_0", g = "wh3_main_sla_mon_keeper_of_secrets_0_warriors_faction_pool", p = "wh3_main_belakor_faction_pool", m = 30 },
	{ u = "wh3_main_sla_mon_soul_grinder_0", g = "wh3_main_sla_mon_soul_grinder_0_warriors_faction_pool", p = "wh3_dlc20_chs_faction_pool", m = 30 },
	{ u = "wh3_main_sla_mon_soul_grinder_0", g = "wh3_main_sla_mon_soul_grinder_0_warriors_faction_pool", p = "wh3_dlc20_coc_faction_pool", m = 30 },
	{ u = "wh3_main_sla_mon_soul_grinder_0", g = "wh3_main_sla_mon_soul_grinder_0_warriors_faction_pool", p = "wh3_main_belakor_faction_pool", m = 30 },
	{ u = "wh3_main_sla_veh_seeker_chariot_0", g = "wh3_main_sla_veh_seeker_chariot_0_warriors_faction_pool", p = "wh3_dlc20_chs_faction_pool", m = 30 },
	{ u = "wh3_main_sla_veh_seeker_chariot_0", g = "wh3_main_sla_veh_seeker_chariot_0_warriors_faction_pool", p = "wh3_dlc20_coc_faction_pool", m = 30 },
	{ u = "wh3_main_sla_veh_seeker_chariot_0", g = "wh3_main_sla_veh_seeker_chariot_0_warriors_faction_pool", p = "wh3_main_belakor_faction_pool", m = 30 },
	{ u = "wh3_main_tze_inf_pink_horrors_0", g = "wh3_main_tze_inf_pink_horrors_0_warriors_faction_pool", p = "wh3_dlc20_chs_faction_pool", m = 30 },
	{ u = "wh3_main_tze_inf_pink_horrors_0", g = "wh3_main_tze_inf_pink_horrors_0_warriors_faction_pool", p = "wh3_dlc20_coc_faction_pool", m = 30 },
	{ u = "wh3_main_tze_inf_pink_horrors_0", g = "wh3_main_tze_inf_pink_horrors_0_warriors_faction_pool", p = "wh3_main_belakor_faction_pool", m = 30 },
	{ u = "wh3_main_tze_inf_pink_horrors_1", g = "wh3_main_tze_inf_pink_horrors_1_belakor_faction_pool", p = "wh3_main_belakor_faction_pool", m = 30 },
	{ u = "wh3_main_tze_mon_flamers_0", g = "wh3_main_tze_mon_flamers_0_warriors_faction_pool", p = "wh3_dlc20_chs_faction_pool", m = 30 },
	{ u = "wh3_main_tze_mon_flamers_0", g = "wh3_main_tze_mon_flamers_0_warriors_faction_pool", p = "wh3_dlc20_coc_faction_pool", m = 30 },
	{ u = "wh3_main_tze_mon_flamers_0", g = "wh3_main_tze_mon_flamers_0_warriors_faction_pool", p = "wh3_main_belakor_faction_pool", m = 30 },
	{ u = "wh3_main_tze_mon_lord_of_change_0", g = "wh3_main_tze_mon_lord_of_change_0_warriors_faction_pool", p = "wh3_dlc20_chs_faction_pool", m = 30 },
	{ u = "wh3_main_tze_mon_lord_of_change_0", g = "wh3_main_tze_mon_lord_of_change_0_warriors_faction_pool", p = "wh3_dlc20_coc_faction_pool", m = 30 },
	{ u = "wh3_main_tze_mon_lord_of_change_0", g = "wh3_main_tze_mon_lord_of_change_0_warriors_faction_pool", p = "wh3_main_belakor_faction_pool", m = 30 },
	{ u = "wh3_main_tze_mon_screamers_0", g = "wh3_main_tze_mon_screamers_0_warriors_faction_pool", p = "wh3_dlc20_chs_faction_pool", m = 30 },
	{ u = "wh3_main_tze_mon_screamers_0", g = "wh3_main_tze_mon_screamers_0_warriors_faction_pool", p = "wh3_dlc20_coc_faction_pool", m = 30 },
	{ u = "wh3_main_tze_mon_screamers_0", g = "wh3_main_tze_mon_screamers_0_warriors_faction_pool", p = "wh3_main_belakor_faction_pool", m = 30 },
	{ u = "wh3_main_tze_mon_soul_grinder_0", g = "wh3_main_tze_mon_soul_grinder_0_warriors_faction_pool", p = "wh3_dlc20_chs_faction_pool", m = 30 },
	{ u = "wh3_main_tze_mon_soul_grinder_0", g = "wh3_main_tze_mon_soul_grinder_0_warriors_faction_pool", p = "wh3_dlc20_coc_faction_pool", m = 30 },
	{ u = "wh3_main_tze_mon_soul_grinder_0", g = "wh3_main_tze_mon_soul_grinder_0_warriors_faction_pool", p = "wh3_main_belakor_faction_pool", m = 30 },
}
local pool_source = {
	["wh2_dlc12_skv_tech_lab_pool"] = "renown",
	["wh2_dlc13_emp_elector_counts_merc_pool"] = "imperial_supply",
	["wh2_dlc13_emp_elector_counts_merc_pool_non_replenish"] = "imperial_supply",
	["wh2_dlc13_emp_elector_counts_merc_pool_volkmar"] = "imperial_supply",
	["wh2_dlc13_emp_imperial_supply_pool"] = "imperial_supply",
	["wh2_dlc14_skv_units_of_renown_doppelgang_pool"] = "renown",
	["wh2_dlc15_grn_waaagh_pool"] = "waaagh_units",
	["wh2_dlc16_skv_throt_flesh_lab_pool"] = "flesh_lab",
	["wh2_main_lzd_spawnings_pool"] = "blessed_spawning",
	["wh2_twa03_def_rakarth_merc_pool"] = "monster_pen",
	["wh3_cp1_cth_bhashiva_shang_yang_support"] = "cp1_shang_yang_support",
	["wh3_dlc20_chs_faction_pool"] = "daemonic_summoning",
	["wh3_dlc20_coc_faction_pool"] = "daemonic_summoning",
	["wh3_dlc25_dwf_book_of_grudges_mercenary_pool"] = "dwarf_grudges_units",
	["wh3_dlc25_dwf_malakai_feature_mercenary_pool"] = "malakai_adventure_units",
	["wh3_dlc25_emp_amethyst_unit_pool"] = "amethyst_units",
	["wh3_dlc27_nor_monstrous_arcanum"] = "dlc27_monstrous_arcanum",
	["wh3_dlc27_sla_daemonic_attraction"] = "wh3_dlc27_sla_daemonic_attraction",
	["wh3_main_belakor_faction_pool"] = "daemonic_summoning_belakor",
	["wh3_main_ksl_zealous_conscription"] = "zealous_conscription",
	["wh3_main_nur_units"] = "nurgle_buildings",
	["wh3_main_ogr_merc_pool"] = "ogre_mercenaries",
}
local pool_factions = {
	["wh2_dlc12_skv_tech_lab_pool"] = { ["wh2_main_skv_clan_skryre"]=true },
	["wh2_dlc13_emp_elector_counts_merc_pool"] = { ["wh_main_emp_empire"]=true },
	["wh2_dlc13_emp_elector_counts_merc_pool_non_replenish"] = { ["wh2_dlc13_emp_the_huntmarshals_expedition"]=true },
	["wh2_dlc13_emp_elector_counts_merc_pool_volkmar"] = { ["wh_main_emp_wissenland"]=true, ["wh2_dlc13_emp_golden_order"]=true, ["wh3_main_emp_cult_of_sigmar"]=true },
	["wh2_dlc13_emp_imperial_supply_pool"] = { ["wh2_dlc13_emp_the_huntmarshals_expedition"]=true },
	["wh2_dlc14_skv_units_of_renown_doppelgang_pool"] = { ["wh2_dlc09_skv_clan_eshin"]=true },
	["wh2_dlc15_grn_waaagh_pool"] = { ["wh_main_grn_crooked_moon"]=true, ["wh_main_grn_greenskins"]=true, ["wh_main_grn_orcs_of_the_bloody_hand"]=true, ["wh2_dlc15_grn_bonerattlaz"]=true, ["wh2_dlc15_grn_broken_axe"]=true, ["wh3_dlc26_grn_gorbad_ironclaw"]=true },
	["wh2_dlc16_skv_throt_flesh_lab_pool"] = { ["wh2_main_skv_clan_moulder"]=true },
	["wh2_main_lzd_spawnings_pool"] = { ["wh2_dlc12_lzd_cult_of_sotek"]=true, ["wh2_dlc13_lzd_spirits_of_the_jungle"]=true, ["wh2_dlc17_lzd_oxyotl"]=true, ["wh2_main_lzd_hexoatl"]=true, ["wh2_main_lzd_itza"]=true, ["wh2_main_lzd_last_defenders"]=true, ["wh2_main_lzd_lizardmen"]=true, ["wh2_main_lzd_tlaqua"]=true },
	["wh2_twa03_def_rakarth_merc_pool"] = { ["wh2_twa03_def_rakarth"]=true },
	["wh3_cp1_cth_bhashiva_shang_yang_support"] = { ["wh3_cp1_cth_tiger_warriors"]=true },
	["wh3_dlc20_chs_faction_pool"] = { ["wh_main_chs_chaos"]=true, ["wh3_dlc20_chs_kholek"]=true, ["wh3_dlc20_chs_sigvald"]=true, ["wh3_main_chs_dreaded_wo"]=true, ["wh3_main_chs_gharhar"]=true, ["wh3_main_chs_khazag"]=true, ["wh3_main_chs_kvellig"]=true },
	["wh3_dlc20_coc_faction_pool"] = { ["wh3_dlc20_chs_azazel"]=true, ["wh3_dlc20_chs_festus"]=true, ["wh3_dlc20_chs_valkia"]=true, ["wh3_dlc20_chs_vilitch"]=true },
	["wh3_dlc25_dwf_book_of_grudges_mercenary_pool"] = { ["wh_main_dwf_barak_varr"]=true, ["wh_main_dwf_dwarfs"]=true, ["wh_main_dwf_karak_azul"]=true, ["wh_main_dwf_karak_hirn"]=true, ["wh_main_dwf_karak_izor"]=true, ["wh_main_dwf_karak_kadrin"]=true, ["wh_main_dwf_karak_norn"]=true, ["wh_main_dwf_karak_ziflin"]=true, ["wh_main_dwf_kraka_drak"]=true, ["wh_main_dwf_zhufbar"]=true, ["wh2_dlc15_dwf_clan_helhein"]=true, ["wh2_dlc17_dwf_thorek_ironbrow"]=true, ["wh2_main_dwf_greybeards_prospectors"]=true, ["wh2_main_dwf_karak_zorn"]=true, ["wh2_main_dwf_spine_of_sotek_dwarfs"]=true, ["wh3_dlc25_dwf_malakai"]=true, ["wh3_main_dwf_karak_azorn"]=true, ["wh3_main_dwf_the_ancestral_throng"]=true },
	["wh3_dlc25_dwf_malakai_feature_mercenary_pool"] = { ["wh3_dlc25_dwf_malakai"]=true },
	["wh3_dlc25_emp_amethyst_unit_pool"] = { ["wh_main_emp_wissenland"]=true },
	["wh3_dlc27_nor_monstrous_arcanum"] = { ["wh_dlc08_nor_norsca"]=true, ["wh_dlc08_nor_wintertooth"]=true, ["wh3_dlc27_nor_sayl"]=true },
	["wh3_dlc27_sla_daemonic_attraction"] = { ["wh3_dlc27_sla_the_tormentors"]=true },
	["wh3_main_belakor_faction_pool"] = { ["wh3_main_chs_shadow_legion"]=true },
	["wh3_main_ksl_zealous_conscription"] = { ["wh3_dlc24_ksl_daughters_of_the_forest"]=true, ["wh3_main_ksl_brotherhood_of_the_bear"]=true, ["wh3_main_ksl_druzhina_enclave"]=true, ["wh3_main_ksl_kislev"]=true, ["wh3_main_ksl_kislev_qb1"]=true, ["wh3_main_ksl_kislev_qb2"]=true, ["wh3_main_ksl_kislev_rebels"]=true, ["wh3_main_ksl_ropsmenn_clan"]=true, ["wh3_main_ksl_the_great_orthodoxy"]=true, ["wh3_main_ksl_the_ice_court"]=true, ["wh3_main_ksl_ungol_kindred"]=true, ["wh3_main_ksl_ursun_revivalists"]=true },
	["wh3_main_nur_units"] = { ["wh3_dlc20_nur_pallid_nurslings"]=true, ["wh3_dlc25_nur_epidemius"]=true, ["wh3_dlc25_nur_tamurkhan"]=true, ["wh3_main_nur_bubonic_swarm"]=true, ["wh3_main_nur_maggoth_kin"]=true, ["wh3_main_nur_poxmakers_of_nurgle"]=true, ["wh3_main_nur_septic_claw"]=true },
}
local pool_subcultures = {
	["wh2_dlc13_emp_elector_counts_merc_pool"] = { ["wh_main_sc_emp_empire"]=true },
	["wh2_dlc13_emp_elector_counts_merc_pool_non_replenish"] = { ["wh_main_sc_emp_empire"]=true },
	["wh2_dlc13_emp_elector_counts_merc_pool_volkmar"] = { ["wh_main_sc_emp_empire"]=true },
	["wh2_dlc15_grn_waaagh_pool"] = { ["wh_main_sc_grn_greenskins"]=true },
	["wh2_main_lzd_spawnings_pool"] = { ["wh2_main_sc_lzd_lizardmen"]=true },
	["wh3_dlc20_chs_faction_pool"] = { ["wh_main_sc_chs_chaos"]=true },
	["wh3_dlc20_coc_faction_pool"] = { ["wh_main_sc_chs_chaos"]=true },
	["wh3_dlc25_dwf_book_of_grudges_mercenary_pool"] = { ["wh_main_sc_dwf_dwarfs"]=true },
	["wh3_dlc25_dwf_malakai_feature_mercenary_pool"] = { ["wh_main_sc_dwf_dwarfs"]=true },
	["wh3_dlc27_nor_monstrous_arcanum"] = { ["wh_dlc08_sc_nor_norsca"]=true },
	["wh3_main_ksl_zealous_conscription"] = { ["wh3_main_sc_ksl_kislev"]=true },
	["wh3_main_nur_units"] = { ["wh3_main_sc_nur_nurgle"]=true },
}

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