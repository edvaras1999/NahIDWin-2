Scriptname NahIDWinBridge extends Quest
{ NAH-I-D-WIN - ponte minima. A DLL faz todas as contas (poise e postura) e envia UM evento de mod
  ("NahIDWin_Stagger") so quando e preciso reagir:
   tipo 1,2,3 = stagger leve / medio / pesado  -> lanca um de tres feiticos de stagger do jogo
   tipo 4     = BleedOut (a postura quebrou)   -> toca a animacao de ajoelhado durante alguns segundos
   tipo 5     = stagger pesado + empurrao (golpe forte, criatura gigante)
   tipo 6     = parry perfeito do jogador      -> faiscas e som (do pacote de efeitos)
   tipo 7     = exaustao (estamina a zero)     -> jogador: sem atacar e sem regenerar por uns segundos; NPC: stagger pesado
  O jogador tambem usa eventos de animacao (um por balanco, golpe forte). Parry, furia e dano de vida sao feitos na DLL.
  Nao ha ciclos nem consultas repetidas. }

Spell sp1
Spell sp2
Spell sp3

Event OnInit()
	RegisterForModEvent("NahIDWin_Stagger", "OnNahStagger")
	RegisterForModEvent("NahIDWin_Load", "OnNahLoad")
	RegisterForModEvent("NahIDWin_Combatant", "OnNahCombatant")
	RegisterForModEvent("NahIDWin_Rage", "OnNahRage")
	RegisterForModEvent("NahIDWin_Life", "OnNahLife")
	RegisterForModEvent("NahIDWin_Essential", "OnNahEssential")
	RegisterForModEvent("NahIDWin_BossLife", "OnNahBossLife")
	RegisterForModEvent("NahIDWin_Execute", "OnNahExecute")
	RegisterForModEvent("NahIDWin_Reflect", "OnNahReflect")
	RegisterForModEvent("NahIDWin_Perilous", "OnNahPerilous")
	RegisterForModEvent("NahIDWin_Repair", "OnNahRepair")
	RegisterForSleep()
	RegisterInputs()
	RegisterForSingleUpdate(0.5)
	NahIDWinNative.ScriptReady()
	; New game: the DLL's load message can arrive before this script exists, so the load setup runs from OnUpdate (two passes).
	sInitStage = 0
	sInitAt = Utility.GetCurrentRealTime() + 6.0
EndEvent

int sInitStage = 2
float sInitAt = 0.0

; Same setup as OnNahLoad but without blocking waits.
Function LateInit()
	RegisterInputs()
	ZeroVanillaCosts()
	NahIDWinNative.Log("bridge 0.24.4: late init pass " + sInitStage)
EndFunction

; A DLL avisa quando um save e carregado: os registos de animacao perdem-se, entao registamos de novo.
Function OnNahLoad(string eventName, string strArg, float numArg, Form sender)
	; saves antigos nao tem os registos novos (OnInit so corre em jogos novos): registamos sempre
	RegisterForModEvent("NahIDWin_Stagger", "OnNahStagger")
	RegisterForModEvent("NahIDWin_Combatant", "OnNahCombatant")
	RegisterForModEvent("NahIDWin_Rage", "OnNahRage")
	RegisterForModEvent("NahIDWin_Life", "OnNahLife")
	RegisterForModEvent("NahIDWin_Essential", "OnNahEssential")
	RegisterForModEvent("NahIDWin_BossLife", "OnNahBossLife")
	RegisterForModEvent("NahIDWin_Execute", "OnNahExecute")
	RegisterForModEvent("NahIDWin_Reflect", "OnNahReflect")
	RegisterForModEvent("NahIDWin_Perilous", "OnNahPerilous")
	RegisterForModEvent("NahIDWin_Repair", "OnNahRepair")
	RegisterForSleep()
	NahIDWinNative.SetLivesUsed(livesUsed)
	executing = false
	if speedCut > 0.0
		Game.GetPlayer().ModActorValue("SpeedMult", speedCut)
	endif
	speedCut = 0.0
	if atkCut > 0.0
		Game.GetPlayer().ModActorValue("WeaponSpeedMult", atkCut)
	endif
	atkCut = 0.0
	if ctrlHeld
		Game.EnablePlayerControls(true, true, true, true, true, true, true, true, 0)
		ctrlHeld = false
		NahIDWinNative.Log("controls: released the controls this mod had disabled before the save")
	endif
	RefreshPerf()
	exhaustedNow = false
	NahIDWinNative.ExhaustEnded()
	if NahIDWinNative.IniGetF("Exhaustion", "RepairSpeedOnLoad", 0.0) > 0.5
		; one-shot repair: set SpeedMult back to its base value, then switch the option off
		Actor plr = Game.GetPlayer()
		float baseSp = plr.GetBaseActorValue("SpeedMult")
		float curSp = plr.GetActorValue("SpeedMult")
		if Math.Abs(curSp - baseSp) > 0.5
			plr.ModActorValue("SpeedMult", baseSp - curSp)
		endif
		NahIDWinNative.IniSetF("Exhaustion", "RepairSpeedOnLoad", 0.0)
		NahIDWinNative.Log("speed repaired " + curSp + " -> " + baseSp)
	endif
	lastRegen = -1.0
	sInitStage = 2
	RegisterInputs()
	RegisterForSingleUpdate(0.5)
	NahIDWinNative.Log("bridge 0.24.4: eventos de mod e de animacao registados")
	; o Inpa reaplica os Game Settings dele ao carregar (bloqueio dos NPCs a 0.60); depois disso repomos o valor escolhido no menu
	Utility.Wait(8.0)
	ApplyNpcBlock()
