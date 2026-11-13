Scriptname NahIDWinMCM extends SKI_ConfigBase
{ Menu UNICO do NAH-I-D-WIN (substitui o menu do Inpa Sekiro Combat; nao herda dele). Estilo do Inpa: cabecalhos laranja, MOD On/Off, sem imagens.
  Tres paginas: "MOD Setting", "Game Setting" e "Advanced".
  - Opcoes do Inpa (parry, bloqueio, dificuldade, resistencias, Game Settings): gravam nos MESMOS globais do Inpa e aplicam os mesmos Game Settings,
    por isso o resto do Inpa continua a funcionar e reaplica tudo ao carregar o jogo (nada precisa de ficar no save).
  - Opcoes nossas (poise, postura, furia, exaustao, estamina por golpe, stagger...): gravam no NahIDWin.ini atraves da DLL.
  - MOD On/Off liga e desliga o Inpa e o NahIDWin em conjunto.
  As propriedades abaixo tem os nomes das propriedades da quest do menu do Inpa (preenchidas pelo NahIDWin.esp). }

; ---------------- propriedades (preenchidas pelo ESP) ----------------
Actor Property PlayerRef Auto
GlobalVariable Property zzzSekiro_MCM_turn Auto
GlobalVariable Property zzzSekiro_parrytimer Auto
GlobalVariable Property zzzSekiro_staminaRecovery Auto
GlobalVariable Property zzzSekiro_parry_ward_opt Auto
GlobalVariable Property zzzSekiro_arrowparry Auto
GlobalVariable Property zzzSekiro_wardparry Auto
GlobalVariable Property zzzSekiro_player_blockdamage0 Auto
GlobalVariable Property zzzSekiro_block_resist_poison_opt Auto
GlobalVariable Property zzzSekiro_postureregen Auto
GlobalVariable Property zzzSekiro_killmove Auto
GlobalVariable Property zzzSekiro_killmove_sneak Auto
GlobalVariable Property zzzSekiro_player_sneak_damage_mult Auto
GlobalVariable Property zzzSekiro_alert Auto
GlobalVariable Property zzzSekiro_npc_arrow_parry Auto
GlobalVariable Property zzzSekiro_npc_magic_parry Auto
GlobalVariable Property zzzSekiro_npc_fist_parry Auto
GlobalVariable Property zzzSekiro_frost_resist Auto
GlobalVariable Property zzzSekiro_npc_magic_stagger Auto
GlobalVariable Property zzzSekiro_penrilrandom Auto
GlobalVariable Property zzzSekiro_dragon_staminaX Auto
GlobalVariable Property zzzSekiro_protect_friend Auto
GlobalVariable Property zzzSekiro_ally_dont_stamina_dmg Auto
GlobalVariable Property zzzSekiro_ally_cant_stagger Auto
GlobalVariable Property zzzSekiro_all_difficulty Auto
GlobalVariable Property zzzSekiro_player_difficulty_taken Auto
GlobalVariable Property zzzSekiro_npc_difficulty Auto
GlobalVariable Property zzzSekiro_npc_difficulty_taken Auto
GlobalVariable Property zzzSekiro_resurrection Auto
GlobalVariable Property zzzSekiro_posture_dmg_mult Auto
GlobalVariable Property zzzSekiro_posture_dmg_mult_player Auto
GlobalVariable Property zzzSekiro_poisesystem Auto
GlobalVariable Property STAMINA_POWERCOST_SLIDER_global Auto
GlobalVariable Property SPRINT_DRAINBASE_SLIDER_global Auto
GlobalVariable Property SPRINT_DRAINMULT_SLIDER_global Auto
GlobalVariable Property COMBAT_STAMINAREGEN_SLIDER_global Auto
GlobalVariable Property STAMINA_REGENDELAY_SLIDER_global Auto
GlobalVariable Property MAX_RESISTANCE_SLIDER_global Auto
GlobalVariable Property ARMOR_MAXRESIST_SLIDER_global Auto
GlobalVariable Property BLOCK_SHIELD_SLIDER_global Auto
GlobalVariable Property BLOCK_WEAPON_SLIDER_global Auto
Spell Property zzzSekiro_player_main_spell Auto
Spell Property zzzSekiro_player_main2_spell Auto
Spell Property zzzSekiro_player_main3_spell Auto
Spell Property zzzSekiro_cloak_spell Auto
Spell Property zzzSekiro_regen_blocking_spell Auto
Spell Property zzzSekiro_ward_spell Auto
Spell Property zzzSekiro_player_parrytimer_spell Auto
Spell Property zzzSekiro_player_parry_spell Auto
Spell Property zzzSekiro_player_parry2_spell Auto
Spell Property zzzSekiro_player_parry3_spell Auto
Spell Property zzzSekiro_zzResurrection_spell Auto

; ---------------- tabela das nossas opcoes (.ini) ----------------
int[] sBlk
int[] sType
string[] sSec
string[] sKey
string[] sLabelPT
string[] sLabelEN
string[] sInfoPT
string[] sInfoEN
float[] sMin
float[] sMax
float[] sStep
float[] sDef
int count
int tableRev
int buildTab = -1

; ---------------- opcoes desenhadas na pagina ----------------
; tipos: 1 interruptor MOD, 2 toggle do .ini, 3 slider do .ini, 4 toggle global, 5 slider global, 6 menu
int[] oKind
int[] oRef
int[] oOpt
int sPageNo = -1
int sFlag = 0

; gid dos globais do Inpa
; 1 parrytimer 2 staminaRecovery 3 parry_ward 4 arrow 5 ward 6 blockdamage0 7 resist_poison 8 alert 9 npc_arrow 10 npc_magic 11 npc_fist
; 12 frost 13 npc_magic_stagger 14 perilous 15 dragon 16 protect_friend 17 ally_stamina 18 ally_stagger 19 killmove 20 killmove_sneak
; 21 sneak_mult 22 powercost 23 sprint_base 24 sprint_mult 25 combat_regen 26 regen_delay 27 max_res 28 armor_res 29 shield 30 weapon
; 31 player_difficulty_on 32 player_taken 33 npc_difficulty_on 34 npc_taken

int Function GetVersion()
	return 34
EndFunction

; Bloquear flechas/magia e resistir veneno vem do .ini ([Inpa] BlockArrow, BlockMagic, ResistPoison); ligados por omissao.
; A mudanca de dificuldade vem desligada na primeira vez.
Function ApplyIniGlobal(int gid, string key)
	GlobalVariable g = GetG(gid)
	if g
		float v = NahIDWinNative.IniGetF("Inpa", key, 1.0)
		if (g.GetValue() > 0.5) != (v > 0.5)
			g.SetValue(v)
			GlobalChanged(gid, v)
		endif
	endif
EndFunction

Function ApplyIniGlobals()
	ApplyIniGlobal(4, "BlockArrow")
	ApplyIniGlobal(5, "BlockMagic")
	ApplyIniGlobal(7, "ResistPoison")
	ApplyParryGlobal()
	if NahIDWinNative.IniGetF("Menu", "ExecInit", 0.0) < 0.5
		NahIDWinNative.IniSetF("Menu", "ExecInit", 1.0)
		if GetG(19)
			GetG(19).SetValue(3.0)
			GlobalChanged(19, 3.0)
		endif
		if GetG(20)
			GetG(20).SetValue(2.0)
			GlobalChanged(20, 2.0)
		endif
	endif
	if NahIDWinNative.IniGetF("Menu", "DifficultyInit", 0.0) < 0.5
		NahIDWinNative.IniSetF("Menu", "DifficultyInit", 1.0)
		if GetG(31) && GVal(31) > 0.5
			GetG(31).SetValue(0.0)
			GlobalChanged(31, 0.0)
		endif
		if GetG(33) && GVal(33) > 0.5
			GetG(33).SetValue(0.0)
			GlobalChanged(33, 0.0)
		endif
	endif
EndFunction

Event OnGameReload()
	parent.OnGameReload()
	ApplyIniGlobals()
EndEvent

Event OnVersionUpdate(int a_version)
	SetupPages()
EndEvent

Event OnInit()
	parent.OnInit()
	SetupPages()
EndEvent

Event OnConfigInit()
	SetupPages()
	ApplyIniGlobals()
EndEvent

Function SetupPages()
	ModName = "NAH-I-D-WIN"
	Pages = new string[5]
	Pages[0] = "General & System"
	Pages[1] = "Stamina"
	Pages[2] = "Poise & Posture"
	Pages[3] = "Stagger & Behaviors"
	Pages[4] = "Special & HUD"
EndFunction

; ---------------- utilitarios ----------------
bool Function IsPT()
	return NahIDWinNative.GetLanguage() == 1
EndFunction

string Function Tr(string en, string pt)
	if IsPT()
		return pt
	endif
	return en
EndFunction

string Function Orange(string t)
	return "<font color=\"#d1820d\">" + t + "</font>"
EndFunction

bool Function ModOn()
	if zzzSekiro_MCM_turn
		return zzzSekiro_MCM_turn.GetValue() > 0.5
	endif
	return NahIDWinNative.IniGetF("General", "Enabled", 1.0) > 0.5
EndFunction

GlobalVariable Function GetG(int gid)
	if gid == 1
		return zzzSekiro_parrytimer
	elseif gid == 2
		return zzzSekiro_staminaRecovery
	elseif gid == 3
		return zzzSekiro_parry_ward_opt
	elseif gid == 4
		return zzzSekiro_arrowparry
	elseif gid == 5
		return zzzSekiro_wardparry
	elseif gid == 6
		return zzzSekiro_player_blockdamage0
	elseif gid == 7
		return zzzSekiro_block_resist_poison_opt
	elseif gid == 8
		return zzzSekiro_alert
	elseif gid == 9
		return zzzSekiro_npc_arrow_parry
	elseif gid == 10
		return zzzSekiro_npc_magic_parry
	elseif gid == 11
		return zzzSekiro_npc_fist_parry
	elseif gid == 12
		return zzzSekiro_frost_resist
	elseif gid == 13
		return zzzSekiro_npc_magic_stagger
	elseif gid == 14
		return zzzSekiro_penrilrandom
	elseif gid == 15
		return zzzSekiro_dragon_staminaX
	elseif gid == 16
		return zzzSekiro_protect_friend
	elseif gid == 17
		return zzzSekiro_ally_dont_stamina_dmg
	elseif gid == 18
		return zzzSekiro_ally_cant_stagger
	elseif gid == 19
		return zzzSekiro_killmove
	elseif gid == 20
		return zzzSekiro_killmove_sneak
	elseif gid == 21
		return zzzSekiro_player_sneak_damage_mult
	elseif gid == 22
		return STAMINA_POWERCOST_SLIDER_global
	elseif gid == 23
		return SPRINT_DRAINBASE_SLIDER_global
	elseif gid == 24
		return SPRINT_DRAINMULT_SLIDER_global
	elseif gid == 25
		return COMBAT_STAMINAREGEN_SLIDER_global
	elseif gid == 26
		return STAMINA_REGENDELAY_SLIDER_global
	elseif gid == 27
		return MAX_RESISTANCE_SLIDER_global
	elseif gid == 28
		return ARMOR_MAXRESIST_SLIDER_global
	elseif gid == 29
		return BLOCK_SHIELD_SLIDER_global
	elseif gid == 30
		return BLOCK_WEAPON_SLIDER_global
	elseif gid == 31
		return zzzSekiro_all_difficulty
	elseif gid == 32
		return zzzSekiro_player_difficulty_taken
	elseif gid == 33
		return zzzSekiro_npc_difficulty
	elseif gid == 34
		return zzzSekiro_npc_difficulty_taken
	endif
	return None
EndFunction

float Function GVal(int gid)
	GlobalVariable g = GetG(gid)
	if g
		return g.GetValue()
	endif
	return 0.0
EndFunction

; Slider: minimo / maximo / passo / valor por omissao / formato (lidos do menu do Inpa)
float Function GMin(int gid)
	if gid == 1
		return 0.1
	elseif gid == 15
		return 1.0
	elseif gid == 21
		return 5.0
	endif
	return 0.0
EndFunction

float Function GMax(int gid)
	if gid == 1
		return 0.2
	elseif gid == 2 || gid == 14
		return 10.0
	elseif gid == 15
		return 10.0
	elseif gid == 21
		return 20.0
	elseif gid == 22
		return 10.0
	elseif gid == 23
		return 50.0
	elseif gid == 24 || gid == 25 || gid == 29 || gid == 30
		return 1.0
	elseif gid == 26
		return 10.0
	elseif gid == 27 || gid == 28
		return 100.0
	endif
	return 1000.0
EndFunction

float Function GStep(int gid)
	if gid == 1 || gid == 24 || gid == 25 || gid == 29 || gid == 30
		return 0.01
	elseif gid == 15 || gid == 22 || gid == 26
		return 0.1
	elseif gid == 21 || gid == 32 || gid == 34
		return 5.0
	endif
	return 1.0
EndFunction

float Function GDef(int gid)
	if gid == 1
		return 0.15
	elseif gid == 2
		return 5.0
	elseif gid == 14
		return 7.0
	elseif gid == 15
		return 2.0
	elseif gid == 21
		return 5.0
	elseif gid == 22
		return 2.0
	elseif gid == 23
		return 7.0
	elseif gid == 24
		return 0.02
	elseif gid == 25
		return 0.35
	elseif gid == 26
		return 5.0
	elseif gid == 27
		return 100.0
	elseif gid == 28
		return 75.0
	elseif gid == 29
		return 0.75
	elseif gid == 30
		return 0.66
	elseif gid == 32
		return 100.0
	elseif gid == 34
		return 35.0
	endif
	return 0.0