EndFunction

Function ApplyNpcBlock()
	; v0.24.2: NPC block game settings are left vanilla
	ZeroVanillaCosts()
EndFunction

; v0.23: o mod passa a cobrar os custos de estamina (golpe, bash, bloqueio); os do jogo ficam a zero (os Game Settings nao ficam gravados no save)
Function ZeroVanillaCosts()
	if NahIDWinNative.IniGetF("General", "Enabled", 1.0) < 0.5 || NahIDWinNative.IniGetF("Stamina", "Enabled", 1.0) < 0.5 || NahIDWinNative.IniGetF("Stamina", "ZeroVanillaCosts", 1.0) < 0.5
		return
	endif
	ZeroGmst("fStaminaAttackWeaponBase")
	ZeroGmst("fStaminaAttackWeaponMult")
	ZeroGmst("fPowerAttackStaminaPenalty")
	ZeroGmst("fStaminaBashBase")
	ZeroGmst("fStaminaPowerBashBase")
	ZeroGmst("fStaminaBlockBase")
	ZeroGmst("fStaminaBlockMult")
EndFunction

Function ZeroGmst(string gmstName)
	float before = Game.GetGameSettingFloat(gmstName)
	Game.SetGameSettingFloat(gmstName, 0.0)
	NahIDWinNative.Log("GMST " + gmstName + ": " + before + " -> " + Game.GetGameSettingFloat(gmstName))
EndFunction

Function RegisterInputs()
	Actor pl = Game.GetPlayer()
	if pl
		RegisterForAnimationEvent(pl, "weaponSwing")
		RegisterForAnimationEvent(pl, "weaponLeftSwing")
		RegisterForAnimationEvent(pl, "bashStart")
		RegisterForAnimationEvent(pl, "bashPowerStart")
		RegisterForAnimationEvent(pl, "attackPowerStartInPlace")
		RegisterForAnimationEvent(pl, "attackPowerStartForward")
		RegisterForAnimationEvent(pl, "attackPowerStartBackward")
		RegisterForAnimationEvent(pl, "attackPowerStartLeft")
		RegisterForAnimationEvent(pl, "attackPowerStartRight")
		RegisterForAnimationEvent(pl, "attackPowerStartDualWield")
		RegisterForAnimationEvent(pl, "staggerStart")
		; so para o diagnostico das quedas do jogador (so escrevem no log)
		RegisterForAnimationEvent(pl, "recoilStart")
		RegisterForAnimationEvent(pl, "recoilLargeStart")
		RegisterForAnimationEvent(pl, "bleedOutStart")
		RegisterForAnimationEvent(pl, "KnockDown")
		RegisterForAnimationEvent(pl, "ragdollStart")
		RegisterForAnimationEvent(pl, "recoilStop")
		RegisterForAnimationEvent(pl, "staggerStop")
		RegisterForAnimationEvent(pl, "attackPowerStartForwardLeftHand")
		RegisterForAnimationEvent(pl, "ragdollEnd")
		RegisterForAnimationEvent(pl, "GetUpStart")
		RegisterForAnimationEvent(pl, "GetUpEnd")
		ApplyRegen()
	endif
EndFunction

; Depois de um stagger o jogador fica uns segundos sem poder ser staggerado de novo (para poder bloquear ou esquivar).
; [Stagger] PlayerImmuneAfterSeconds no .ini (0 = desligado). Staggers pesados do nosso mod (poise quebrado) passam sempre.
bool sNoStagger = false

Function OnPlayerStagger()
	float win = NahIDWinNative.IniGetF("Stagger", "PlayerImmuneAfterSeconds", 1.5)
	if win <= 0.0 || sNoStagger
		return
	endif
	sNoStagger = true
	sNoStaggerEnd = Utility.GetCurrentRealTime() + win
	Game.GetPlayer().SetAnimationVariableBool("bNoStagger", true)
EndFunction

float sNoStaggerEnd = 0.0

; Ciclo curto: regeneracao de estamina conforme o combate e fim da imunidade ao stagger.
Event OnUpdate()
	if sNoStagger && Utility.GetCurrentRealTime() >= sNoStaggerEnd
		Game.GetPlayer().SetAnimationVariableBool("bNoStagger", false)
		sNoStagger = false
	endif
	if sInitStage < 2 && Utility.GetCurrentRealTime() >= sInitAt
		sInitStage += 1
		sInitAt = Utility.GetCurrentRealTime() + 40.0
		LateInit()
	endif
	CheckExhaust()
	ApplyRegen()
	ControlsWatchdog()
	; light loop: 0.5 s in combat or exhausted, 2.5 s otherwise (slower in the Light/Minimal performance modes)
	if inCombatNow || exhaustedNow
		RegisterForSingleUpdate(loopCombat)
	else
		RegisterForSingleUpdate(loopIdle)
	endif
EndEvent

; ---------------- v0.26: seguranca (vigia de controles), reparo e desempenho ----------------
bool ctrlHeld = false
float loopCombat = 0.5
float loopIdle = 2.5
float wdNext = 0.0
float wdPerfNext = 0.0
string wdLast = ""
int wdBad = 0

Function RefreshPerf()
	float pm = NahIDWinNative.IniGetF("Performance", "Mode", 0.0)
	if pm >= 1.5
		loopCombat = 1.0
		loopIdle = 5.0
	elseif pm >= 0.5
		loopCombat = 0.75
		loopIdle = 4.0
	else
		loopCombat = 0.5
		loopIdle = 2.5
	endif
EndFunction

int Function Bi(bool b)
	if b
		return 1
	endif
	return 0
EndFunction

; Regista no log (so quando muda) o estado dos controles do jogador; opcionalmente reativa-os se ficarem presos depois do combate.
Function ControlsWatchdog()
	float t = Utility.GetCurrentRealTime()
	if t < wdNext
		return
	endif
	if t >= wdPerfNext
		wdPerfNext = t + 20.0
		RefreshPerf()
	endif
	if NahIDWinNative.IniGetF("Safety", "ControlsWatchdog", 1.0) < 0.5
		wdNext = t + 10.0
		return
	endif
	wdNext = t + 2.0
	Actor pl = Game.GetPlayer()
	string st = "mov=" + Bi(Game.IsMovementControlsEnabled()) + " fight=" + Bi(Game.IsFightingControlsEnabled()) + " look=" + Bi(Game.IsLookingControlsEnabled()) + " menu=" + Bi(Game.IsMenuControlsEnabled()) + " activate=" + Bi(Game.IsActivateControlsEnabled()) + " journal=" + Bi(Game.IsJournalControlsEnabled()) + " sneak=" + Bi(Game.IsSneakingControlsEnabled()) + " cam=" + Bi(Game.IsCamSwitchControlsEnabled()) + " pov=" + Bi(Game.IsPOVSwitchControlsEnabled())
	bool allOn = (st == "mov=1 fight=1 look=1 menu=1 activate=1 journal=1 sneak=1 cam=1 pov=1")
	string full = st + " | combat=" + Bi(inCombatNow) + " menuMode=" + Bi(Utility.IsInMenuMode()) + " ourHold=" + Bi(ctrlHeld) + " bleedout=" + Bi(pl.IsBleedingOut()) + " exhausted=" + Bi(exhaustedNow)
	if full != wdLast
		wdLast = full
		if allOn
			NahIDWinNative.Log("CONTROLS OK | " + full)
		else
			NahIDWinNative.Log("CONTROLS BLOCKED | " + full)
		endif
	endif
	if allOn || inCombatNow || ctrlHeld || exhaustedNow || executing
		wdBad = 0
		return
	endif
	wdBad += 1
	if wdBad >= 5 && NahIDWinNative.IniGetF("Safety", "AutoFix", 0.0) > 0.5 && !Utility.IsInMenuMode()
		wdBad = 0
		Game.EnablePlayerControls(true, true, true, true, true, true, true, true, 0)
		NahIDWinNative.Log("CONTROLS: auto-fix re-enabled the player controls (" + st + ")")
	endif
EndFunction

; Botao do MCM "Reparar jogo / Preparar para desinstalar": devolve tudo ao normal e para os ciclos do mod.
Function OnNahRepair(string eventName, string strArg, float numArg, Form sender)
	Actor pl = Game.GetPlayer()
	if exhaustedNow
		NahIDWinNative.ExhaustEnded()
		exhaustedNow = false
	endif
	if speedCut > 0.0
		pl.ModActorValue("SpeedMult", speedCut)
		speedCut = 0.0
	endif
	if atkCut > 0.0
		pl.ModActorValue("WeaponSpeedMult", atkCut)
		atkCut = 0.0
	endif
	float baseSp = pl.GetBaseActorValue("SpeedMult")
	float curSp = pl.GetActorValue("SpeedMult")
	if Math.Abs(curSp - baseSp) > 0.5
		pl.ModActorValue("SpeedMult", baseSp - curSp)
	endif
	pl.SetActorValue("StaminaRateMult", 100.0)
	pl.SetAnimationVariableBool("bNoStagger", false)
	sNoStagger = false
	Game.EnablePlayerControls(true, true, true, true, true, true, true, true, 0)
	ctrlHeld = false
	Game.SetGameSettingFloat("fStaminaAttackWeaponBase", 20.0)
	Game.SetGameSettingFloat("fStaminaAttackWeaponMult", 1.0)
	NahIDWinNative.Log("REPAIR: speed, attack speed, stamina regen, GMSTs and controls restored")
	Debug.Notification("NAH-I-D-WIN: jogo reparado / game repaired")
EndFunction

; ---------------- vidas extra do jogador ----------------
int livesUsed = 0
bool sleptInBed = false
bool executing = false

; A DLL avisa quando uma vida extra foi gasta (numArg = quantas ja gastas): ouro, aviso e brilho.
; Marca/desmarca "essencial" (como o SkyTweak): o jogo so faz o bleedout verdadeiro se a flag ja la estiver.
Function OnNahEssential(string eventName, string strArg, float numArg, Form sender)
	Actor a = sender as Actor
	if a
		ActorBase ab = a.GetActorBase()
		if ab
			ab.SetEssential(numArg > 0.5)
		endif
	endif
EndFunction