EndFunction

string Function GFmt(int gid)
	if gid == 1
		return "{2}sec"
	elseif gid == 2 || gid == 14 || gid == 27 || gid == 28 || gid == 32 || gid == 34
		return "{0}%"
	elseif gid == 15
		return "{1}x"
	elseif gid == 21
		return "{0}x"
	elseif gid == 22 || gid == 26
		return "{1}"
	elseif gid == 23
		return "{0}"
	endif
	return "{2}"
EndFunction

string Function GGmst(int gid)
	if gid == 22
		return "fPowerAttackStaminaPenalty"
	elseif gid == 23
		return "fSprintStaminaDrainMult"
	elseif gid == 24
		return "fSprintStaminaWeightMult"
	elseif gid == 25
		return "fCombatStaminaRegenRateMult"
	elseif gid == 26
		return "fStaminaRegenDelayMax"
	elseif gid == 27
		return "fPlayerMaxResistance"
	elseif gid == 28
		return "fMaxArmorRating"
	elseif gid == 29
		return "fShieldBaseFactor"
	elseif gid == 30
		return "fBlockWeaponBase"
	endif
	return ""
EndFunction

Function Refresh(Spell s)
	if s
		PlayerRef.DispelSpell(s)
		PlayerRef.RemoveSpell(s)
		PlayerRef.AddSpell(s, false)
	endif
EndFunction

Function Strip(Spell s)
	if s
		PlayerRef.DispelSpell(s)
		PlayerRef.RemoveSpell(s)
	endif
EndFunction

Function SetDifficultyPlayer(float pct)
	float f = pct / 100.0
	Game.SetGameSettingFloat("fDiffMultHPToPCVE", f)
	Game.SetGameSettingFloat("fDiffMultHPToPCE", f)
	Game.SetGameSettingFloat("fDiffMultHPToPCN", f)
	Game.SetGameSettingFloat("fDiffMultHPToPCH", f)
	Game.SetGameSettingFloat("fDiffMultHPToPCVH", f)
	Game.SetGameSettingFloat("fDiffMultHPToPCL", f)
EndFunction

Function SetDifficultyNPC(float pct)
	float f = pct / 100.0
	Game.SetGameSettingFloat("fDiffMultHPByPCVE", f)
	Game.SetGameSettingFloat("fDiffMultHPByPCE", f)
	Game.SetGameSettingFloat("fDiffMultHPByPCN", f)
	Game.SetGameSettingFloat("fDiffMultHPByPCH", f)
	Game.SetGameSettingFloat("fDiffMultHPByPCVH", f)
	Game.SetGameSettingFloat("fDiffMultHPByPCL", f)
EndFunction

Function RestoreDifficultyPlayer()
	Game.SetGameSettingFloat("fDiffMultHPToPCVE", 0.5)
	Game.SetGameSettingFloat("fDiffMultHPToPCE", 0.75)
	Game.SetGameSettingFloat("fDiffMultHPToPCN", 1.0)
	Game.SetGameSettingFloat("fDiffMultHPToPCH", 1.5)
	Game.SetGameSettingFloat("fDiffMultHPToPCVH", 2.0)
	Game.SetGameSettingFloat("fDiffMultHPToPCL", 3.0)
EndFunction

Function RestoreDifficultyNPC()
	Game.SetGameSettingFloat("fDiffMultHPByPCVE", 2.0)
	Game.SetGameSettingFloat("fDiffMultHPByPCE", 1.5)
	Game.SetGameSettingFloat("fDiffMultHPByPCN", 1.0)
	Game.SetGameSettingFloat("fDiffMultHPByPCH", 0.75)
	Game.SetGameSettingFloat("fDiffMultHPByPCVH", 0.5)
	Game.SetGameSettingFloat("fDiffMultHPByPCL", 0.25)
EndFunction

; Liga ou desliga o Inpa e o NahIDWin em conjunto.
Function SetModOn(bool a_on)
	if a_on
		zzzSekiro_MCM_turn.SetValue(1.0)
		NahIDWinNative.IniSetF("General", "Enabled", 1.0)
		; sem "regenerar estamina a bloquear" e sem ressurreicao (removidos do mod)
		zzzSekiro_postureregen.SetValue(0.0)
		zzzSekiro_resurrection.SetValue(0.0)
		Strip(zzzSekiro_regen_blocking_spell)
		Strip(zzzSekiro_zzResurrection_spell)
		Strip(zzzSekiro_cloak_spell)
		Refresh(zzzSekiro_player_main_spell)
		Refresh(zzzSekiro_player_main2_spell)
		Refresh(zzzSekiro_player_main3_spell)
		Refresh(zzzSekiro_player_parrytimer_spell)
		Refresh(zzzSekiro_player_parry_spell)
		Refresh(zzzSekiro_player_parry2_spell)
		Refresh(zzzSekiro_player_parry3_spell)
	else
		zzzSekiro_MCM_turn.SetValue(0.0)
		NahIDWinNative.IniSetF("General", "Enabled", 0.0)
		Strip(zzzSekiro_player_main_spell)
		Strip(zzzSekiro_player_main2_spell)
		Strip(zzzSekiro_player_main3_spell)
		Strip(zzzSekiro_cloak_spell)
		Strip(zzzSekiro_regen_blocking_spell)
		Strip(zzzSekiro_ward_spell)
		Strip(zzzSekiro_player_parrytimer_spell)
		Strip(zzzSekiro_player_parry_spell)
		Strip(zzzSekiro_player_parry2_spell)
		Strip(zzzSekiro_player_parry3_spell)
		Strip(zzzSekiro_zzResurrection_spell)
	endif
EndFunction

; efeitos secundarios de mudar um global do Inpa (iguais aos do menu original)
Function GlobalChanged(int gid, float v)
	if gid == 1
		Refresh(zzzSekiro_player_parrytimer_spell)
	elseif gid == 2
		Refresh(zzzSekiro_player_parry_spell)
		Refresh(zzzSekiro_player_parry2_spell)
	elseif gid == 4 || gid == 5
		Refresh(zzzSekiro_player_main_spell)
		Refresh(zzzSekiro_player_parry2_spell)
	elseif gid >= 22 && gid <= 30
		Game.SetGameSettingFloat(GGmst(gid), v)
		Refresh(zzzSekiro_player_main_spell)
	elseif gid == 31
		if v > 0.5
			SetDifficultyPlayer(GVal(32))
		else
			RestoreDifficultyPlayer()
		endif
	elseif gid == 32
		SetDifficultyPlayer(v)
	elseif gid == 33
		if v > 0.5
			SetDifficultyNPC(GVal(34))
		else
			RestoreDifficultyNPC()
		endif
	elseif gid == 34
		SetDifficultyNPC(v)
	endif
EndFunction

; ---------------- tabela das opcoes .ini ----------------
Function AddSetting(int blk, int ty, string sec, string key, string lpt, string lenn, string ipt, string ien, float mn, float mx, float stp, float df)
	if TabOfBlk(blk) != buildTab || count >= 128
		return
	endif
	sBlk[count] = blk
	sType[count] = ty
	sSec[count] = sec
	sKey[count] = key
	sLabelPT[count] = lpt
	sLabelEN[count] = lenn
	sInfoPT[count] = ipt
	sInfoEN[count] = ien
	sMin[count] = mn
	sMax[count] = mx
	sStep[count] = stp
	sDef[count] = df
	count += 1
EndFunction