; Boss gastou a vida extra: o jogo fez o bleedout; espera, repoe a vida, tira a flag e volta a lutar.
; Execucao garantida: o jogador acertou um alvo com a postura quebrada. Gigantes/dragoes ("big"): morrem. Os outros: feitico de execucao do Inpa.
Function OnNahExecute(string eventName, string strArg, float numArg, Form sender)
	Actor v = sender as Actor
	Actor pl = Game.GetPlayer()
	if !v || v.IsDead()
		return
	endif
	if strArg == "big"
		NahIDWinNative.Log("execution (big creature): kill " + v)
		v.Kill(pl)
		return
	endif
	GlobalVariable g = Game.GetFormFromFile(0x0011AADE, "NahIDWin.esp") as GlobalVariable
	int mode = 2
	if g
		mode = g.GetValue() as int
	endif
	Spell sp = None
	if mode == 2
		sp = Game.GetFormFromFile(0x0078D3B4, "NahIDWin.esp") as Spell
	elseif mode == 3
		sp = Game.GetFormFromFile(0x007C9FB9, "NahIDWin.esp") as Spell
	endif
	if !sp
		NahIDWinNative.Log("execution: Inpa killmove mode " + mode + " has no spell")
		return
	endif
	if executing
		NahIDWinNative.Log("execution: skipped (another one is still running)")
		return
	endif
	executing = true
	; [Execution] Method: 0 = espera pela execucao do proprio Inpa e so lanca a nossa se ela nao arrancar (evita duas execucoes ao mesmo tempo);
	; 1 = lanca logo a execucao do Inpa (comportamento antigo); 2 = mata o alvo diretamente, sem animacao.
	int method = NahIDWinNative.IniGetF("Execution", "Method", 0.0) as int
	GlobalVariable hd = Game.GetFormFromFile(0x007BFDB8, "NahIDWin.esp") as GlobalVariable
	if method == 2
		Utility.Wait(0.3)
		NahIDWinNative.Log("execution: method 2, direct kill " + v)
		if !v.IsDead()
			v.Kill(pl)
		endif
		executing = false
		return
	endif
	bool inpaRunning = false
	if method == 0
		int w = 0
		while w < 6 && !inpaRunning
			Utility.Wait(0.2)
			w += 1
			if v.IsDead() || v.IsInKillMove() || pl.IsInKillMove()
				inpaRunning = true
			elseif hd && hd.GetValue() > 0.5
				inpaRunning = true
			endif
		endWhile
	else
		Utility.Wait(0.35)
	endif
	if inpaRunning
		NahIDWinNative.Log("execution: Inpa's own execution is already running (kill move/global/victim dead), ours is not cast")
	elseif v.IsDead() || v.IsInKillMove() || pl.IsInKillMove()
		NahIDWinNative.Log("execution: skipped (victim dead or a kill move already running)")
		executing = false
		return
	else
		NahIDWinNative.Log("execution: casting Inpa execution (mode " + mode + ", method " + method + ") on " + v + " player hp " + pl.GetActorValue("Health"))
		sp.Cast(v, pl)
	endif
	; registo da vida do jogador durante e depois da execucao (para descobrir o que o mata)
	int i = 0
	while i < 14
		Utility.Wait(0.5)
		i += 1
		NahIDWinNative.Log("execution watch " + i + ": player hp " + pl.GetActorValue("Health") + " dead=" + pl.IsDead() + " killmove=" + pl.IsInKillMove() + " ghost=" + pl.IsGhost() + " victim dead=" + v.IsDead())
	endWhile
	executing = false
EndFunction

; Deflect: o feitico que acertou o jogador e relancado no conjurador.
Function OnNahReflect(string eventName, string strArg, float numArg, Form sender)
	Actor c = sender as Actor
	if !c || c.IsDead()
		return
	endif
	Spell sp = Game.GetForm(strArg as int) as Spell
	if sp
		sp.Cast(Game.GetPlayer(), c)
	endif
EndFunction

; Ataque perigoso: aviso visual (simbolo + brilho do Inpa) e som no atacante.
Function OnNahPerilous(string eventName, string strArg, float numArg, Form sender)
	Actor a = sender as Actor
	if !a || a.IsDead()
		return
	endif
	Spell symbol = Game.GetFormFromFile(0x00000843, "NahIDWin.esp") as Spell
	Spell glow = Game.GetFormFromFile(0x00000841, "NahIDWin.esp") as Spell
	if symbol
		symbol.Cast(a, a)
	endif
	if glow
		glow.Cast(a, a)
	endif
	Sound mk = Game.GetFormFromFile(0x00006E76, "NahIDWin.esp") as Sound
	if mk
		mk.Play(a)
	endif
EndFunction

Function OnNahBossLife(string eventName, string strArg, float numArg, Form sender)
	Actor b = sender as Actor
	if !b
		return
	endif
	float secs = numArg
	if secs < 3.0
		secs = 3.0
	endif
	NahIDWinNative.Log("boss life: bleedout for " + secs + " s")
	Utility.Wait(secs)
	if b.IsDead()
		return
	endif
	NahIDWinNative.BossRecover(b)
	ActorBase ab = b.GetActorBase()
	if ab
		ab.SetEssential(false)
	endif
	b.StartCombat(Game.GetPlayer())
	NahIDWinNative.Log("boss life: restored, back to combat")
EndFunction

Function OnNahLife(string eventName, string strArg, float numArg, Form sender)
	livesUsed = numArg as int
	Actor pl = Game.GetPlayer()
	float pct = NahIDWinNative.IniGetF("Lives", "GoldLossPercent", 25.0)
	Form gold = Game.GetForm(0x0000000F)
	int lost = 0
	if gold && pct > 0.0
		int have = pl.GetItemCount(gold)
		lost = ((have as float) * pct / 100.0) as int
		if lost > 0
			pl.RemoveItem(gold, lost, true, None)
		endif
	endif
	if NahIDWinNative.GetLanguage() == 0
		Debug.Notification("Vida extra usada (" + livesUsed + " gasta(s)). Ouro perdido: " + lost)
	else
		Debug.Notification("Extra life used (" + livesUsed + " spent). Gold lost: " + lost)
	endif
	; Metodo do SkyTweak: o jogo fez o bleedout verdadeiro (jogador essencial). Espera, acaba o combate e repoe a vida.
	if NahIDWinNative.LifeMethod() == 1
		float secs = NahIDWinNative.GetBleedSeconds()
		if secs < 5.0
			secs = 5.0
		endif
		NahIDWinNative.Log("extra life: bleedout (game) for " + secs + " s")
		; Igual ao SkyTweak: acaba o alarme de combate logo no inicio do bleedout, espera, repoe a vida.
		pl.StopCombatAlarm()
		Utility.Wait(0.7)
		bool engineBO = pl.IsBleedingOut()
		NahIDWinNative.Log("extra life: engine bleedout=" + engineBO)
		if !engineBO
			; rede de seguranca: o jogo nao fez o bleedout (marca essencial ignorada) -> animacao nossa, com invulnerabilidade da DLL
			ctrlHeld = true
			Game.DisablePlayerControls(true, true, false, false, false, false, false, false, 0)
			int pid = pl.GetFormID()
			int tries = 0
			bool ok = false
			while tries < 6 && !ok
				NahIDWinNative.OwnAnim(600)
				Debug.SendAnimationEvent(pl, "BleedoutStart")
				Utility.Wait(0.25)
				ok = NahIDWinNative.BleedAccepted(pid)
				tries += 1
			endwhile
			NahIDWinNative.Log("extra life: fallback animation accepted=" + ok + " after " + tries + " tries")
		endif
		Utility.Wait(secs - 0.7)
		if !engineBO
			NahIDWinNative.OwnAnim(1500)
			Debug.SendAnimationEvent(pl, "BleedoutStop")
			Game.EnablePlayerControls(true, true, true, true, true, true, true, true, 0)
			ctrlHeld = false
		endif
		pl.ResetHealthAndLimbs()
		NahIDWinNative.LifeRecover()
		NahIDWinNative.Log("extra life: health restored, standing up")
	endif
	Spell glow = Game.GetFormFromFile(0x00000841, "NahIDWin.esp") as Spell
	if glow
		glow.Cast(pl, pl)
		Utility.Wait(3.0)
		pl.DispelSpell(glow)
	endif
EndFunction

; Dormir numa cama enche as vidas extra outra vez (esperar nao conta).
Event OnSleepStart(float afSleepStartTime, float afDesiredSleepEndTime)
	Actor pl = Game.GetPlayer()
	sleptInBed = (pl.GetFurnitureReference() != None) && (pl.GetSleepState() >= 2)
EndEvent

Event OnSleepStop(bool abInterrupted)
	if sleptInBed && !abInterrupted && livesUsed > 0
		livesUsed = 0
		NahIDWinNative.SetLivesUsed(0)
		if NahIDWinNative.GetLanguage() == 0
			Debug.Notification("Vidas extra recuperadas.")
		else
			Debug.Notification("Extra lives restored.")
		endif
	endif
	sleptInBed = false
EndEvent

; Furia (jogador e NPC): brilho e/ou simbolo vermelho.
; [Rage] StaggerImmune: 1 = ligado. [Rage] NPCVisual / PlayerVisual: 0 nada, 1 brilho, 2 simbolo, 3 os dois.
Function OnNahRage(string eventName, string strArg, float numArg, Form sender)
	Actor a = sender as Actor
	if !a
		return
	endif
	int mode = NahIDWinNative.IniGetF("Rage", "NPCVisual", 1.0) as int
	if a == Game.GetPlayer()
		mode = NahIDWinNative.IniGetF("Rage", "PlayerVisual", 1.0) as int
	endif
	if strArg == "supreme"
		mode = 3
	endif
	Spell glow = None
	Spell symbol = None
	if mode == 1 || mode == 3
		glow = Game.GetFormFromFile(0x00000841, "NahIDWin.esp") as Spell
	endif
	if mode == 2 || mode == 3
		symbol = Game.GetFormFromFile(0x00000843, "NahIDWin.esp") as Spell
	endif
	Spell fire = None
	if strArg == "supreme"
		fire = Game.GetFormFromFile(0x00000845, "NahIDWin.esp") as Spell
	endif
	string gs = "MISSING"
	string ss = "MISSING"
	if glow
		gs = "ok"
	endif
	if symbol
		ss = "ok"
	endif
	NahIDWinNative.Log("rage visual: mode " + mode + " glow " + gs + " symbol " + ss)
	if numArg > 0.0
		if glow
			glow.Cast(a, a)
		endif
		if symbol
			symbol.Cast(a, a)
		endif
		if fire
			fire.Cast(a, a)
		endif
		if strArg == "supreme" && a == Game.GetPlayer()
			string an = NahIDWinNative.GetSupremeAnim()
			if an != ""
				NahIDWinNative.Log("supreme rage: animation event " + an)
				Debug.SendAnimationEvent(a, an)
			endif
		endif
		Utility.Wait(numArg)
	endif
	if glow
		a.DispelSpell(glow)
	endif
	if symbol
		a.DispelSpell(symbol)
	endif
	if fire
		a.DispelSpell(fire)
	endif