; blocos: 1 Poise, 2 Postura, 3 Furia, 4 Exaustao, 5 Estamina (nossa), 6 Bloqueio dos NPCs, 7 Stagger e empurrao,
;         8 Multiplicadores por arma, 9 Armadura, 10 HUD, 11 Sistema, 12 Bloqueio normal
Function BuildTable(int tab)
	if count > 0 && tableRev == 14 && buildTab == tab
		return
	endif
	tableRev = 14
	buildTab = tab
	sBlk = new int[128]
	sType = new int[128]
	sSec = new string[128]
	sKey = new string[128]
	sLabelPT = new string[128]
	sLabelEN = new string[128]
	sInfoPT = new string[128]
	sInfoEN = new string[128]
	sMin = new float[128]
	sMax = new float[128]
	sStep = new float[128]
	sDef = new float[128]
	count = 0
	; 0 = slider, 1 = interruptor
	AddSetting(1, 0, "Poise", "MaxScalePlayer", "Poise maximo - jogador (escala)", "Max poise - player (scale)", "Tamanho da barra de poise do jogador. Mais alto = aguenta mais golpes.", "Size of the player's poise bar. Higher = survives more hits.", 0.5, 20.0, 0.1, 4.5)
	AddSetting(1, 0, "Poise", "MaxScaleNPC", "Poise maximo - NPCs (escala)", "Max poise - NPCs (scale)", "Tamanho da barra de poise dos NPCs e criaturas.", "Size of the poise bar of NPCs and creatures.", 0.5, 30.0, 0.5, 9.0)
	AddSetting(1, 0, "Poise", "NPCTakenMult", "Dano de poise aos NPCs (x)", "Poise damage to NPCs (x)", "Quanto poise e postura os NPCs perdem por golpe.", "How much poise and posture NPCs lose per hit.", 0.5, 10.0, 0.1, 2.5)
	AddSetting(1, 0, "Poise", "PlayerTakenMult", "Dano de poise ao jogador (x)", "Poise damage to player (x)", "Quanto poise e postura o jogador perde por golpe.", "How much poise and posture the player loses per hit.", 0.5, 10.0, 0.1, 1.5)
	AddSetting(1, 0, "Poise", "RegenSeconds", "Regeneracao do poise (s)", "Poise regeneration (s)", "Segundos para o poise encher de zero a cheio.", "Seconds for poise to refill from zero to full.", 5.0, 120.0, 5.0, 30.0)
	AddSetting(1, 0, "Poise", "RegenDelaySeconds", "Pausa antes de regenerar (s)", "Delay before regenerating (s)", "Segundos sem levar golpes antes de comecar a regenerar.", "Seconds without being hit before regeneration starts.", 0.0, 10.0, 0.5, 2.0)
	AddSetting(1, 0, "Poise", "PlayerStaggerFloor", "Jogador sem stagger acima de (fracao)", "Player no stagger above (fraction)", "Com o poise do jogador acima desta fracao, nenhum golpe causa stagger. Abaixo, o stagger do jogo (e o SBS) tomam conta.", "While the player's poise is above this fraction no hit staggers. Below it the vanilla stagger (and SBS) take over.", 0.0, 1.0, 0.05, 0.5)
	AddSetting(1, 0, "Poise", "LevelBonus", "Bonus de poise por nivel", "Poise bonus per level", "Poise maximo extra por nivel do personagem (antes da escala).", "Extra max poise per character level (before the scale).", 0.0, 10.0, 0.1, 1.5)
	AddSetting(1, 0, "Damage", "AttackerLevelMult", "Dano de poise por nivel do atacante", "Poise damage per attacker level", "Dano de poise extra por nivel do atacante.", "Extra poise damage per attacker level.", 0.0, 3.0, 0.05, 0.35)
	AddSetting(1, 0, "Damage", "CreatureDamageMult", "Dano de poise/postura de criaturas (x)", "Creature poise/posture damage (x)", "Multiplicador do dano de poise e postura de criaturas (aranhas, lobos...).", "Multiplier of poise and posture damage from creatures (spiders, wolves...).", 0.1, 2.0, 0.05, 0.55)
	AddSetting(1, 0, "Damage", "GiantDamageMult", "Dano de poise/postura de gigantes (x)", "Giant poise/posture damage (x)", "Multiplicador do dano de poise e postura de gigantes e criaturas enormes.", "Multiplier of poise and posture damage from giants and huge creatures.", 0.1, 2.0, 0.05, 0.40)
	AddSetting(1, 0, "Damage", "BlockedMultNpc", "Poise do NPC ao bloquear (x)", "NPC poise when blocking (x)", "Fracao do dano de poise que um golpe bloqueado causa a um NPC.", "Fraction of poise damage a blocked hit causes to an NPC.", 0.0, 1.0, 0.01, 0.30)
	AddSetting(2, 0, "Posture", "PlayerBrokenSeconds", "Postura quebrada (jogador): segundos expostos", "Broken posture (player): seconds exposed", "Tempo em que o jogador fica exposto: leva mais dano, estamina a 0 e nao bloqueia.", "How long the player stays exposed: takes more damage, stamina 0, cannot block.", 0.0, 10.0, 0.5, 4.0)
	AddSetting(2, 0, "Posture", "PlayerBrokenDamageMult", "Postura quebrada (jogador): dano recebido (x)", "Broken posture (player): damage taken (x)", "Multiplicador do dano recebido enquanto exposto.", "Damage taken multiplier while exposed.", 1.0, 5.0, 0.1, 2.0)
	AddSetting(2, 0, "Posture", "BlockedMultNpc", "Postura do NPC ao bloquear (x)", "NPC posture when blocking (x)", "Fracao do dano de postura de um golpe bloqueado num NPC.", "Fraction of posture damage of a blocked hit on an NPC.", 0.0, 1.0, 0.01, 0.40)
	AddSetting(5, 0, "NpcStamina", "SwingPercent", "NPC: custo do golpe (% da estamina)", "NPC: swing cost (% of stamina)", "Percentagem da estamina maxima do NPC por golpe de referencia.", "Percent of the NPC's max stamina per reference swing.", 0.0, 20.0, 0.25, 4.5)
	AddSetting(5, 0, "NpcStamina", "BlockPercent", "NPC: custo do bloqueio (% da estamina)", "NPC: block cost (% of stamina)", "Percentagem da estamina maxima do NPC por golpe bloqueado.", "Percent of the NPC's max stamina per blocked hit.", 0.0, 50.0, 1.0, 14.0)
	AddSetting(1, 0, "Damage", "BlockedMult", "Poise gasto ao bloquear (x)", "Poise spent when blocking (x)", "Fracao do dano de poise que um golpe bloqueado causa.", "Fraction of poise damage a blocked hit causes.", 0.0, 1.0, 0.01, 0.15)
	AddSetting(2, 1, "Posture", "Enabled", "Postura ligada", "Posture enabled", "Liga a barra de postura (separada da estamina). Quando enche: BleedOut.", "Enables the posture bar (separate from stamina). When it fills: BleedOut.", 0.0, 1.0, 1.0, 1.0)
	AddSetting(2, 0, "Posture", "Difficulty", "DIFICULDADE da postura", "Posture DIFFICULTY", "1.0 normal. 2.0 = a postura aguenta o dobro. 0.5 = quebra com metade.", "1.0 normal. 2.0 = posture lasts twice as long. 0.5 = breaks with half.", 0.2, 10.0, 0.1, 1.0)
	AddSetting(2, 0, "Posture", "ScalePlayer", "Postura - jogador (escala)", "Posture - player (scale)", "Tamanho da barra de postura do jogador.", "Size of the player's posture bar.", 1.0, 20.0, 0.5, 5.0)
	AddSetting(2, 0, "Posture", "ScaleNPC", "Postura - NPCs (escala)", "Posture - NPCs (scale)", "Tamanho da barra de postura dos NPCs.", "Size of the NPCs' posture bar.", 1.0, 20.0, 0.5, 5.0)
	AddSetting(2, 0, "Posture", "DamageMult", "Dano de postura (x)", "Posture damage (x)", "Quanto cada golpe enche a postura.", "How much each hit fills posture.", 0.1, 5.0, 0.1, 1.0)
	AddSetting(2, 0, "Posture", "BlockedMult", "Postura gasta ao bloquear (x)", "Posture spent when blocking (x)", "Fracao do dano de postura de um golpe bloqueado.", "Fraction of posture damage of a blocked hit.", 0.0, 1.0, 0.01, 0.12)
	AddSetting(2, 0, "Posture", "RegenSeconds", "Regeneracao da postura (s)", "Posture regeneration (s)", "Segundos para a postura baixar de cheia a zero.", "Seconds for posture to drop from full to zero.", 10.0, 300.0, 5.0, 60.0)
	AddSetting(2, 0, "Posture", "LowHealthBonus", "Bonus com vida baixa", "Low health bonus", "Com a vida baixa a postura enche mais depressa. 0 = desligado.", "With low health posture fills faster. 0 = off.", 0.0, 3.0, 0.1, 1.0)
	AddSetting(2, 0, "Posture", "BleedOutSeconds", "Duracao do BleedOut (s)", "BleedOut duration (s)", "Tempo ajoelhado quando a postura quebra.", "Time kneeling when posture breaks.", 1.0, 15.0, 0.5, 4.0)
	AddSetting(2, 0, "Posture", "BleedOutImmuneSeconds", "Imunidade apos BleedOut (s)", "Immunity after BleedOut (s)", "Tempo sem poder voltar a quebrar depois de levantar.", "Time you cannot break again after getting up.", 0.0, 15.0, 0.5, 5.0)
	AddSetting(3, 1, "Rage", "Enabled", "Furia ligada", "Rage enabled", "Imunidade temporaria em troca de vida ou estamina.", "Temporary stagger immunity and damage reduction at a cost.", 0.0, 1.0, 1.0, 1.0)
	AddSetting(3, 0, "Rage", "Key", "Tecla da furia (codigo)", "Rage key (code)", "Codigo DirectInput. 34 = G, 19 = R, 47 = V, 46 = C.", "DirectInput code. 34 = G, 19 = R, 47 = V, 46 = C.", 1.0, 255.0, 1.0, 34.0)
	AddSetting(3, 0, "Rage", "DurationSeconds", "Duracao da furia (s)", "Rage duration (s)", "Tempo de imunidade.", "How long rage lasts.", 1.0, 20.0, 0.5, 5.0)
	AddSetting(3, 0, "Rage", "CooldownSeconds", "Recarga da furia (s)", "Rage cooldown (s)", "Tempo ate poderes usar outra vez.", "Time until you can use it again.", 5.0, 180.0, 5.0, 30.0)
	AddSetting(3, 0, "Rage", "CostType", "Custo: 0 vida, 1 estamina", "Cost: 0 health, 1 stamina", "Com o que pagas a furia.", "What you pay the rage with.", 0.0, 1.0, 1.0, 0.0)
	AddSetting(3, 0, "Rage", "LifeCostPercent", "Custo da furia (% da vida)", "Rage cost (% of health)", "Percentagem da vida maxima que a furia custa. Nunca te mata.", "Percent of max health rage costs. Never kills you.", 10.0, 30.0, 1.0, 20.0)
	AddSetting(3, 0, "Rage", "ExtraReduction", "Reducao extra de dano - jogador (%)", "Extra damage reduction - player (%)", "Reduz o dano que ainda chega a vida (bloqueado ou nao), por cima de toda a resistencia.", "Cuts the damage that still reaches health (blocked or not), on top of all resistance.", 25.0, 50.0, 1.0, 40.0)
	AddSetting(3, 0, "Rage", "DamageBonus", "Aumento de dano - jogador (%)", "Damage bonus - player (%)", "Aumenta o dano final das tuas armas e magias durante a furia.", "Raises the final damage of your weapons and spells during rage.", 10.0, 30.0, 1.0, 20.0)
	AddSetting(3, 1, "Rage", "StaggerImmune", "Imunidade a stagger durante a furia", "Stagger immunity during rage", "Jogador e NPCs nao sao travados enquanto a furia durar.", "Player and NPCs are not staggered while rage lasts.", 0.0, 1.0, 1.0, 1.0)
	AddSetting(3, 0, "Rage", "NPCExtraReduction", "Reducao extra de dano - NPC (%)", "Extra damage reduction - NPC (%)", "Igual, para os NPCs.", "Same, for NPCs.", 25.0, 50.0, 1.0, 30.0)
	AddSetting(3, 0, "Rage", "NPCDamageBonus", "Aumento de dano - NPC (%)", "Damage bonus - NPC (%)", "Aumenta o dano final dos NPCs em furia.", "Raises the final damage of NPCs in rage.", 10.0, 30.0, 1.0, 10.0)
	AddSetting(3, 1, "Rage", "ZeroStamina", "Furia sem custo de estamina", "Zero stamina cost in rage", "Durante a furia os golpes nao gastam estamina (so vida).", "During rage your swings cost no stamina (only health).", 0.0, 1.0, 1.0, 1.0)
	AddSetting(3, 0, "Rage", "NPCVisual", "Visual da furia dos NPCs", "NPC rage visual", "0 = nenhum, 1 = brilho, 2 = simbolo vermelho, 3 = os dois.", "0 = none, 1 = glow, 2 = red symbol, 3 = both.", 0.0, 3.0, 1.0, 1.0)
	AddSetting(3, 0, "Rage", "PlayerVisual", "Visual da furia do jogador", "Player rage visual", "0 = nenhum, 1 = brilho, 2 = simbolo vermelho, 3 = os dois.", "0 = none, 1 = glow, 2 = red symbol, 3 = both.", 0.0, 3.0, 1.0, 1.0)
	AddSetting(3, 1, "Rage", "NPCs", "NPCs usam furia", "NPCs use rage", "NPCs ativam a furia sozinhos quando perto de quebrar.", "NPCs trigger rage on their own when close to breaking.", 0.0, 1.0, 1.0, 1.0)
	AddSetting(3, 0, "Rage", "NPCPostureTrigger", "NPC: postura acima de", "NPC: posture above", "O NPC ativa quando a postura passa desta fracao.", "The NPC triggers when posture passes this fraction.", 0.3, 1.0, 0.05, 0.8)
	AddSetting(3, 0, "Rage", "NPCPoiseTrigger", "NPC: poise abaixo de", "NPC: poise below", "... ou quando o poise desce abaixo desta fracao.", "... or when poise drops below this fraction.", 0.0, 0.6, 0.05, 0.15)
	AddSetting(3, 0, "Rage", "NPCChancePercent", "NPC: probabilidade (%)", "NPC: chance (%)", "Probabilidade por golpe recebido quando a condicao se cumpre.", "Chance per hit received when the condition is met.", 0.0, 100.0, 5.0, 50.0)
	AddSetting(3, 0, "Rage", "NPCCooldownSeconds", "NPC: recarga (s)", "NPC: cooldown (s)", "Tempo minimo entre duas furias do mesmo NPC.", "Minimum time between two rages of the same NPC.", 5.0, 180.0, 5.0, 45.0)
	AddSetting(3, 0, "Rage", "NPCCostPercent", "NPC: custo (%)", "NPC: cost (%)", "0 = gratis para os NPCs.", "0 = free for NPCs.", 0.0, 50.0, 1.0, 0.0)
	AddSetting(4, 1, "Exhaustion", "Enabled", "Exaustao ligada", "Exhaustion enabled", "Estamina a zero: nao podes atacar nem regenerar por um tempo.", "Stamina at zero: you cannot attack or regenerate for a while.", 0.0, 1.0, 1.0, 1.0)
	AddSetting(4, 0, "Exhaustion", "Seconds", "Exaustao: duracao minima (s)", "Exhaustion: minimum duration (s)", "Tempo minimo sem regenerar estamina.", "Minimum time without stamina regeneration.", 1.0, 10.0, 0.5, 2.0)
	AddSetting(4, 0, "Exhaustion", "SpeedFactor", "Exaustao: velocidade de movimento (x)", "Exhaustion: movement speed (x)", "0.7 = 70% da velocidade enquanto exausto. 1 = sem reducao.", "0.7 = 70% speed while exhausted. 1 = no slowdown.", 0.1, 1.0, 0.05, 0.7)
	AddSetting(4, 0, "Exhaustion", "AttackSpeedFactor", "Exaustao: velocidade de ataque (x)", "Exhaustion: attack speed (x)", "0.7 = ataques a 70% da velocidade enquanto exausto. 1 = sem reducao.", "0.7 = attacks at 70% speed while exhausted. 1 = no slowdown.", 0.1, 1.0, 0.05, 0.7)
	AddSetting(4, 0, "Exhaustion", "BlockedDamageMult", "Exaustao: dano que passa o bloqueio (x)", "Exhaustion: damage through the block (x)", "Exausto, o bloqueio absorve menos: o dano que passa multiplica por isto (1 = sem efeito).", "While exhausted the block absorbs less: damage that gets through is multiplied by this (1 = no effect).", 1.0, 4.0, 0.1, 1.8)
	AddSetting(4, 0, "Exhaustion", "AttackDamageMult", "Exaustao: dano que o jogador causa (x)", "Exhaustion: damage the player deals (x)", "0.4 = o jogador exausto causa 40% do dano (-60%).", "0.4 = the exhausted player deals 40% damage (-60%).", 0.1, 1.0, 0.05, 0.4)
	AddSetting(4, 0, "Exhaustion", "AttackPoiseMult", "Exaustao: poise/postura que causa (x)", "Exhaustion: poise/posture dealt (x)", "Multiplica o dano de poise e postura que o jogador exausto causa.", "Multiplies the poise and posture damage the exhausted player deals.", 0.0, 1.0, 0.05, 0.5)
	AddSetting(4, 0, "Exhaustion", "SelfPoiseLightPercent", "Exaustao: poise perdido por golpe leve (%)", "Exhaustion: poise lost per light swing (%)", "Cada golpe leve exausto gasta esta % do poise maximo do jogador. A 0 ele cambaleia.", "Each exhausted light swing costs this % of the player's max poise. At 0 he stumbles back.", 0.0, 50.0, 1.0, 10.0)
	AddSetting(4, 0, "Exhaustion", "SelfPoiseHeavyPercent", "Exaustao: poise perdido por golpe forte (%)", "Exhaustion: poise lost per heavy swing (%)", "Idem para golpes fortes.", "Same for heavy swings.", 0.0, 80.0, 1.0, 20.0)
	AddSetting(4, 0, "Exhaustion", "PoiseDamageMult", "Exaustao: dano de poise/postura (x)", "Exhaustion: poise/posture damage (x)", "Quem esta exausto leva mais dano de poise e postura.", "Whoever is exhausted takes more poise and posture damage.", 1.0, 3.0, 0.1, 1.5)
	AddSetting(4, 0, "Exhaustion", "RecoverStamina", "Exaustao: estamina recuperada no fim", "Exhaustion: stamina recovered at the end", "Estamina que o jogador recupera quando a exaustao acaba.", "Stamina the player gets back when exhaustion ends.", 0.0, 200.0, 5.0, 50.0)
	AddSetting(4, 0, "Exhaustion", "StopSeconds", "Exaustao: parar para recuperar (s)", "Exhaustion: stop to recover (s)", "Segundos sem atacar para receber a estamina de volta. Quem insiste em bater nao recupera.", "Seconds without swinging to get the stamina back. Keep swinging and you do not recover.", 0.0, 5.0, 0.1, 1.5)
	AddSetting(4, 1, "Exhaustion", "ReenterOnSwing", "Exaustao: reentrar se continuar a bater", "Exhaustion: re-enter if you keep swinging", "O cooldown nao impede nova exaustao enquanto voce continua a bater.", "The cooldown does not stop a new exhaustion while you keep swinging.", 0.0, 1.0, 1.0, 1.0)
	AddSetting(4, 0, "Exhaustion", "NpcStaminaFloorPercent", "NPC: piso de estamina (%)", "NPC: stamina floor (%)", "O dreno de estamina do mod nao leva o NPC abaixo disto (evita que recuem/fujam). Ao chegar la entra em exaustao. 0 = sem piso.", "The mods stamina drain never takes an NPC below this (stops them retreating/fleeing). At the floor it gets exhausted. 0 = no floor.", 0.0, 60.0, 5.0, 25.0)
	AddSetting(4, 0, "Exhaustion", "CooldownSeconds", "Recarga da exaustao (s)", "Exhaustion cooldown (s)", "Tempo minimo entre duas exaustoes.", "Minimum time between two exhaustions.", 0.0, 30.0, 1.0, 8.0)
	AddSetting(4, 1, "Exhaustion", "NPCs", "Exaustao nos NPCs", "Exhaustion on NPCs", "NPCs sem estamina levam stagger pesado.", "NPCs with no stamina get a heavy stagger.", 0.0, 1.0, 1.0, 1.0)
	AddSetting(5, 1, "Stamina", "Enabled", "Custo de estamina por golpe", "Stamina cost per swing", "Liga o custo de estamina por golpe e a influencia da armadura.", "Enables stamina cost per swing and armor influence.", 0.0, 1.0, 1.0, 1.0)
	AddSetting(5, 0, "Stamina", "CombatRegenPercent", "Regeneracao em combate (%)", "Combat regeneration (%)", "Velocidade da regeneracao de estamina em combate, em % da normal.", "Stamina regeneration speed in combat, in % of normal.", 50.0, 400.0, 10.0, 150.0)
	AddSetting(5, 0, "Stamina", "CombatRegenDelayMs", "Pausa depois de bater (ms)", "Pause after attacking (ms)", "Sem regenerar durante este tempo depois de um golpe (so em combate).", "No regeneration for this long after a swing (combat only).", 0.0, 3000.0, 50.0, 600.0)
	AddSetting(5, 0, "Stamina", "CombatRegenBlockFactor", "Regeneracao a bloquear (x)", "Regeneration while blocking (x)", "Multiplicador da regeneracao enquanto seguras o bloqueio.", "Regeneration multiplier while holding block.", 0.0, 1.0, 0.05, 0.4)
	AddSetting(7, 1, "Stagger", "LightEnabled", "Stagger leve ligado", "Light stagger enabled", "Golpe normal sem bloquear da stagger leve.", "A normal unblocked hit causes a light stagger.", 0.0, 1.0, 1.0, 1.0)
	AddSetting(7, 1, "Stagger", "LightPlayer", "Stagger leve no jogador", "Light stagger on player", "Desligado = o jogador nao e travado por golpes leves.", "Off = the player is not locked by light hits.", 0.0, 1.0, 1.0, 1.0)
	AddSetting(7, 0, "Stagger", "LightCooldownMs", "Espaco do stagger leve - NPCs (ms)", "Light stagger spacing - NPCs (ms)", "Tempo minimo entre dois staggers leves.", "Minimum time between two light staggers.", 100.0, 3000.0, 100.0, 700.0)
	AddSetting(7, 0, "Stagger", "PlayerHeavyMagnitude", "Cambalear do jogador (magnitude)", "Player stumble (magnitude)", "Forca do cambalear para tras quando o poise ou a postura do jogador quebra. Sem queda nem bleedout.", "Strength of the backward stumble when the player's poise or posture breaks. No knockdown or bleedout.", 0.1, 10.0, 0.1, 1.0)
	AddSetting(7, 0, "Stagger", "PlayerImmuneAfterSeconds", "Imunidade do jogador apos stagger (s)", "Player immunity after stagger (s)", "Depois de levares um stagger do jogo, ficas este tempo sem o levar de novo (para bloquear ou esquivar). 0 = desligado. Staggers pesados do mod passam sempre.", "After the game staggers you, you cannot be staggered again for this long (to block or dodge). 0 = off. The mod heavy staggers always go through.", 0.0, 5.0, 0.1, 1.5)
	AddSetting(7, 1, "Stagger", "MediumOnPowerAttack", "Stagger medio em golpe forte", "Medium stagger on power attack", "Golpe forte ou de escudo sem bloquear da stagger medio.", "An unblocked power attack or bash causes a medium stagger.", 0.0, 1.0, 1.0, 1.0)
	AddSetting(7, 1, "Knockback", "Enabled", "Empurrao ligado", "Knockback enabled", "Empurrao no stagger pesado, so em condicoes especificas.", "Knockback on heavy stagger, only in specific conditions.", 0.0, 1.0, 1.0, 1.0)
	AddSetting(7, 0, "Knockback", "Force", "Forca do empurrao", "Knockback force", "0 = sem empurrao.", "0 = no knockback.", 0.0, 5.0, 0.1, 1.0)
	AddSetting(7, 1, "Knockback", "OnPowerAttack", "Quando golpe forte", "On power attack", "Inclui o carregado e o de corrida.", "Includes charged and sprinting attacks.", 0.0, 1.0, 1.0, 1.0)
	AddSetting(7, 0, "Knockback", "GiantMassMin", "Massa minima de gigante", "Giant minimum mass", "Massa da raca a partir da qual conta como gigante.", "Race mass from which it counts as giant.", 1.0, 10.0, 0.5, 3.0)
	AddSetting(7, 1, "Knockback", "OnHeavyWeapon", "Quando arma pesada (golpe normal)", "On heavy weapon (normal hit)", "Cuidado: deixa as armas grandes muito fortes.", "Careful: makes big weapons very strong.", 0.0, 1.0, 1.0, 0.0)
	AddSetting(8, 0, "Stamina", "TypeMult0", "Custo: Punhos (x)", "Cost: Fists (x)", "Multiplicador do custo de estamina para este tipo de arma.", "Stamina cost multiplier for this weapon type.", 0.0, 4.0, 0.1, 0.6)
	AddSetting(8, 0, "Stamina", "TypeMult1", "Custo: Espada 1 mao (x)", "Cost: 1H Sword (x)", "Multiplicador do custo de estamina para este tipo de arma.", "Stamina cost multiplier for this weapon type.", 0.0, 4.0, 0.1, 1.0)
	AddSetting(8, 0, "Stamina", "TypeMult2", "Custo: Adaga (x)", "Cost: Dagger (x)", "Multiplicador do custo de estamina para este tipo de arma.", "Stamina cost multiplier for this weapon type.", 0.0, 4.0, 0.1, 0.6)
	AddSetting(8, 0, "Stamina", "TypeMult3", "Custo: Machado 1 mao (x)", "Cost: 1H Axe (x)", "Multiplicador do custo de estamina para este tipo de arma.", "Stamina cost multiplier for this weapon type.", 0.0, 4.0, 0.1, 1.2)
	AddSetting(8, 0, "Stamina", "TypeMult4", "Custo: Maca 1 mao (x)", "Cost: 1H Mace (x)", "Multiplicador do custo de estamina para este tipo de arma.", "Stamina cost multiplier for this weapon type.", 0.0, 4.0, 0.1, 1.3)
	AddSetting(8, 0, "Stamina", "TypeMult5", "Custo: Espada 2 maos (x)", "Cost: 2H Sword (x)", "Multiplicador do custo de estamina para este tipo de arma.", "Stamina cost multiplier for this weapon type.", 0.0, 4.0, 0.1, 1.6)
	AddSetting(8, 0, "Stamina", "TypeMult6", "Custo: Machado/Martelo 2 maos (x)", "Cost: 2H Axe/Hammer (x)", "Multiplicador do custo de estamina para este tipo de arma.", "Stamina cost multiplier for this weapon type.", 0.0, 4.0, 0.1, 1.8)
	AddSetting(8, 0, "Stamina", "TypeMult7", "Custo: Arco (x)", "Cost: Bow (x)", "Multiplicador do custo de estamina para este tipo de arma.", "Stamina cost multiplier for this weapon type.", 0.0, 4.0, 0.1, 0.8)
	AddSetting(8, 0, "Stamina", "TypeMult8", "Custo: Cajado (x)", "Cost: Staff (x)", "Multiplicador do custo de estamina para este tipo de arma.", "Stamina cost multiplier for this weapon type.", 0.0, 4.0, 0.1, 0.6)
	AddSetting(8, 0, "Stamina", "TypeMult9", "Custo: Feitico (x)", "Cost: Spell (x)", "Multiplicador do custo de estamina para este tipo de arma.", "Stamina cost multiplier for this weapon type.", 0.0, 4.0, 0.1, 0.0)
	AddSetting(8, 0, "Stamina", "TypeMult10", "Custo: Escudo (x)", "Cost: Shield (x)", "Multiplicador do custo de estamina para este tipo de arma.", "Stamina cost multiplier for this weapon type.", 0.0, 4.0, 0.1, 1.0)
	AddSetting(10, 0, "TrueHUD", "Bar", "Barra do TrueHUD", "TrueHUD bar", "0 = poise a descer (recomendado), 1 = postura, 2 = risco.", "0 = poise, 1 = posture, 2 = risk (whichever is closest to breaking).", 0.0, 2.0, 1.0, 0.0)
	AddSetting(10, 0, "TrueHUD", "PoiseWarnFraction", "Aviso de poise baixo (fracao)", "Low poise warning (fraction)", "A barra pisca quando o poise desce abaixo disto. 0 = desligado.", "The bar flashes when poise drops below this. 0 = off.", 0.0, 0.8, 0.05, 0.3)
	AddSetting(10, 1, "TrueHUD", "FlashOnBreak", "Barra pisca ao quebrar", "Bar flashes on break", "", "", 0.0, 1.0, 1.0, 1.0)
	AddSetting(11, 1, "General", "Player", "Poise e postura no jogador", "Poise and posture on player", "", "", 0.0, 1.0, 1.0, 1.0)
	AddSetting(11, 1, "General", "NPCs", "Poise e postura nos NPCs", "Poise and posture on NPCs", "", "", 0.0, 1.0, 1.0, 1.0)
	AddSetting(13, 1, "HUD", "Enabled", "Barras proprias (postura e furia)", "Own bars (posture and rage)", "Mostra a postura e a furia do jogador e do alvo. Precisa do NahIDWinHUD.swf em Data/Interface.", "Shows posture and rage for the player and the target. Needs NahIDWinHUD.swf in Data/Interface.", 0.0, 1.0, 1.0, 1.0)
	AddSetting(13, 1, "HUD", "Player", "Barras do jogador", "Player bars", "", "", 0.0, 1.0, 1.0, 1.0)
	AddSetting(13, 1, "HUD", "PlayerAlways", "Barras do jogador sempre visiveis", "Player bars always visible", "Desligado = so aparecem em combate ou com a furia ativa.", "Off = only shown in combat or while rage is active.", 0.0, 1.0, 1.0, 0.0)
	AddSetting(13, 1, "HUD", "Target", "Barras do alvo (mira)", "Target bars (lock-on)", "Mostra por baixo da barra de vida do inimigo que esta na mira.", "Shown under the health bar of the locked-on enemy.", 0.0, 1.0, 1.0, 1.0)
	AddSetting(13, 1, "HUD", "IconsAlways", "Losangos e simbolo sempre visiveis", "Lives and Supreme icons always visible", "Mostra as vidas extra e o Supremo Rage junto as barras, mesmo fora de combate.", "Shows extra lives and Supreme Rage next to the bars, even out of combat.", 0.0, 1.0, 1.0, 1.0)
	AddSetting(13, 1, "HUD", "RageIcon", "Icone da furia ativa", "Active rage icon", "Losango piscante ao lado das barras quando a furia esta ativa.", "Flashing diamond next to the bars while rage is active.", 0.0, 1.0, 1.0, 1.0)
	AddSetting(13, 2, "HUD", "BarStyle", "Estilo das barras", "Bar style", "Plana ou estilo Sekiro (enche dos dois lados para o centro).", "Flat or Sekiro style (fills from both sides toward the center).", 0.0, 1.0, 1.0, 1.0)
	AddSetting(13, 2, "HUD", "PlayerPosH", "Jogador: posicao horizontal", "Player: horizontal position", "Esquerda, centro ou direita do ecra.", "Left, center or right of the screen.", 0.0, 2.0, 1.0, 0.0)
	AddSetting(13, 2, "HUD", "PlayerPosV", "Jogador: posicao vertical", "Player: vertical position", "Cima, centro ou baixo do ecra.", "Top, center or bottom of the screen.", 0.0, 2.0, 1.0, 2.0)
	AddSetting(13, 0, "HUD", "PlayerWidth", "Jogador: largura", "Player: width", "", "", 50.0, 600.0, 5.0, 200.0)
	AddSetting(13, 2, "HUD", "TargetPosH", "Alvo: posicao horizontal", "Target: horizontal position", "Esquerda, centro ou direita do ecra.", "Left, center or right of the screen.", 0.0, 2.0, 1.0, 1.0)
	AddSetting(13, 2, "HUD", "TargetPosV", "Alvo: posicao vertical", "Target: vertical position", "Cima, centro ou baixo do ecra.", "Top, center or bottom of the screen.", 0.0, 2.0, 1.0, 0.0)
	AddSetting(13, 0, "HUD", "TargetWidth", "Alvo: largura (0 = 200)", "Target: width (0 = 200)", "", "", 0.0, 600.0, 5.0, 0.0)
	AddSetting(13, 1, "HUD", "TargetAnchor", "Alvo: seguir a barra de vida do jogo", "Target: follow the game health bar", "Ligado = por baixo do nome do inimigo (se a barra do jogo estiver visivel).", "On = under the enemy name (if the game bar is visible).", 0.0, 1.0, 1.0, 0.0)
	AddSetting(13, 0, "HUD", "TargetShiftX", "Alvo: deslocar na horizontal", "Target: shift horizontally", "Move as barras do alvo para os lados (pixels). Usado quando NAO segue a barra de vida do jogo.", "Moves the target bars sideways (pixels). Used when NOT following the game health bar.", -400.0, 400.0, 5.0, 0.0)
	AddSetting(13, 0, "HUD", "TargetShiftY", "Alvo: deslocar na vertical", "Target: shift vertically", "Altura das barras do alvo (pixels, + desce). Use para afastar da barra de vida dos bosses (Centro + Topo).", "Height of the target bars (pixels, + moves down). Use to clear the boss health bar (Center + Top).", -300.0, 500.0, 5.0, 55.0)
	AddSetting(13, 0, "HUD", "TargetOffsetX", "Alvo (seguindo a vida): horizontal", "Target (following health): horizontal", "Deslocamento quando segue a barra de vida do jogo.", "Offset when following the game health bar.", -300.0, 300.0, 2.0, 0.0)
	AddSetting(13, 0, "HUD", "TargetOffsetY", "Alvo (seguindo a vida): vertical", "Target (following health): vertical", "Deslocamento vertical quando segue a barra de vida do jogo.", "Vertical offset when following the game health bar.", -200.0, 300.0, 2.0, 22.0)
	AddSetting(14, 1, "Lives", "Enabled", "Vidas extra ligadas", "Extra lives enabled", "Quando morreres, usas uma vida extra se tiveres alguma. Enchem ao dormir numa cama.", "When you would die, an extra life is used if you have one. They refill when you sleep in a bed.", 0.0, 1.0, 1.0, 1.0)
	AddSetting(14, 0, "Lives", "Level2", "Nivel da 2a vida", "Level of the 2nd life", "Nivel do jogador para desbloquear a segunda vida.", "Player level to unlock the second life.", 1.0, 81.0, 1.0, 30.0)
	AddSetting(14, 0, "Lives", "Level3", "Nivel da 3a vida", "Level of the 3rd life", "Nivel do jogador para desbloquear a terceira vida.", "Player level to unlock the third life.", 1.0, 81.0, 1.0, 60.0)
	AddSetting(14, 0, "Lives", "HealthPercent", "Vida ao voltar (%)", "Health on return (%)", "Percentagem da vida maxima com que voltas.", "Percent of max health you return with.", 10.0, 100.0, 5.0, 50.0)
	AddSetting(14, 0, "Lives", "GoldLossPercent", "Ouro perdido por morte (%)", "Gold lost per death (%)", "Percentagem do ouro que perdes ao usar uma vida. Sem ouro, nao perdes nada.", "Percent of your gold lost when a life is used. No gold, nothing lost.", 0.0, 50.0, 1.0, 25.0)
	AddSetting(14, 0, "Lives", "InvulnSeconds", "Invulnerabilidade apos voltar (s)", "Invulnerability after return (s)", "Segundos sem levar dano depois de usares uma vida.", "Seconds without damage after a life is used.", 0.0, 10.0, 0.5, 3.0)
	AddSetting(16, 1, "Bosses", "Enabled", "Bosses com 2 vidas", "Bosses with 2 lives", "NPC unico de nivel alto: ao gastar a 1a vida cai em bleedout e volta com a vida cheia.", "High-level unique NPC: when the 1st life ends it goes into bleedout and returns with full health.", 0.0, 1.0, 1.0, 1.0)
	AddSetting(16, 0, "Bosses", "LevelMargin", "Bosses: niveis acima do jogador", "Bosses: levels above player", "Inimigo com este numero de niveis acima do teu (ou mais) vira boss.", "An enemy this many levels above yours (or more) becomes a boss.", 3.0, 20.0, 1.0, 7.0)
	AddSetting(16, 0, "Bosses", "PoiseMult", "Bosses: poise (x)", "Bosses: poise (x)", "Multiplicador do poise dos bosses.", "Poise multiplier for bosses.", 0.5, 4.0, 0.1, 1.5)
	AddSetting(16, 0, "Bosses", "PostureMult", "Bosses: postura (x)", "Bosses: posture (x)", "Multiplicador da postura dos bosses.", "Posture multiplier for bosses.", 0.5, 4.0, 0.1, 1.5)
	AddSetting(16, 0, "BigCreatures", "PoiseMult", "Gigantes/dragoes: poise (x)", "Giants/dragons: poise (x)", "Multiplicador do poise das criaturas grandes (massa alta).", "Poise multiplier for large creatures (high mass).", 0.5, 4.0, 0.1, 1.5)
	AddSetting(16, 0, "BigCreatures", "RageDurationMult", "Gigantes/dragoes: duracao da furia (x)", "Giants/dragons: rage duration (x)", "Multiplica a duracao da furia das criaturas grandes. Nao aumenta o dano que levam.", "Multiplies rage duration of large creatures. Does not increase damage they take.", 1.0, 3.0, 0.1, 1.5)
	AddSetting(16, 0, "BigCreatures", "PostureMult", "Gigantes/dragoes: postura (x)", "Giants/dragons: posture (x)", "Multiplicador da postura das criaturas grandes.", "Posture multiplier for large creatures.", 0.5, 4.0, 0.1, 1.5)
	AddSetting(16, 1, "Perilous", "Enabled", "Ataque perigoso (bosses/gigantes)", "Perilous attack (bosses/giants)", "Aviso (simbolo) e ataque que ignora o bloqueio: esquiva ou faz parry. O parry da muita postura ao atacante.", "Warning (symbol) and an attack that ignores block: dodge or parry. A parry deals big posture damage to the attacker.", 0.0, 1.0, 1.0, 1.0)
	AddSetting(16, 0, "Perilous", "ChancePercent", "Ataque perigoso: chance (%)", "Perilous: chance (%)", "Probabilidade de um ataque de boss/gigante ser perigoso.", "Chance that a boss/giant attack is perilous.", 0.0, 100.0, 5.0, 25.0)
	AddSetting(16, 0, "Perilous", "ParryPosture", "Ataque perigoso: postura no parry", "Perilous: parry posture", "Postura extra (fracao do maximo) que o atacante leva se fizeres parry.", "Extra posture (fraction of max) the attacker takes if you parry.", 0.1, 1.0, 0.05, 0.5)
	AddSetting(19, 1, "Magic", "DeflectEnabled", "Deflexao de magia", "Magic deflect", "Depois de um parry numa magia, enquanto seguras o bloqueio a magia e devolvida ao conjurador.", "After parrying a spell, while you hold block the spell is reflected to the caster.", 0.0, 1.0, 1.0, 1.0)
	AddSetting(19, 0, "Magic", "DotPoiseMult", "Magia continua: poise/postura (x)", "Continuous magic: poise/posture (x)", "Fracao do poise/postura de magia continua (Chamas...). O golpe conta no maximo 1 vez por segundo.", "Fraction of poise/posture from continuous magic (Flames...). Counts at most once per second.", 0.0, 1.0, 0.05, 0.5)
	AddSetting(20, 1, "Stagger", "Behavior", "Eventos de behavior (POISE)", "Behavior events (POISE)", "Ligado: usa as animacoes do mod Nemesis NahIDWin Behavior (poise_*). So ligar depois de instala-lo e rodar o Nemesis. Desligado: stagger vanilla.", "On: uses the animations of the NahIDWin Behavior Nemesis mod (poise_*). Turn on only after installing it and running Nemesis. Off: vanilla stagger.", 0.0, 1.0, 1.0, 0.0)
	AddSetting(14, 1, "Execution", "Enabled", "Execucao garantida", "Guaranteed execution", "Acertar uma arma num alvo com a postura quebrada executa-o (feitico do Inpa). Bosses so depois da 1a vida.", "Hitting a posture-broken target with a weapon executes it (Inpa spell). Bosses only after their 1st life.", 0.0, 1.0, 1.0, 1.0)
	AddSetting(14, 1, "Execution", "KillBigCreatures", "Executar gigantes/dragoes", "Execute giants/dragons", "Criaturas grandes morrem de vez (sem animacao de execucao).", "Large creatures die outright (no execution animation).", 0.0, 1.0, 1.0, 1.0)
	AddSetting(14, 1, "Execution", "MeleeOnly", "Executar so com golpe corpo a corpo", "Execute only on melee hits", "Flechas e bestas nunca executam.", "Arrows and crossbow bolts never execute.", 0.0, 1.0, 1.0, 1.0)
	AddSetting(14, 0, "Execution", "Range", "Distancia maxima da execucao", "Maximum execution range", "Distancia (unidades do jogo) maxima entre voce e o alvo para executar. 300 = cerca de 4 m.", "Maximum distance (game units) between you and the target. 300 = about 4 m.", 100.0, 1000.0, 25.0, 300.0)
	AddSetting(14, 0, "Execution", "Chance", "Chance de execucao (%)", "Execution chance (%)", "Chance de executar a cada golpe normal num alvo em bleedout.", "Chance to execute on each normal hit on a bleeding-out target.", 0.0, 100.0, 5.0, 60.0)
	AddSetting(14, 0, "Execution", "PowerAttackChance", "Chance com ataque de poder (%)", "Power attack chance (%)", "Chance de executar com um ataque de poder.", "Chance to execute with a power attack.", 0.0, 100.0, 5.0, 100.0)
	AddSetting(15, 1, "Supreme", "Enabled", "Supremo Rage ligado", "Supreme Rage enabled", "Aura de fogo: tudo o que a furia da, mais dano em area. Cooldown muito longo.", "Fire aura: everything rage gives, plus area damage. Very long cooldown.", 0.0, 1.0, 1.0, 1.0)
	AddSetting(15, 0, "Supreme", "Key", "Tecla do Supremo Rage (codigo)", "Supreme Rage key (code)", "Codigo DirectInput. 35 = H. Prime outra vez para desligar.", "DirectInput code. 35 = H. Press again to turn off.", 1.0, 255.0, 1.0, 35.0)
	AddSetting(15, 0, "Supreme", "DurationSeconds", "Duracao (s)", "Duration (s)", "", "", 3.0, 30.0, 1.0, 10.0)
	AddSetting(15, 0, "Supreme", "CooldownSeconds", "Recarga (s)", "Cooldown (s)", "Tempo ate poderes usar outra vez. O jogador tem de saber quando usar.", "Time until it can be used again.", 60.0, 1200.0, 10.0, 500.0)
	AddSetting(15, 0, "Supreme", "CostPercentPerSecond", "Custo (% da vida por segundo)", "Cost (% of health per second)", "Nunca te mata.", "Never kills you.", 1.0, 3.0, 0.5, 2.0)
	AddSetting(12, 1, "Block", "DrainEnabled", "Bloqueio gasta estamina do atacante", "Block drains attacker stamina", "Bloqueio normal (sem parry) gasta estamina do atacante. Sem stagger.", "Normal block (no parry) drains the attacker's stamina. No stagger.", 0.0, 1.0, 1.0, 1.0)
	AddSetting(12, 0, "Block", "AttackerStamina", "Estamina do atacante por golpe", "Attacker stamina per hit", "Estamina que o atacante perde por golpe bloqueado.", "Stamina the attacker loses per blocked hit.", 0.0, 60.0, 1.0, 10.0)
	; ---- v0.24 rows ----
	AddSetting(5, 0, "Stamina", "SwingBase", "Custo base por golpe", "Base cost per swing", "Custo fixo de cada golpe, antes do peso.", "Fixed cost of each swing before weight.", 0.0, 20.0, 0.25, 5.0)
	AddSetting(5, 0, "Stamina", "SwingPerWeight", "Custo por peso da arma", "Cost per weapon weight", "Custo extra por unidade de peso da arma.", "Extra cost per unit of weapon weight.", 0.0, 3.0, 0.05, 0.75)
	AddSetting(5, 0, "Stamina", "PowerMult", "Golpe forte (x)", "Power attack (x)", "Multiplicador do custo do golpe forte.", "Cost multiplier of power attacks.", 1.0, 4.0, 0.1, 2.0)
	AddSetting(5, 0, "Stamina", "BashWeightMult", "Bash de escudo (x peso)", "Shield bash (x shield weight)", "Multiplicador do custo do bash, sobre o peso do escudo.", "Bash cost multiplier on shield weight.", 0.0, 4.0, 0.05, 1.35)
	AddSetting(5, 0, "Stamina", "BlockCostFactor", "Custo do bloqueio (x dano)", "Block cost (x damage)", "Fracao do dano bloqueado que vira custo de estamina.", "Fraction of blocked damage paid in stamina.", 0.0, 1.0, 0.01, 0.28)
	AddSetting(5, 0, "Stamina", "BlockCostShieldMult", "Custo do bloqueio com escudo (x)", "Block cost with shield (x)", "Multiplicador do custo ao bloquear com escudo.", "Block cost multiplier when using a shield.", 0.1, 1.0, 0.05, 0.6)
	AddSetting(5, 0, "Stamina", "GuardBreakPosturePercent", "Guarda quebrada: postura imediata (%)", "Guard break: immediate posture (%)", "0 = nenhuma. A guarda quebrada quebra o poise e multiplica o dano de postura durante o stagger lock; nao quebra a postura sozinha.", "Posture lost when stamina runs out while blocking.", 0.0, 100.0, 5.0, 20.0)
	AddSetting(5, 0, "Stamina", "LowZoneFraction", "Zona baixa: abaixo de (fracao)", "Low zone: below (fraction)", "Abaixo desta fracao da estamina a regeneracao piora e levas mais dano de poise.", "Below this stamina fraction regen worsens and poise damage rises.", 0.0, 0.6, 0.05, 0.25)
	AddSetting(5, 0, "Stamina", "LowZoneRegenMult", "Zona baixa: regeneracao (x)", "Low zone: regen (x)", "Multiplicador da regeneracao na zona baixa.", "Regen multiplier in the low zone.", 0.1, 1.0, 0.05, 0.7)
	AddSetting(5, 0, "Stamina", "LowZonePoiseDamageMult", "Zona baixa: dano de poise (x)", "Low zone: poise damage (x)", "Multiplicador do dano de poise na zona baixa.", "Poise damage multiplier in the low zone.", 1.0, 2.0, 0.05, 1.2)
	AddSetting(5, 0, "Stamina", "PoiseMidRegenMult", "Poise < 50%: regeneracao (x)", "Poise < 50%: regen (x)", "Regeneracao de estamina com o poise entre 50% e 25%.", "Stamina regen while poise is between 50% and 25%.", 0.1, 1.0, 0.05, 0.8)
	AddSetting(5, 0, "Stamina", "PoiseLowRegenMult", "Poise < 25%: regeneracao (x)", "Poise < 25%: regen (x)", "Regeneracao de estamina com o poise abaixo de 25%.", "Stamina regen while poise is below 25%.", 0.0, 1.0, 0.05, 0.6)
	AddSetting(5, 0, "Parry", "DefenderStaminaRecoverFraction", "Parry devolve estamina (fracao)", "Parry returns stamina (fraction)", "Fracao da estamina maxima devolvida num parry.", "Fraction of max stamina returned by a parry.", 0.0, 1.0, 0.05, 0.30)
	AddSetting(9, 1, "Stamina", "ClassRegen", "Armadura abranda a regeneracao", "Armor slows regeneration", "Cada classe de armadura reduz a regeneracao de estamina.", "Each armor class reduces stamina regeneration.", 0.0, 1.0, 1.0, 1.0)
	AddSetting(9, 0, "Stamina", "ClassRegenPenalty", "Penalidade por classe", "Penalty per class", "Fracao de regeneracao perdida por classe de armadura.", "Regeneration fraction lost per armor class.", 0.0, 0.3, 0.01, 0.08)
	AddSetting(4, 0, "Exhaustion", "MaxSeconds", "Exaustao: duracao maxima (s)", "Exhaustion: maximum duration (s)", "A exaustao acaba aqui mesmo que a estamina nao chegue ao alvo.", "Exhaustion ends here even if stamina has not reached the target.", 2.0, 20.0, 0.5, 7.0)
	AddSetting(4, 0, "Exhaustion", "TargetPercent", "Exaustao: estamina alvo (%)", "Exhaustion: target stamina (%)", "Depois do tempo minimo, a exaustao acaba quando a estamina chega a esta percentagem.", "After the minimum time, exhaustion ends when stamina reaches this percent.", 10.0, 100.0, 5.0, 35.0)
	AddSetting(4, 0, "Exhaustion", "RegenFactor", "Exaustao: regeneracao (x)", "Exhaustion: regen (x)", "Multiplicador da regeneracao durante a exaustao.", "Regen multiplier while exhausted.", 0.0, 1.0, 0.05, 0.7)
	AddSetting(17, 0, "StaggerLock", "SecondsNpc", "Staggerlock - NPC (s)", "Staggerlock - NPC (s)", "Segundos que um NPC fica preso apos o poise chegar a zero.", "Seconds an NPC stays locked after poise reaches zero.", 0.5, 8.0, 0.5, 3.0)
	AddSetting(17, 0, "StaggerLock", "SecondsPlayer", "Staggerlock - jogador (s)", "Staggerlock - player (s)", "Segundos que o jogador fica preso apos o poise chegar a zero.", "Seconds the player stays locked after poise reaches zero.", 0.5, 8.0, 0.5, 2.0)
	AddSetting(17, 0, "StaggerLock", "PostureMult", "Staggerlock: dano de postura (x)", "Staggerlock: posture damage (x)", "Multiplicador do dano de postura durante o staggerlock.", "Posture damage multiplier during staggerlock.", 1.0, 6.0, 0.25, 3.0)
	AddSetting(17, 0, "GuardBreak", "DamageMult", "Dano extra na quebra de guarda (x)", "Guard break extra damage (x)", "Multiplicador do dano de vida enquanto a guarda esta quebrada (staggerlock). 1.0 = sem extra.", "Health damage multiplier while the guard is broken (staggerlock). 1.0 = no extra.", 1.0, 3.0, 0.05, 1.1)
	AddSetting(17, 0, "StaggerLock", "PostureCapPercent", "Limite de postura por golpe no lock (%)", "Posture per hit cap in lock (%)", "Maximo de postura (em % da barra) que um unico golpe pode somar durante o staggerlock. Evita quebrar a postura de uma vez.", "Max posture (in % of the bar) a single hit can add during staggerlock. Stops one hit from breaking posture.", 0.0, 50.0, 1.0, 15.0)
	AddSetting(17, 0, "Stagger", "LightCooldownPlayerMs", "Stagger leve - jogador: intervalo (ms)", "Light stagger - player: spacing (ms)", "Intervalo minimo entre staggers leves no jogador.", "Minimum spacing between light staggers on the player.", 300.0, 5000.0, 100.0, 1500.0)
	AddSetting(19, 0, "Magic", "DeflectCostWeapon", "Deflexao: custo de magia - arma", "Deflect: magicka cost - weapon", "Magicka por ponto de dano defletido com arma.", "Magicka per point of damage deflected with a weapon.", 0.0, 2.0, 0.05, 0.6)
	AddSetting(19, 0, "Magic", "DeflectCostShield", "Deflexao: custo de magia - escudo", "Deflect: magicka cost - shield", "Magicka por ponto de dano defletido com escudo.", "Magicka per point of damage deflected with a shield.", 0.0, 2.0, 0.05, 0.4)
	AddSetting(19, 0, "Magic", "DeflectReturnWeapon", "Deflexao: devolvido - arma", "Deflect: returned - weapon", "Fracao do dano defletido devolvida ao atacante (arma).", "Fraction of deflected damage returned to the attacker (weapon).", 0.0, 2.0, 0.05, 0.7)