EndFunction

; 0 = sem peca ou roupa, 0.5 = leve, 1.0 = pesada
float Function PieceScore(Actor pl, int mask)
	Armor ar = pl.GetWornForm(mask) as Armor
	if !ar
		return 0.0
	endif
	int wc = ar.GetWeightClass()
	if wc == 1
		return 1.0
	elseif wc == 0
		return 0.5
	endif
	return 0.0
EndFunction

; Regeneracao de estamina do jogador conforme a armadura (100 = normal).
float lastRegen = -1.0
bool inCombatNow = false
Function ApplyRegen()
	Actor pl = Game.GetPlayer()
	inCombatNow = pl.IsInCombat()
	NahIDWinNative.SetLeftType(pl.GetEquippedItemType(0))
	float ww = 0.0
	int slotMasks = 0
	Form wf
	wf = pl.GetWornForm(4)
	if wf
		ww += wf.GetWeight()
	endif
	wf = pl.GetWornForm(1)
	if wf
		ww += wf.GetWeight()
	endif
	wf = pl.GetWornForm(8)
	if wf
		ww += wf.GetWeight()
	endif
	wf = pl.GetWornForm(128)
	if wf
		ww += wf.GetWeight()
	endif
	NahIDWinNative.SetWornWeight(ww)
	; classe de defesa por peca: corpo .45, cabeca/maos/pes .15, escudo .10; armadura leve vale .5, pesada 1, roupa 0
	float sc = PieceScore(pl, 4) * 0.45 + PieceScore(pl, 1) * 0.15 + PieceScore(pl, 8) * 0.15 + PieceScore(pl, 128) * 0.15 + PieceScore(pl, 512) * 0.10
	NahIDWinNative.SetWornScore(sc)
	float r = NahIDWinNative.GetCombatRegen(inCombatNow)
	if r >= 0.0 && Math.Abs(r - lastRegen) > 1.0
		lastRegen = r
		pl.SetActorValue("StaminaRateMult", r)
	endif
EndFunction

; Cada golpe do jogador gasta estamina (mesmo sem acertar). O custo depende da arma, do tipo de golpe e da armadura.
Event OnAnimationEvent(ObjectReference akSource, string asEventName)
	Actor pl = Game.GetPlayer()
	if asEventName == "recoilStop" || asEventName == "staggerStop" || asEventName == "ragdollEnd" || asEventName == "GetUpStart" || asEventName == "GetUpEnd"
		NahIDWinNative.Log("PLAYER ANIM: " + asEventName)
		return
	endif
	if asEventName == "staggerStart" || asEventName == "recoilStart" || asEventName == "recoilLargeStart" || asEventName == "bleedOutStart" || asEventName == "KnockDown" || asEventName == "ragdollStart"
		NahIDWinNative.Log("PLAYER ANIM: " + asEventName + " (stamina " + pl.GetActorValue("Stamina") + ")")
		if asEventName == "staggerStart"
			OnPlayerStagger()
		endif
		return
	endif
	int mode = 0
	if asEventName == "bashStart" || asEventName == "bashPowerStart"
		mode = 2
	elseif asEventName != "weaponSwing" && asEventName != "weaponLeftSwing"
		mode = 1
	endif
	int hand = 1
	if asEventName == "weaponLeftSwing"
		hand = 0
	endif
	float wgt = 0.0
	Form wo
	if mode == 2
		wo = pl.GetEquippedObject(0)
	else
		wo = pl.GetEquippedObject(hand)
	endif
	if wo
		wgt = wo.GetWeight()
	endif
	float cost = NahIDWinNative.GetSwingCost(mode, pl.GetEquippedItemType(hand), wgt)
	if cost > 0.0
		pl.DamageActorValue("Stamina", cost)
		if pl.GetActorValue("Stamina") <= 0.0
			if NahIDWinNative.TryExhaust()
				DoExhaustPlayer()
			endif
		endif
	endif
	if exhaustedNow
		NahIDWinNative.SelfPoise(mode == 1)
	endif
	ApplyRegen()
EndEvent

; Exhaustion (player): no stamina regen for a few seconds, reduced move speed. Non-blocking: the end is checked from OnUpdate.
Function DoExhaustPlayer()
	Actor pl = Game.GetPlayer()
	if exhaustedNow
		return
	endif
	exhaustedNow = true
	exhStart = Utility.GetCurrentRealTime()
	exhMin = NahIDWinNative.GetExhaustSeconds()
	exhMax = NahIDWinNative.GetExhaustMax()
	float sf = NahIDWinNative.IniGetF("Exhaustion", "SpeedFactor", 0.5)
	speedCut = 0.0
	if sf >= 0.0 && sf < 1.0
		speedCut = pl.GetActorValue("SpeedMult") * (1.0 - sf)
		pl.ModActorValue("SpeedMult", -speedCut)
	endif
	float af = NahIDWinNative.IniGetF("Exhaustion", "AttackSpeedFactor", 0.7)
	atkCut = 0.0
	if af >= 0.0 && af < 1.0
		atkCut = pl.GetActorValue("WeaponSpeedMult") * (1.0 - af)
		pl.ModActorValue("WeaponSpeedMult", -atkCut)
	endif
	lastRegen = 0.0
	pl.SetActorValue("StaminaRateMult", 0.0)
	NahIDWinNative.Log("exhaust player start " + exhMin)
	if NahIDWinNative.GetLanguage() == 1
		Debug.Notification("NAH-I-D-WIN: EXAUSTO!")
	else
		Debug.Notification("NAH-I-D-WIN: EXHAUSTED!")
	endif
	RegisterForSingleUpdate(0.5)
EndFunction

; Called every update while exhausted: ends it when min time passed and (max time reached or stamina >= target).
Function CheckExhaust()
	if !exhaustedNow
		return
	endif
	Actor pl = Game.GetPlayer()
	float el = Utility.GetCurrentRealTime() - exhStart
	if el < 0.0
		el = exhMax + 99.0
	endif
	float tgtP = NahIDWinNative.GetExhaustTarget()
	bool done = false
	float stopSec = NahIDWinNative.IniGetF("Exhaustion", "StopSeconds", 1.5)
	bool stopped = NahIDWinNative.ExhaustSwingAgo() >= stopSec
	if el >= exhMin
		if el >= exhMax
			done = true
		elseif stopped && pl.GetActorValue("Stamina") >= pl.GetActorValueMax("Stamina") * tgtP / 100.0
			done = true
		endif
	endif
	if el >= exhMax + 4.0
		done = true
	endif
	if done
		EndExhaust()
	endif
EndFunction

Function EndExhaust()
	Actor pl = Game.GetPlayer()
	NahIDWinNative.ExhaustEnded()
	if speedCut > 0.0
		pl.ModActorValue("SpeedMult", speedCut)
		speedCut = 0.0
	endif
	if atkCut > 0.0
		pl.ModActorValue("WeaponSpeedMult", atkCut)
		atkCut = 0.0
	endif
	float rec = NahIDWinNative.IniGetF("Exhaustion", "RecoverStamina", 50.0)
	float curSt = pl.GetActorValue("Stamina")
	; so recebe o bonus quem parou de bater; quem insistiu ate ao limite fica so com a regeneracao normal
	if NahIDWinNative.ExhaustSwingAgo() < NahIDWinNative.IniGetF("Exhaustion", "StopSeconds", 1.5)
		rec = 0.0
	endif
	if rec > curSt
		pl.RestoreActorValue("Stamina", rec - curSt)
	endif
	exhaustedNow = false
	lastRegen = -1.0
	ApplyRegen()
EndFunction

float exhStart = 0.0
float exhMin = 2.0
float exhMax = 8.0
bool exhaustedNow = false
float speedCut = 0.0
float atkCut = 0.0

; sender = a vitima. numArg = sequencia * 8 + tipo (1..6). strArg = form id do agressor (decimal, pode ser negativo).
Function OnNahStagger(string eventName, string strArg, float numArg, Form sender)
	int packed = numArg as int
	int kind = packed % 8
	Actor victim = sender as Actor
	if victim
		if kind == 4
			Actor aggr = None
			int aid = strArg as int
			if aid != 0
				aggr = Game.GetForm(aid) as Actor
			endif
			DoBleedOut(victim, packed, aggr)
			return
		endif
		if kind == 6
			DoParryFX(victim)
			NahIDWinNative.Ack(packed)
			return
		endif
		if kind == 7
			if victim == Game.GetPlayer()
				NahIDWinNative.Ack(packed)
				DoExhaustPlayer()
				return
			endif
			; NPC sem estamina: stagger pesado
		endif
		if victim == Game.GetPlayer() && kind == 3
			; player heavy stagger: the vanilla backward stumble (like a giant or a shout), no knockdown and no bleedout
			victim.SetAnimationVariableBool("bNoStagger", false)
			victim.SetAnimationVariableFloat("StaggerMagnitude", NahIDWinNative.IniGetF("Stagger", "PlayerHeavyMagnitude", 1.0))
			NahIDWinNative.OwnAnim(700)
			Debug.SendAnimationEvent(victim, "StaggerStart")
			NahIDWinNative.Ack(packed)
			return
		endif
		if victim == Game.GetPlayer() && sNoStagger && kind >= 2
			; stagger do nosso mod (poise quebrado etc.) tem de passar mesmo durante a janela de imunidade
			victim.SetAnimationVariableBool("bNoStagger", false)
		endif
		int tierSpell = kind
		if kind == 5 || kind == 7
			tierSpell = 3
		endif
		Spell sp = GetSpellForTier(tierSpell)
		if sp
			Actor attacker = None
			int attackerId = strArg as int
			if attackerId != 0
				attacker = Game.GetForm(attackerId) as Actor
			endif
			if attacker && attacker != victim
				sp.Cast(attacker, victim)
			else
				sp.Cast(victim, victim)
			endif
			if kind == 5
				float force = NahIDWinNative.GetKnockbackForce()
				if force > 0.0 && attacker && attacker != victim
					attacker.PushActorAway(victim, force)
				endif
			endif
		endif
	endif
	NahIDWinNative.Ack(packed)
EndFunction