EndFunction

; ---------------- tabs / presets ----------------
int Function TabOfBlk(int b)
	if b == 11 || b == 14 || b == 20
		return 0
	elseif b == 4 || b == 5 || b == 8 || b == 9
		return 1
	elseif b == 1 || b == 2
		return 2
	elseif b == 7 || b == 12 || b == 17 || b == 18 || b == 19
		return 3
	endif
	return 4
EndFunction

bool Function UsesPreset(int blk)
	return blk != 10 && blk != 13 && TabOfBlk(blk) >= 1
EndFunction

bool Function TabManual(int tab)
	return NahIDWinNative.IniGetF("Menu", "Mode" + tab, 0.0) > 0.5
EndFunction

int Function TabLevel(int tab)
	return NahIDWinNative.IniGetF("Menu", "Level" + tab, 1.0) as int
EndFunction

string Function LevelName(int l)
	if l <= 0
		return Tr("Easy", "Facil")
	elseif l == 1
		return Tr("Normal (recommended)", "Normal (recomendado)")
	endif
	return "Hard"
EndFunction

string Function MKey(int i)
	return sSec[i] + "_" + sKey[i]
EndFunction

float Function RowVal(int i)
	float live = NahIDWinNative.IniGetF(sSec[i], sKey[i], sDef[i])
	if UsesPreset(sBlk[i]) && TabManual(TabOfBlk(sBlk[i]))
		return NahIDWinNative.IniGetF("Manual", MKey(i), live)
	endif
	return live
EndFunction

Function SetRow(int i, float v)
	NahIDWinNative.IniSetF(sSec[i], sKey[i], v)
	NahIDWinNative.IniSetF("Manual", MKey(i), v)
EndFunction

int pLvl = 1
Function PV(string sec, string key, float e, float n, float h)
	float v = n
	if pLvl <= 0
		v = e
	elseif pLvl >= 2
		v = h
	endif
	NahIDWinNative.IniSetF(sec, key, v)
EndFunction

; Preset tables: Easy / Normal / Hard. Hard = the values of v0.23.1.
Function ApplyPreset(int tab, int lvl)
	pLvl = lvl
	if tab == 1
		PV("NpcStamina", "SwingPercent", 8.0, 6.0, 4.5)
		PV("NpcStamina", "BlockPercent", 32.0, 22.0, 14.0)
		PV("Stamina", "SwingBase", 4.0, 5.0, 6.0)
		PV("Stamina", "SwingPerWeight", 0.6, 0.75, 0.9)
		PV("Stamina", "PowerMult", 1.8, 2.0, 2.2)
		PV("Stamina", "BashWeightMult", 1.2, 1.35, 1.5)
		PV("Stamina", "BlockCostFactor", 0.20, 0.28, 0.35)
		PV("Stamina", "GuardBreakPosturePercent", 0.0, 0.0, 0.0)
		PV("Stamina", "LowZoneRegenMult", 0.8, 0.7, 0.6)
		PV("Stamina", "LowZonePoiseDamageMult", 1.1, 1.2, 1.25)
		PV("Stamina", "PoiseMidRegenMult", 0.85, 0.8, 0.75)
		PV("Stamina", "PoiseLowRegenMult", 0.7, 0.6, 0.5)
		PV("Stamina", "ClassRegenPenalty", 0.05, 0.08, 0.10)
		PV("Exhaustion", "AttackDamageMult", 0.55, 0.4, 0.3)
		PV("Exhaustion", "SelfPoiseLightPercent", 6.0, 10.0, 14.0)
		PV("Exhaustion", "SelfPoiseHeavyPercent", 12.0, 20.0, 28.0)
		PV("Posture", "PlayerBrokenSeconds", 3.0, 4.0, 5.0)
		PV("Posture", "PlayerBrokenDamageMult", 1.5, 2.0, 2.5)
		PV("Exhaustion", "SpeedFactor", 0.8, 0.7, 0.6)
		PV("Exhaustion", "AttackSpeedFactor", 0.8, 0.7, 0.6)
		PV("Exhaustion", "BlockedDamageMult", 1.4, 1.8, 2.2)
		PV("Exhaustion", "Seconds", 1.5, 2.0, 2.0)
		PV("Exhaustion", "MaxSeconds", 6.0, 7.0, 8.0)
		PV("Exhaustion", "TargetPercent", 30.0, 35.0, 40.0)
		PV("Exhaustion", "RegenFactor", 0.8, 0.7, 0.6)
		PV("Parry", "DefenderStaminaRecoverFraction", 0.50, 0.30, 0.15)
	elseif tab == 2
		PV("Poise", "MaxScalePlayer", 6.0, 5.0, 4.5)
		PV("Poise", "MaxScaleNPC", 5.5, 6.5, 8.0)
		PV("Poise", "NPCTakenMult", 3.5, 3.1, 2.75)
		PV("Damage", "BlockedMultNpc", 0.85, 0.65, 0.40)
		PV("Damage", "CreatureDamageMult", 0.45, 0.55, 0.70)
		PV("Damage", "GiantDamageMult", 0.30, 0.40, 0.55)
		PV("Posture", "BlockedMultNpc", 0.90, 0.70, 0.45)
		PV("Poise", "PlayerTakenMult", 1.2, 1.35, 1.5)
		PV("Poise", "RegenSeconds", 8.0, 9.0, 10.0)
		PV("Poise", "RegenDelaySeconds", 2.0, 3.0, 3.5)
		PV("Damage", "BlockedMult", 0.10, 0.12, 0.15)
		PV("Posture", "ScalePlayer", 6.0, 5.5, 5.0)
		PV("Posture", "ScaleNPC", 4.5, 4.75, 5.0)
		PV("Posture", "BlockedMult", 0.09, 0.105, 0.12)
		PV("Posture", "BleedOutSeconds", 5.0, 4.5, 4.0)
		PV("Posture", "BleedOutImmuneSeconds", 4.0, 4.5, 5.0)
	elseif tab == 3
		PV("StaggerLock", "SecondsNpc", 4.0, 3.5, 3.0)
		PV("StaggerLock", "SecondsPlayer", 1.5, 1.75, 2.0)
		PV("StaggerLock", "PostureMult", 2.2, 1.8, 1.5)
		PV("StaggerLock", "PostureCapPercent", 18.0, 15.0, 12.0)
		PV("GuardBreak", "DamageMult", 1.25, 1.10, 1.0)
		PV("Stagger", "PlayerImmuneAfterSeconds", 2.0, 1.75, 1.5)
		PV("Stagger", "LightCooldownMs", 500.0, 600.0, 700.0)
		PV("Stagger", "LightCooldownPlayerMs", 2200.0, 1800.0, 1500.0)
		PV("Knockback", "Force", 0.8, 0.9, 1.0)
		PV("Magic", "DeflectCostWeapon", 0.5, 0.55, 0.6)
		PV("Magic", "DeflectCostShield", 0.3, 0.35, 0.4)
		PV("Magic", "DeflectReturnWeapon", 0.9, 0.8, 0.7)
		PV("Block", "AttackerStamina", 14.0, 12.0, 10.0)
	elseif tab == 4
		PV("Rage", "CooldownSeconds", 20.0, 25.0, 30.0)
		PV("Rage", "LifeCostPercent", 15.0, 18.0, 20.0)
		PV("Rage", "DurationSeconds", 6.0, 5.5, 5.0)
		PV("Rage", "NPCChancePercent", 35.0, 45.0, 50.0)
		PV("Rage", "NPCCooldownSeconds", 60.0, 52.0, 45.0)
		PV("Rage", "NPCExtraReduction", 20.0, 25.0, 30.0)
		PV("Rage", "NPCDamageBonus", 5.0, 8.0, 10.0)
		PV("Supreme", "CooldownSeconds", 350.0, 425.0, 500.0)
		PV("Supreme", "CostPercentPerSecond", 1.5, 2.0, 2.0)
		PV("Supreme", "DurationSeconds", 8.0, 6.0, 5.0)
		PV("Bosses", "PoiseMult", 1.2, 1.35, 1.5)
		PV("Bosses", "PostureMult", 1.2, 1.35, 1.5)
		PV("BigCreatures", "PoiseMult", 1.2, 1.35, 1.5)
		PV("BigCreatures", "PostureMult", 1.2, 1.35, 1.5)
		PV("Perilous", "ChancePercent", 15.0, 20.0, 25.0)
		PV("Perilous", "ParryPosture", 0.6, 0.55, 0.5)
	endif