; Faiscas e som do parry: formas proprias do NahIDWin.esp (os ficheiros .nif/.wav vem do pacote de efeitos).
Function DoParryFX(Actor victim)
	Explosion ex = Game.GetFormFromFile(0x00000810, "NahIDWin.esp") as Explosion
	if ex
		victim.PlaceAtMe(ex)
	endif
	int left = victim.GetEquippedItemType(0)
	int right = victim.GetEquippedItemType(1)
	Sound snd
	if left == 10
		snd = Game.GetFormFromFile(0x00000811, "NahIDWin.esp") as Sound
	elseif right == 0
		snd = Game.GetFormFromFile(0x00000812, "NahIDWin.esp") as Sound
	elseif right == 2
		snd = Game.GetFormFromFile(0x00000813, "NahIDWin.esp") as Sound
	elseif right == 4 || right == 6
		snd = Game.GetFormFromFile(0x00000814, "NahIDWin.esp") as Sound
	else
		snd = Game.GetFormFromFile(0x00000815, "NahIDWin.esp") as Sound
	endif
	if snd
		snd.Play(victim)
	endif
	; jogador: animacao de impacto no bloqueio (o script do Inpa que a tocava nao responde)
	if victim == Game.GetPlayer()
		Debug.SendAnimationEvent(victim, "blockHitStart")
	endif
EndFunction

; BleedOut: ajoelhado e indefeso. O jogador perde o controlo durante esse tempo.
Function DoBleedOut(Actor victim, int packed, Actor aggressor)
	NahIDWinNative.Ack(packed)
	float secs = NahIDWinNative.GetBleedSeconds()
	bool isPlayer = (victim == Game.GetPlayer())
	if isPlayer
		ctrlHeld = true
		Game.DisablePlayerControls(true, true, false, false, false, false, false, false, 0)
	endif
	NahIDWinNative.Log("bleedout start " + secs)
	; NPC com o Inpa fundido: postura quebrada = o "poisebreak" do Inpa (stagger grande, som e janela de execucao com animacao do jogo base).
	; Sem o Inpa (ou no jogador) fica a animacao de ajoelhado de sempre.
	Spell pb = None
	if !isPlayer
		pb = Game.GetFormFromFile(0x0075FAAD, "NahIDWin.esp") as Spell
	endif
	if pb
		NahIDWinNative.OwnAnim(700)
		DoInpaPostureBreak(victim, aggressor, pb)
	else
		; Repete o pedido de BleedoutStart ate o grafo de animacao o aceitar (a DLL diz se aceitou).
		int vid = victim.GetFormID()
		int tries = 0
		bool ok = false
		while tries < 6 && !ok
			NahIDWinNative.OwnAnim(600)
			Debug.SendAnimationEvent(victim, "BleedoutStart")
			Utility.Wait(0.25)
			ok = NahIDWinNative.BleedAccepted(vid)
			tries += 1
		endwhile
		NahIDWinNative.Log("bleedout animation accepted=" + ok + " after " + tries + " tries")
		if !ok
			victim.PushActorAway(victim, 0.0)
		endif
	endif
	Utility.Wait(secs)
	if !victim.IsDead() && !pb
		NahIDWinNative.OwnAnim(1500)
		Debug.SendAnimationEvent(victim, "BleedoutStop")
	endif
	if isPlayer
		Game.EnablePlayerControls(true, true, true, true, true, true, true, true, 0)
		ctrlHeld = false
	endif
	NahIDWinNative.BleedDone(packed)
EndFunction

Spell Function GetSpellForTier(int tier)
	if tier <= 1
		if !sp1
			sp1 = Game.GetFormFromFile(0x00000801, "NahIDWin.esp") as Spell
		endif
		return sp1
	elseif tier == 2
		if !sp2
			sp2 = Game.GetFormFromFile(0x00000802, "NahIDWin.esp") as Spell
		endif
		return sp2
	endif
	if !sp3
		sp3 = Game.GetFormFromFile(0x00000803, "NahIDWin.esp") as Spell
	endif
	return sp3
EndFunction

; Igual ao que o Inpa faz quando o poise do inimigo quebra, mas disparado pela NOSSA postura e sem mexer na estamina do alvo.
Function DoInpaPostureBreak(Actor victim, Actor aggressor, Spell pb)
	victim.SetAnimationVariableBool("bNoStagger", false)
	victim.SetAnimationVariableFloat("StaggerMagnitude", 10.0)
	if !victim.IsDead() && !victim.IsInKillMove()
		Debug.SendAnimationEvent(victim, "StaggerStart")
	endif
	Actor caster = aggressor
	if !caster
		caster = Game.GetPlayer()
	endif
	if caster == Game.GetPlayer()
		Sound mk = Game.GetFormFromFile(0x00006E76, "NahIDWin.esp") as Sound
		if mk
			mk.Play(caster)
		endif
	endif
	pb.Cast(caster, victim)
	victim.SetAnimationVariableBool("isBlocking", false)
	NahIDWinNative.Log("posture break -> Inpa poisebreak cast on " + victim)
EndFunction

; Substitui o "cloak" do Inpa: so quem entra em combate recebe os feiticos dele (aliado ou inimigo), uma vez por carregamento.
Function OnNahCombatant(string eventName, string strArg, float numArg, Form sender)
	Actor a = sender as Actor
	if !a || a == Game.GetPlayer() || a.IsDead()
		return
	endif
	Spell sp
	if Game.GetPlayer().GetFactionReaction(a) == 2
		sp = Game.GetFormFromFile(0x00908EDF, "NahIDWin.esp") as Spell
	else
		sp = Game.GetFormFromFile(0x000048BF, "NahIDWin.esp") as Spell
	endif
	if sp && !a.HasSpell(sp)
		a.AddSpell(sp, false)
	endif
EndFunction