EndFunction

; manual mode: copy the saved manual values of that tab to the live ini
Function ApplyManual(int tab)
	BuildTable(tab)
	int i = 0
	while i < count
		if UsesPreset(sBlk[i])
			float v = NahIDWinNative.IniGetF("Manual", MKey(i), -9999.0)
			if v > -9998.0
				NahIDWinNative.IniSetF(sSec[i], sKey[i], v)
			endif
		endif
		i += 1
	endWhile
EndFunction

; Effects are processed when the menu closes.
Function ApplyAllTabs()
	int t = 1
	while t <= 4
		if TabManual(t)
			ApplyManual(t)
		else
			ApplyPreset(t, TabLevel(t))
		endif
		t += 1
	endWhile
	ApplyParryGlobal()
EndFunction

; Inpa's parry script restores BaseStamina x global, so the global must be a FRACTION (0.30), not a percent.
Function ApplyParryGlobal()
	GlobalVariable g = GetG(2)
	if g
		float pf = NahIDWinNative.IniGetF("Parry", "DefenderStaminaRecoverFraction", 0.30)
		if Math.Abs(g.GetValue() - pf) > 0.001
			g.SetValue(pf)
			GlobalChanged(2, pf)
		endif
	endif
EndFunction

Event OnConfigClose()
	ApplyAllTabs()
EndEvent



string Function FormatFor(int i)
	if sStep[i] >= 1.0
		return "{0}"
	endif
	return "{2}"
EndFunction

string Function LabelOf(int i)
	if IsPT()
		return sLabelPT[i]
	endif
	return sLabelEN[i]
EndFunction

; ---------------- desenho ----------------
int Function Track(int a_option, int a_kind, int a_ref)
	if a_option >= 0
		int slot = a_option % 128
		oKind[slot] = a_kind
		oRef[slot] = a_ref
	endif
	return a_option
EndFunction

Function Hdr(string en, string pt)
	AddHeaderOption(Orange(Tr(en, pt)), 0)
EndFunction

Function GTog(int gid, string en, string pt)
	Track(AddToggleOption(Tr(en, pt), GVal(gid) > 0.5, sFlag), 4, gid)
EndFunction

Function GSliD(int gid, string en, string pt, bool enabled)
	int f = sFlag
	if !enabled
		f = OPTION_FLAG_DISABLED
	endif
	Track(AddSliderOption(Tr(en, pt), GVal(gid), GFmt(gid), f), 5, gid)
EndFunction

Function GSli(int gid, string en, string pt)
	Track(AddSliderOption(Tr(en, pt), GVal(gid), GFmt(gid), sFlag), 5, gid)
EndFunction

string Function KillName(int v)
	if v == 0
		return Tr("Increased Damage X5", "Dano Aumentado X5")
	elseif v == 3
		return Tr("Only Script Animation", "So animacao")
	endif
	return Tr("Only Onekill Damage", "So dano de morte")
EndFunction

; 0 = Dano Aumentado X5, 3 = animacao, 4 = dano de morte (os modos do VioLens ficam de fora)
int Function KillIndex(int v)
	if v == 0
		return 0
	elseif v == 4
		return 2
	endif
	return 1
EndFunction

int Function KillValue(int idx)
	if idx == 0
		return 0
	elseif idx == 2
		return 4
	endif
	return 3
EndFunction

string Function SneakName(int v)
	if v == 0
		return Tr("Off", "Desligado")
	elseif v == 1
		return Tr("Increased Damage", "Dano Aumentado")
	endif
	return Tr("Script Animation", "Animacao")
EndFunction

; opcoes do .ini escolhidas num menu (posicao do HUD, estilo)
int Function IniChoiceCount(string key)
	if key == "BarStyle"
		return 2
	endif
	return 3
EndFunction

string Function IniChoiceName(string key, int v)
	if key == "BarStyle"
		if v == 0
			return Tr("Flat", "Plana")
		endif
		return "Sekiro"
	endif
	if key == "PlayerPosH" || key == "TargetPosH"
		if v <= 0
			return Tr("Left", "Esquerda")
		elseif v == 1
			return Tr("Center", "Centro")
		endif
		return Tr("Right", "Direita")
	endif
	if v <= 0
		return Tr("Top", "Cima")
	elseif v == 1
		return Tr("Center", "Centro")
	endif
	return Tr("Bottom", "Baixo")
EndFunction

Function DrawBlock(int blk, string en, string pt)
	; cabecalho retratil: clicar abre ou fecha o bloco (estado guardado no .ini, seccao MenuOpen)
	float openDef = 0.0
	if blk == 3
		openDef = 1.0
	endif
	bool isOpen = NahIDWinNative.IniGetF("MenuOpen", "B" + blk, openDef) > 0.5
	string sign = "[+] "
	if isOpen
		sign = "[-] "
	endif
	Track(AddTextOption(Orange(sign + Tr(en, pt)), "", 0), 10, blk)
	if !isOpen
		return
	endif
	bool hide = false
	int i = 0
	while i < count
		if sBlk[i] == blk && !hide
			float cur = RowVal(i)
			if sType[i] == 2
				Track(AddMenuOption(LabelOf(i), IniChoiceName(sKey[i], cur as int), sFlag), 9, i)
			elseif sType[i] == 1
				Track(AddToggleOption(LabelOf(i), cur > 0.5, sFlag), 2, i)
				; funcao desligada: as opcoes dela ficam escondidas
				if sKey[i] == "Enabled" && cur < 0.5
					hide = true
				endif
			else
				Track(AddSliderOption(LabelOf(i), cur, FormatFor(i), sFlag), 3, i)
			endif
		endif
		i += 1
	endWhile
EndFunction

Event OnPageReset(string a_page)
	if a_page == ""
		sPageNo = -1
		return
	endif
	UnloadCustomContent()
	int pg = 0
	if a_page == Pages[1]
		pg = 1
	elseif a_page == Pages[2]
		pg = 2
	elseif a_page == Pages[3]
		pg = 3
	elseif a_page == Pages[4]
		pg = 4
	endif
	BuildTable(pg)
	oKind = new int[128]
	oRef = new int[128]
	if ModOn()
		sFlag = OPTION_FLAG_NONE
	else
		sFlag = OPTION_FLAG_DISABLED
	endif
	SetCursorFillMode(TOP_TO_BOTTOM)
	sPageNo = pg
	if pg == 0
		DrawPage0()
	elseif pg == 1
		DrawPage1()
	elseif pg == 2
		DrawPage2()
	elseif pg == 3
		DrawPage3()
	else
		DrawPage4()
	endif
EndEvent

; mode selector of a tab: returns true when the manual rows must be drawn
bool Function DrawMode(int tab)
	bool man = TabManual(tab)
	Hdr("Mode", "Modo")
	Track(AddToggleOption(Tr("Manual mode (off = preset)", "Modo manual (desligado = predefinido)"), man, sFlag), 11, tab)
	int f = sFlag
	if man
		f = OPTION_FLAG_DISABLED
	endif
	Track(AddMenuOption(Tr("Preset", "Predefinido"), LevelName(TabLevel(tab)), f), 12, tab)
	if !man
		AddTextOption(Tr("Values are applied when the menu closes.", "Os valores sao aplicados ao fechar o menu."), "", OPTION_FLAG_DISABLED)
	endif
	return man
EndFunction

Function DrawPage0()
	SetCursorPosition(0)
	Track(AddToggleOption("<font color=\"#d9b111\">MOD On/Off</font>", ModOn(), 0), 1, 0)
	int li = AddToggleOption(Tr("Language: Portugues (BR)", "Idioma: Portugues (BR)"), IsPT(), 0)
	Track(li, 7, 0)
	Hdr("Master preset", "Predefinido geral")
	Track(AddMenuOption(Tr("Apply to all tabs", "Aplicar a todas as abas"), LevelName(NahIDWinNative.IniGetF("Menu", "Master", 1.0) as int), sFlag), 13, 0)
	DrawBlock(20, "Behavior (Nemesis)", "Behavior (Nemesis)")
	Hdr("Parry Setting", "Parry")
	GSli(1, "Parry & Deflect Timer", "Janela de Parry e Deflexao")
	GTog(3, "Magic Reflect", "Refletir Magia")
	Hdr("Block Setting", "Bloqueio")
	GTog(6, "Resist Melee Damage", "Resistir Dano Corpo a Corpo")
	Hdr("Execution", "Execucao")
	int a = AddMenuOption(Tr("Shinobi Execution", "Execucao Shinobi"), KillName(KillValue(KillIndex(GVal(19) as int))), sFlag)
	Track(a, 6, 19)
	int b = AddMenuOption(Tr("(beta) Sneak Execution", "(beta) Execucao Furtiva"), SneakName(GVal(20) as int), sFlag)
	Track(b, 6, 20)
	GSli(21, "Sneak Execution Damage Mult", "Dano da Execucao Furtiva")
	Hdr("Difficulty Game Setting", "Dificuldade (Game Setting)")
	GTog(31, "Player Difficulty Change", "Mudar Dificuldade do Jogador")
	GSliD(32, "Player taken damage mult", "Dano que o Jogador Recebe", GVal(31) > 0.5)
	GTog(33, "NPC Difficulty Change", "Mudar Dificuldade dos NPCs")
	GSliD(34, "NPC taken damage mult", "Dano que os NPCs Recebem", GVal(33) > 0.5)
	SetCursorPosition(1)
	Hdr("Resist Game Setting", "Resistencias (Game Setting)")
	GSli(27, "Maximum Resistance", "Resistencia Maxima")
	GSli(28, "Maximum Armor Resistance", "Resistencia Maxima da Armadura")
	GSli(29, "Shield Block Base", "Base do Bloqueio com Escudo")
	GSli(30, "Weapon Block Base", "Base do Bloqueio com Arma")
	DrawBlock(14, "Extra Lives and Execution", "Vidas extra e Execucao")
	DrawBlock(11, "System", "Sistema")
EndFunction

Function DrawPage1()
	SetCursorPosition(0)
	if !DrawMode(1)
		return
	endif
	DrawBlock(5, "Stamina", "Estamina")
	DrawBlock(4, "Exhaustion", "Exaustao")
	Hdr("Stamina Game Setting", "Estamina (Game Setting)")
	GSli(23, "Sprint Stamina Drain Base", "Gasto Base da Corrida")
	GSli(24, "Sprint Stamina Drain Mult", "Gasto da Corrida por Peso")
	GSli(25, "Combat Stamina Regen", "Regeneracao de Estamina em Combate")
	GSli(26, "Stamina Regen Delay", "Pausa da Regeneracao de Estamina")
	SetCursorPosition(1)
	DrawBlock(9, "Armor", "Armadura")
	DrawBlock(8, "Stamina cost per weapon type", "Custo de estamina por tipo de arma")
EndFunction

Function DrawPage2()
	SetCursorPosition(0)
	if !DrawMode(2)
		return
	endif
	DrawBlock(1, "Poise", "Poise")
	SetCursorPosition(1)
	DrawBlock(2, "Posture", "Postura")
EndFunction

Function DrawPage3()
	SetCursorPosition(0)
	if !DrawMode(3)
		return
	endif
	DrawBlock(7, "Stagger and Knockback", "Stagger e Empurrao")
	DrawBlock(17, "Staggerlock", "Staggerlock")
	SetCursorPosition(1)
	DrawBlock(12, "Normal block", "Bloqueio normal")
	DrawBlock(19, "Magic deflect", "Deflexao de magia")
EndFunction

Function DrawPage4()
	SetCursorPosition(0)
	bool man = DrawMode(4)
	if man
		DrawBlock(3, "Rage", "Furia")
		DrawBlock(15, "Supreme Rage (fire aura)", "Supremo Rage (aura de fogo)")
		DrawBlock(16, "Bosses, giants and perilous attacks", "Bosses, gigantes e ataques perigosos")
	endif
	SetCursorPosition(1)
	DrawBlock(10, "HUD (TrueHUD bar)", "HUD (barra do TrueHUD)")
	DrawBlock(13, "HUD (own bars)", "HUD (barras proprias)")
EndFunction

; ---------------- eventos ----------------
Event OnOptionSelect(int a_option)
	int slot = a_option % 128
	int k = oKind[slot]
	int r = oRef[slot]
	if k == 1
		bool turnOn = !ModOn()
		SetToggleOptionValue(a_option, turnOn)
		SetModOn(turnOn)
		ForcePageReset()
	elseif k == 11
		float mv = 1.0
		if TabManual(r)
			mv = 0.0
		endif
		NahIDWinNative.IniSetF("Menu", "Mode" + r, mv)
		ForcePageReset()
	elseif k == 7
		float nv = 1.0
		if IsPT()
			nv = 0.0
		endif
		NahIDWinNative.IniSetF("Menu", "Language", nv)
		ForcePageReset()
	elseif k == 10
		float od = 0.0
		if r == 3
			od = 1.0
		endif
		float ov = 1.0
		if NahIDWinNative.IniGetF("MenuOpen", "B" + r, od) > 0.5
			ov = 0.0
		endif
		NahIDWinNative.IniSetF("MenuOpen", "B" + r, ov)
		ForcePageReset()
	elseif k == 2
		float cur = RowVal(r)
		float nv2 = 1.0
		if cur > 0.5
			nv2 = 0.0
		endif
		SetRow(r, nv2)
		SetToggleOptionValue(a_option, nv2 > 0.5)
		if sKey[r] == "Enabled"
			ForcePageReset()
		endif
	elseif k == 4
		float g = 1.0
		if GVal(r) > 0.5
			g = 0.0
		endif
		GetG(r).SetValue(g)
		SetToggleOptionValue(a_option, g > 0.5)
		GlobalChanged(r, g)
		if r == 31 || r == 33
			ForcePageReset()
		endif
	endif
EndEvent

Event OnOptionDefault(int a_option)
	int slot = a_option % 128
	int k = oKind[slot]
	int r = oRef[slot]
	if k == 2
		SetRow(r, sDef[r])
		SetToggleOptionValue(a_option, sDef[r] > 0.5)
	elseif k == 3
		SetRow(r, sDef[r])
		SetSliderOptionValue(a_option, sDef[r], FormatFor(r))
	elseif k == 9
		SetRow(r, sDef[r])
		SetMenuOptionValue(a_option, IniChoiceName(sKey[r], sDef[r] as int))
	elseif k == 5
		GetG(r).SetValue(GDef(r))
		SetSliderOptionValue(a_option, GDef(r), GFmt(r))
		GlobalChanged(r, GDef(r))
	endif
EndEvent

Event OnOptionSliderOpen(int a_option)
	int slot = a_option % 128
	int k = oKind[slot]
	int r = oRef[slot]
	if k == 3
		SetSliderDialogStartValue(RowVal(r))
		SetSliderDialogDefaultValue(sDef[r])
		SetSliderDialogRange(sMin[r], sMax[r])
		SetSliderDialogInterval(sStep[r])
	elseif k == 5
		SetSliderDialogStartValue(GVal(r))
		SetSliderDialogDefaultValue(GDef(r))
		SetSliderDialogRange(GMin(r), GMax(r))
		SetSliderDialogInterval(GStep(r))
	endif
EndEvent

Event OnOptionSliderAccept(int a_option, float a_value)
	int slot = a_option % 128
	int k = oKind[slot]
	int r = oRef[slot]
	if k == 3
		SetRow(r, a_value)
		SetSliderOptionValue(a_option, a_value, FormatFor(r))
	elseif k == 5
		GetG(r).SetValue(a_value)
		SetSliderOptionValue(a_option, a_value, GFmt(r))
		GlobalChanged(r, a_value)
	endif
EndEvent

Event OnOptionMenuOpen(int a_option)
	int slot = a_option % 128
	int r = oRef[slot]
	if oKind[slot] == 12 || oKind[slot] == 13
		string[] lv = new string[3]
		lv[0] = LevelName(0)
		lv[1] = LevelName(1)
		lv[2] = LevelName(2)
		SetMenuDialogOptions(lv)
		if oKind[slot] == 12
			SetMenuDialogStartIndex(TabLevel(r))
		else
			SetMenuDialogStartIndex(NahIDWinNative.IniGetF("Menu", "Master", 1.0) as int)
		endif
		SetMenuDialogDefaultIndex(1)
		return
	endif
	if oKind[slot] == 9
		int n = IniChoiceCount(sKey[r])
		string[] opts9 = new string[3]
		opts9[0] = IniChoiceName(sKey[r], 0)
		opts9[1] = IniChoiceName(sKey[r], 1)
		opts9[2] = IniChoiceName(sKey[r], 2)
		if n == 2
			opts9 = new string[2]
			opts9[0] = IniChoiceName(sKey[r], 0)
			opts9[1] = IniChoiceName(sKey[r], 1)
		endif
		SetMenuDialogOptions(opts9)
		SetMenuDialogStartIndex(RowVal(r) as int)
		SetMenuDialogDefaultIndex(sDef[r] as int)
		return
	endif
	if oKind[slot] != 6
		return
	endif
	if r == 19
		string[] opts = new string[3]
		opts[0] = KillName(0)
		opts[1] = KillName(3)
		opts[2] = KillName(4)
		SetMenuDialogOptions(opts)
		SetMenuDialogStartIndex(KillIndex(GVal(19) as int))
		SetMenuDialogDefaultIndex(1)
	elseif r == 20
		string[] opts2 = new string[3]
		opts2[0] = SneakName(0)
		opts2[1] = SneakName(1)
		opts2[2] = SneakName(2)
		SetMenuDialogOptions(opts2)
		SetMenuDialogStartIndex(GVal(20) as int)
		SetMenuDialogDefaultIndex(0)
	endif
EndEvent

Event OnOptionMenuAccept(int a_option, int a_index)
	int slot = a_option % 128
	int r = oRef[slot]
	if oKind[slot] == 12 && a_index >= 0
		NahIDWinNative.IniSetF("Menu", "Level" + r, a_index as float)
		SetMenuOptionValue(a_option, LevelName(a_index))
		return
	endif
	if oKind[slot] == 13 && a_index >= 0
		NahIDWinNative.IniSetF("Menu", "Master", a_index as float)
		int t = 1
		while t <= 4
			NahIDWinNative.IniSetF("Menu", "Mode" + t, 0.0)
			NahIDWinNative.IniSetF("Menu", "Level" + t, a_index as float)
			t += 1
		endWhile
		SetMenuOptionValue(a_option, LevelName(a_index))
		return
	endif
	if oKind[slot] == 9 && a_index >= 0
		SetRow(r, a_index as float)
		SetMenuOptionValue(a_option, IniChoiceName(sKey[r], a_index))
		return
	endif
	if oKind[slot] != 6 || a_index < 0
		return
	endif
	if r == 19
		int v = KillValue(a_index)
		GetG(19).SetValue(v as float)
		SetMenuOptionValue(a_option, KillName(v))
	elseif r == 20
		GetG(20).SetValue(a_index as float)
		SetMenuOptionValue(a_option, SneakName(a_index))
	endif
EndEvent

string Function GInfo(int gid)
	if gid == 1
		return Tr("Deflect timer when you are blocking.", "Janela de parry/deflexao quando comecas a bloquear.")
	elseif gid == 2
		return Tr("Stamina recovered when you parry or deflect.", "Estamina que recuperas ao fazer parry ou deflexao.")
	elseif gid == 3
		return Tr("Reflect magic back at the caster.", "Reflete a magia de volta para quem a lancou.")
	elseif gid == 4
		return Tr("Set whether the player can block arrows.", "Define se o jogador pode bloquear flechas.")
	elseif gid == 5
		return Tr("Set whether the player can block and deflect spells.", "Define se o jogador pode bloquear e defletir magias.")
	elseif gid == 6
		return Tr("No melee damage while blocking, like Sekiro. Level-difference damage cannot be fully blocked.", "Sem dano corpo a corpo ao bloquear, como no Sekiro.")
	elseif gid == 7
		return Tr("Resist poison and disease while blocking.", "Resiste a veneno e doenca ao bloquear.")
	elseif gid == 8
		return Tr("Enemy alert sound when the player is in combat.", "Som de alerta de inimigo quando estas em combate.")
	elseif gid == 9
		return Tr("Set whether enemies can block and deflect arrows.", "Define se os inimigos bloqueiam flechas.")
	elseif gid == 10
		return Tr("Set whether enemies can block magic (with enchanted weapon or shield).", "Define se os inimigos bloqueiam magia (com arma ou escudo encantados).")
	elseif gid == 11
		return Tr("Set whether enemies can block with fists.", "Define se os inimigos bloqueiam com os punhos.")
	elseif gid == 12
		return Tr("Gives enemies 50% frost resistance, like Nord.", "Da 50% de resistencia a gelo aos inimigos, como os Nord.")
	elseif gid == 13
		return Tr("Enemies get staggered by magic like the player.", "Os inimigos cambaleiam com magia como o jogador.")
	elseif gid == 14
		return Tr("Random chance of enemy Perilous Attacks. 0 = off.", "Probabilidade de ataques perigosos dos inimigos. 0 = desligado.")
	elseif gid == 15
		return Tr("Multiplies the stamina of dragons.", "Multiplica a estamina dos dragoes.")
	elseif gid == 16
		return Tr("Protect your allies from execution.", "Protege os teus aliados de execucao.")
	elseif gid == 17
		return Tr("Allies take half stamina damage.", "Os aliados levam metade do dano de estamina.")
	elseif gid == 18
		return Tr("Allies cannot stagger enemies.", "Os aliados nao fazem stagger aos inimigos.")
	elseif gid == 19
		return Tr("Execution when an enemy is in posture break. The VioLens modes are not available.", "Execucao quando o inimigo esta com a postura quebrada. Os modos do VioLens nao existem.")
	elseif gid == 20
		return Tr("Backstab execution while sneaking behind an enemy.", "Execucao pelas costas enquanto furtivo.")
	elseif gid == 21
		return Tr("Damage multiplier of the sneak execution.", "Multiplicador de dano da execucao furtiva.")
	elseif gid == 22
		return Tr("Game setting (vanilla 2): stamina cost multiplier of power attacks, not bashes.", "Game Setting (vanilla 2): multiplicador do custo de estamina dos golpes fortes, nao dos de escudo.")
	elseif gid == 23
		return Tr("Game setting: base stamina drain of sprinting.", "Game Setting: gasto base de estamina ao correr.")
	elseif gid == 24
		return Tr("Game setting: sprint stamina drain per armor weight.", "Game Setting: gasto de estamina da corrida por peso da armadura.")
	elseif gid == 25
		return Tr("Game setting: stamina regeneration rate while in combat (Inpa uses 0.35, vanilla 0.35). Raise it if stamina feels slow to recover.", "Game Setting: velocidade da regeneracao de estamina em combate. Sobe se a estamina demorar a recuperar.")
	elseif gid == 26
		return Tr("Game setting: seconds before stamina starts to regenerate after being spent (vanilla 5). Lower = recovers sooner.", "Game Setting: segundos ate a estamina comecar a regenerar depois de gasta (vanilla 5). Mais baixo = recupera mais cedo.")
	elseif gid == 27
		return Tr("Game setting: maximum possible damage reduction from resistances, blocking, etc.", "Game Setting: reducao maxima de dano por resistencias, bloqueio, etc.")
	elseif gid == 28
		return Tr("Game setting: maximum damage reduction given by armor rating.", "Game Setting: reducao maxima de dano dada pela armadura.")
	elseif gid == 29
		return Tr("Game setting: base of shield blocking.", "Game Setting: base do bloqueio com escudo.")
	elseif gid == 30
		return Tr("Game setting: base of weapon blocking.", "Game Setting: base do bloqueio com arma.")
	elseif gid == 31
		return Tr("Override the vanilla difficulty damage taken by the player.", "Substitui a dificuldade do jogo para o dano que o jogador recebe.")
	elseif gid == 32
		return Tr("How much damage the player takes.", "Quanto dano o jogador recebe.")
	elseif gid == 33
		return Tr("Override the vanilla difficulty damage taken by enemies.", "Substitui a dificuldade do jogo para o dano que os inimigos recebem.")
	elseif gid == 34
		return Tr("How much damage enemies take.", "Quanto dano os inimigos recebem.")
	endif
	return ""
EndFunction

Event OnOptionHighlight(int a_option)
	int slot = a_option % 128
	int k = oKind[slot]
	int r = oRef[slot]
	if k == 1
		SetInfoText(Tr("Turns Inpa Sekiro and NahIDWin on/off together. Do it out of combat.", "Liga/desliga o Inpa Sekiro e o NahIDWin em conjunto. Faz isto fora de combate."))
	elseif k == 7
		SetInfoText(Tr("Switch between English and Portugues (BR).", "Alterna entre English e Portugues (BR)."))
	elseif k == 11
		SetInfoText(Tr("Off: an Easy / Normal / Hard preset is used. On: you edit every value yourself (manual values are kept when you switch back).", "Desligado: usa um predefinido Facil / Normal / Hard. Ligado: editas cada valor (os valores manuais ficam guardados ao voltar)."))
	elseif k == 12
		SetInfoText(Tr("Easy = more slack. Normal = recommended. Hard = strictest. Applied when the menu closes.", "Facil = mais folga. Normal = recomendado. Hard = o mais duro. Aplicado ao fechar o menu."))
	elseif k == 13
		SetInfoText(Tr("Sets the Stamina, Poise & Posture, Stagger & Behaviors and Special tabs to this preset. Applied when the menu closes.", "Define as abas Estamina, Poise e Postura, Stagger e Behaviors e Especial para este predefinido. Aplicado ao fechar o menu."))
	elseif k == 10
		SetInfoText(Tr("Click to open or close this section.", "Clica para abrir ou fechar esta seccao."))
	elseif k == 2 || k == 3 || k == 9
		SetInfoText(Tr(sInfoEN[r], sInfoPT[r]))
	elseif k == 4 || k == 5 || k == 6
		SetInfoText(GInfo(r))
	endif
EndEvent
