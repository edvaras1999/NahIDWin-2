# NAH-I-D-WIN (NahIDWin)

**Poise + Postura** para Skyrim **Legendary Edition** (1.9.32.0 + SKSE 1.7.3), separados da stamina.

- **Poise** (barra rapida): cada golpe tira poise. Sem quebrar: stagger *leve* (golpe normal) ou *medio* (golpe forte / escudo). Quebrou: stagger *pesado*.
- **Postura** (barra lenta, estilo Sekiro): cada golpe enche-a, ela baixa sozinha. Encheu por completo: **BleedOut** (ajoelhado e indefeso).
- Golpes bloqueados enchem as duas barras so um pouco e nao dao stagger. A dificuldade da postura esta no `.ini` (`[Posture] Difficulty`).

Estado: **v0.7.0** (ainda nao testado no jogo). Novo: o parry passou a ser uma **janela de imunidade total** aberta ao carregar no bloqueio (250 ms, recarga 200 ms, so golpes de frente), decidida so pelo tempo e sem devolver vida; o bloqueio normal do jogo fica intacto e apenas gasta estamina ao atacante; no parry o atacante leva postura, stagger leve e perde estamina (sem mexer no poise). Efeitos (faiscas/sons) proprios no NahIDWin.esp: os ficheiros .nif/.wav vem do pacote `NahIDWin-efeitos-inpa.zip` (instalar a parte, nao vai para o repositorio).

## Como compilar (tudo no GitHub)
1. Cria um repositorio novo e envia estes arquivos mantendo as pastas.
2. Aba **Actions** > "Build NahIDWin" > **Run workflow** (tambem corre sozinho a cada envio).
3. No fim, baixa o artefacto **NahIDWin-instalacao**: e um zip pronto para instalar (MO2).
   Se algum passo falhar, baixa tambem os artefactos `dll` e `papyrus` (tem os logs) e envia-os.

## Instalar para testar
Instala o zip pelo MO2 e ativa **NahIDWin.esp**. Precisa de SKSE 1.7.3. Para ver barras: TrueHUD LE com as "special bars" ligadas.
Configuracao: `Data/SKSE/Plugins/NahIDWin.ini` (relido sozinho). Log: `Documentos/My Games/Skyrim/SKSE/NahIDWin.log`.

## Como funciona o stagger
- `StaggerMode=0` (por omissao): a DLL faz as contas e, **quando e preciso reagir (qualquer stagger ou BleedOut)**, envia um evento de mod.
  O script `NahIDWinBridge` (poucas linhas) recebe-o e lanca um de tres feiticos de stagger do jogo (leve/medio/pesado); no BleedOut toca a animacao de ajoelhado durante `BleedOutSeconds`.
- `StaggerMode=1` (experimental): sem Papyrus. A DLL tenta tocar a animacao de stagger. Serve para o diagnostico.

## Diagnostico
O log traz: cada golpe com as contas, o resumo a cada 30 s (eventos enviados, confirmados pelo script, atraso medio e maximo),
avisos se o script nao responde, e um despejo das funcoes de animacao do jogador. Envia o log depois de uma luta.

## Licenca
GPL-3.0 (ver `nahidwin/LICENSE`). A base de compilacao e os enderecos vem do FreeClimb LE / SoftTarget LE. Os registos do efeito de stagger
seguem o mod "SGC Stagger on hit". Referencias: doodlum "Poise" (SE) e a API do TrueHUD LE (Mhacks79, baseada no TrueHUD de Ersh).


## v0.9.0 - menu unico (herda o menu do Inpa Sekiro Combat)
- `papyrus/src/NahIDWinMCM.psc` agora `extends zzzSekiro_MCM`: as paginas "MOD Setting" e "Game Setting" (com o interruptor MOD On/Off) sao do Inpa,
  sem alteracoes; as paginas "Poise and Posture", "Block and Rage" e "Stamina, HUD, System" sao as nossas. A pagina inicial fica sem imagem.
  O interruptor MOD On/Off do Inpa tambem poe `General Enabled` no .ini.
- `papyrus/stubs/zzzSekiro_MCM.psc` e so um apoio para compilar. O script verdadeiro vem do pacote privado (Inpa).
- `tools/make_esp.py` ja nao cria quest de menu: o menu so existe com o ESP fundido (`tools/merge_inpa.py`).
- Ressurreicao desligada por omissao; cloak neutralizado; os feitiços de NPC e aliados vao por SPID (NahIDWin_DISTR.ini, obrigatorio).

## v0.9.1
- Removida a pasta `dist/Data/meshes` (25 ficheiros .hkx de 0 bytes substituíam as animações verdadeiras de bloqueio e stagger).
- Postura quebrada num NPC = `poisebreak` do Inpa (stagger grande, som, janela de execução com animação do jogo base), disparado pela NOSSA postura, sem mexer na estamina do alvo. Sem o Inpa (ou no jogador) fica a animação de ajoelhado.
- O SPID geral foi retirado: a DLL avisa o script ponte quando um ator entra em combate (`NahIDWin_Combatant`) e o script dá-lhe o feitiço do Inpa (aliado ou inimigo) uma vez. O SPID serve só para o perk de bloqueio dos NPCs.
- `PowerStart` declarado em NahIDWinNative.psc (o log da v0.9.0 avisava que faltava).

## v0.9.2
- O pacote do Actions deixou de levar NahIDWin.esp e .seq (vêm só do pacote privado), para não haver dois ESP com o mesmo nome. O .ini do repositório já vem com `[Inpa] Mode=1`.

## v0.10.0 - menu proprio (3 abas), sem herdar do Inpa
- `NahIDWinMCM.psc` e um menu novo (SKI_ConfigBase), no estilo do Inpa (cabecalhos laranja, MOD On/Off), com tres abas: MOD Setting, Game Setting e Advanced.
  As opcoes do Inpa gravam nos mesmos globais dele e aplicam os mesmos Game Settings (o Inpa reaplica-os ao carregar); as nossas gravam no .ini.
- MOD On/Off liga/desliga Inpa + NahIDWin (General Enabled).
- Removido do menu: Regenerate Stamina, Posture Damage Mult do Inpa, Ressurreicao, PowerAttack stamina limit, modos de execucao do VioLens, barras extras.
- Novo: `[NpcBlock] ChanceMin` (chance de bloqueio dos NPCs, reposta pela ponte apos o Inpa); sliders Combat Stamina Regen e Stamina Regen Delay.
- `zzzSekiro_MCM.pex` ja nao e usado nem enviado. Stub novo: GlobalVariable.

## v0.10.1
- Estamina baixa deixa de quebrar a postura do jogador: `tools/pexpatch_stamina.py` neutraliza, nos scripts do Inpa (`zzzSekiro_player_main.pex`, `zzzSekiro_player_parry.pex`), a regra "estamina <= 10 ao levar golpe -> deathblow_ME". So a nossa barra de postura quebra a postura.
- Janela de imunidade do jogador depois de um stagger do jogo (`[Stagger] PlayerImmuneAfterSeconds`, 1.5 s; 0 = desligado), via `bNoStagger`. Staggers pesados do mod passam sempre.
- Furia dos NPCs com visual: `[Rage] NPCVisual` 0 nada, 1 brilho, 2 simbolo vermelho, 3 os dois (luz e desenho do Inpa, sem o script de ataque perigoso). Novo evento `NahIDWin_Rage`.

## v0.10.2
- Visual da furia tambem no jogador (`[Rage] PlayerVisual`, mesma escala 0-3). A ponte escreve no log `rage visual: mode N glow ok/MISSING symbol ok/MISSING`.
- Diagnostico das quedas do jogador: linhas `PLAYER ANIM: staggerStart/recoilStart/recoilLargeStart/bleedOutStart/KnockDown/ragdollStart` no log, na ordem em que acontecem, entre os golpes e custos de estamina.

## v0.11.0 - HUD proprio (fase 1)

- Novo `Data/Interface/NahIDWinHUD.swf` (ActionScript 2), carregado pela DLL dentro do "HUD Menu" (como o moreHUD).
- Mostra **barra de postura** e **barra de furia** (tempo restante enquanto ativa; recarga caso contrario) no jogador (por baixo da estamina) e no alvo da mira (por baixo da barra de vida do inimigo, ancorada a ela). Icone losango piscante quando a furia esta ativa.
- Poise continua na barra especial do TrueHUD.
- Nova seccao `[HUD]` no .ini e bloco "HUD (barras proprias)" no menu (Advanced).
- Fase 2 (por fazer): alvo por raio em volta da mira quando nao ha lock-on.
- Log: procura `scaleform interface: NahIDWinHUD registered` e `hud widget: NahIDWinHUD.swf load requested (ok)`.

### v0.11.0 (correcoes apos o primeiro teste)
- Menu: a tabela de opcoes antiga ficava guardada no save e a seccao "HUD (own bars)" aparecia vazia. Agora a tabela e refeita quando muda a revisao.
- HUD do alvo: se nao ha lock-on usa o alvo debaixo da mira (crosshair); se a barra de vida do jogo estiver escondida (TrueHUD) usa a posicao fixa `TargetFallbackX/Y`. Log: `hud widget: target ...`.
- Bridge: re-regista eventos de mod/animacao a cada load (saves antigos nao tinham o evento da furia); log `bridge 0.11.0: ...`.
- O custo de vida da furia deixou de ser reduzido pela propria furia.

## v0.12.0

- **Furia**: reducao extra de dano (25-50%, por cima de toda a resistencia; so afeta o dano que ainda chega a vida), bonus de dano (10-30%, armas e magias), custo em vida 10-30% (omissao 20%), imunidade a stagger durante a furia (jogador e NPCs). Chaves novas no `.ini` `[Rage]`: `LifeCostPercent`, `ExtraReduction`, `NPCExtraReduction`, `DamageBonus`, `NPCDamageBonus`, `StaggerImmune` (as antigas `DamageReductionPercent` deixam de ser usadas).
- **Golpes fortes**: o jogador nao leva stagger durante `[Stagger] PowerAttackImmuneSeconds` (2 s) depois de iniciar um golpe forte.
- **HUD**: barras do alvo em posicao fixa por defeito (`TargetAnchor=0`); escondem-se com qualquer menu aberto.
- Diagnostico: mais eventos de animacao no log (`PLAYER ANIM`).
- Por fazer: modo manual com aura de fogo (G liga/desliga, 10 s, 2%/s de vida, animacao via DAR).

## v0.13.0

- **Queda ao quebrar o poise de um inimigo (causa raiz)**: `Actor.PushActorAway(alvo, forca)` empurra o argumento para longe de quem chama. O script chamava `vitima.PushActorAway(atacante)`, ou seja empurrava o ATACANTE (o jogador). Agora e `atacante.PushActorAway(vitima)`.
- **Escudo de stagger na furia (jogador e NPCs)**: a DLL encadeia a funcao de notificacao do grafo de animacao e ignora `staggerStart` / `recoilStart`... enquanto o ator esta em furia. Os nossos proprios staggers passam sempre. `[Rage] StaggerImmune=0` desliga. A imunidade em golpes fortes foi retirada.
- **Barras estilo Sekiro**: a postura enche dos dois lados para o centro (`[HUD] BarStyle=1`; 0 = plana). Posicao por preset (esquerda/centro/direita x cima/centro/baixo) + ajuste X/Y em pixeis, para jogador e alvo, no menu e no ini.
- Log: `stagger shield: hook installed...` e `shield blocked=N` no SUMMARY.

## v0.14.0

- **Vidas extra do jogador** (`[Lives]`): 2a vida no nivel 30, 3a no nivel 60. Quando o dano mataria o jogador, a DLL deixa-o a 1 de vida, repoe 50%, da 3 s de invulnerabilidade e o Bridge tira 25% do ouro. Enchem ao dormir numa cama (esperar nao conta). Guardado no save pelo Bridge (`livesUsed`).
- **Supremo Rage** (`[Supreme]`, tecla H, ligar/desligar): 10 s, custo 2% da vida por segundo, aura que queima inimigos hostis num raio, mais tudo o que a furia normal da. Recarga de 500 s.
- **HUD**: losangos das vidas extra (laranja = disponivel, cinzento = gasta) e estrela do Supremo Rage (laranja = pronto, cinzento = recarga, pisca = ativo) junto das barras.
- **Menu retratil**: cada bloco abre/fecha (estado em `[MenuOpen]` do ini) e as opcoes de uma funcao desligada ficam escondidas.
- Pendente: efeito visual de fogo na aura (por agora brilho + simbolo da furia) e a animacao.

## v0.15.0

- **Bleedout fiavel**: o Papyrus repete o pedido de `BleedoutStart` ate o grafo de animacao o aceitar (a DLL diz se aceitou; se falhar 6 vezes o personagem e empurrado ao chao). Durante o bleedout (e na janela ate a animacao arrancar) o escudo de stagger bloqueia stagger leve e recuos, que cancelavam o bleedout.
- **Vida extra com bleedout**: ao gastar uma vida o jogador cai em bleedout, fica invulneravel e levanta-se com a vida reposta.
- **Bosses com 2 vidas** (`[Bosses]`): NPC unico (flag do jogo) com nivel minimo (30), nao companheiro. Ao gastar a 1a vida volta com a vida (100%) e cai em bleedout. Execucao e dragoes/gigantes ficam para a v0.16.0.
- **HUD**: vidas extra em circulos verdes (jogador) e vermelhos (bosses); estrela laranja do Supremo Rage. Postura estilo Sekiro agora enche do centro para as extremidades e pisca vermelho quando cheia.
- **TrueHUD**: a barra especial passa a ser o POISE (a descer; a zero: stagger pesado). `Bar=0` por omissao; a postura fica nas barras proprias.
- **Menu/ini**: gasto de estamina por golpe do jogador e do NPC, ligado, 10 e 10 por omissao.

## v0.15.1

- **Vidas extra pelo metodo do SkyTweak** (`[Lives] EssentialBleedout=1`): enquanto o jogador tem vidas fica marcado como essencial e o jogo faz o bleedout verdadeiro (sem dano que o mate). Passado o tempo de bleedout o Bridge acaba o combate, repoe a vida (`ResetHealthAndLimbs`) e a DLL baixa-a para `HealthPercent`. Sem vidas, a flag sai e a morte e normal. `0` volta ao metodo antigo.

## v0.15.2

- **Essencial como o SkyTweak**: a flag e posta pelo Papyrus (`GetActorBase().SetEssential`) assim que o save carrega e o jogador tem vidas (e retirada quando acabam). A DLL so avisa por evento (reenvia de 10 em 10 s). Bosses: marcados no 1o golpe; quando a vida acaba o jogo faz o bleedout, o script repoe a vida, tira a flag e volta ao combate.
- **Inimigos voltam a lutar** quando o jogador revive (os ultimos 4 atacantes recebem `StartCombat`).
- **Sem empurrao em gigantes/dragoes** (`[Knockback] VictimMassMax=3`): o ragdoll deles ficava preso no ar a andar para tras.

## v0.15.3

- **Bleedout nao e cortado**: durante o bleedout verdadeiro (jogador essencial) a nossa logica ja tratava os golpes como normais e disparava stagger leve nativo, o que cortava a animacao. Agora o jogador fica "em bleedout" tambem para a DLL (sem stagger, sem poise/postura) durante o tempo todo (minimo 5 s, como o SkyTweak).
- **Sem forcar combate**: removido o `StartCombat` aos atacantes. Ordem igual ao SkyTweak: `StopCombatAlarm` no inicio do bleedout, espera, `ResetHealthAndLimbs`.
- **Vida depois de reviver**: o ajuste para `HealthPercent` era anulado pela invulnerabilidade (ficava a 100%); corrigido.
- A marca essencial tambem e verificada a cada dano ao jogador, alem do relogio do HUD.

## v0.16.0

- **Execucao garantida** (`[Execution]`): um golpe de arma do jogador num alvo com a postura quebrada pede ao Bridge o feitico de execucao do Inpa (modo lido do global `zzzSekiro_killmove`), sem depender do `OnHit` dele. Gigantes/dragoes (massa alta): morrem (`KillBigCreatures`).
- **Bosses** (`[Bosses]`): postura e poise x1.5; na 1a fase a postura quebrada so da stagger pesado; so sao executaveis depois de gastarem a 1a vida. **Criaturas grandes** (`[BigCreatures]`): poise e postura x1.5.
- **Vida extra do jogador**: a DLL escreve tambem a flag essencial diretamente (alem do Papyrus) e regista no log o estado dela; se o jogo nao fizer o bleedout (`IsBleedingOut` falso) o script faz a animacao como rede de seguranca. Sem forcar a animacao quando o jogo a faz.
- **Fogo do Supremo Rage**: feitico `NahIDWin_SupFire` (0x845), so no pacote privado (efeitos do jogo base). `[Supreme] ActivationAnim` = evento de animacao opcional (experimental).
- **HUD**: a barra de postura pulsa com contorno vermelho a partir de 80% e pisca inteira ao quebrar.
- **Menu**: opcoes de bosses, criaturas grandes e execucao no bloco das vidas extra.

## v0.17.0
- Bosses: inimigo com `[Bosses] LevelMargin` (7) niveis acima do jogador.
- Magia continua: no maximo 1 golpe por segundo; poise/postura x `[Magic] DotPoiseMult`. Deflexao: parry numa magia + segurar bloqueio devolve a magia (`[Magic] DeflectEnabled`).
- Parry nao conta duas vezes o mesmo ataque.
- Gigantes/dragoes: furia x`[BigCreatures] RageDurationMult`, sem custo de vida (tambem bosses). Menu: o slider "Estamina dos dragoes" foi trocado pelo bloco "Bosses, gigantes e dragoes".
- Ataque perigoso (`[Perilous]`): aviso com simbolo, ignora o bloqueio, parry da postura extra ao atacante.
- Barra do alvo: lock-on do Soft Target LE (precisa do SoftTargetLE.dll novo), lock-on do jogo, crosshair, ou inimigo a menos de `[HUD] TargetRadius` px do centro; fica `TargetStickyMs` ms depois.
- Menu: removidas 8 linhas (ficam no .ini) por causa do limite de 128 entradas do Papyrus.

## v0.17.1
- Barra do alvo por raio: so inimigos hostis (que trocaram golpes contigo nos ultimos 60 s), em combate, a menos de `[HUD] TargetMaxDistance` (2000).
- Execucao: nao arranca se ja ha uma execucao/kill move em curso; registos novos (`EXEC-WATCH`, `PLAYER LETHAL HIT`, `execution watch`) para descobrir o que mata o jogador.

## v0.18.0
- Exaustao do jogador: ja nao bloqueia os controlos de combate (o jogo embainhava a arma); so deixa de regenerar estamina.
- Furia automatica dos NPCs: so bosses e gigantes/dragoes.
- `FLEE-WATCH` no log: regista quando um inimigo hostil deixa de combater estando vivo.
- Supremo Rage: lanca a marca `NahIDWin_SupAnim` (3 s, so no pacote privado) e envia o evento `[Supreme] ActivationAnim` (por defeito `attackPowerStartForward`). O Dynamic Animation Replacer usa a marca como condicao (pacote privado).

## v0.18.1
- Exaustao do jogador: ataque, ataque forte, bash, bloqueio e salto ficam bloqueados no grafo de animacao durante `[Exhaustion] Seconds`, sem bloquear os controlos.
- Barras so para inimigos hostis (criterio do proprio jogo), tambem no lock-on e na mira.
- Execucao: `[Execution] Method` (0 espera pela execucao do Inpa para nao haver duas ao mesmo tempo).
- `FLEE-WATCH` com agressao, confianca e velocidade.

## v0.18.2
- Parry: o evento de animacao `blockHitStart` do jogador so passa uma vez por 600 ms (a animacao do parry tocava duas vezes). Registo `PLAYER-ANIM-EVENT` para confirmar.
- Vigia de NPCs: tambem os hostis do jogo que ainda nao trocaram golpes (`HOSTILE-SEEN`, `FLEE-WATCH`).

## v0.19.0 - parry nativo, exaustao e estamina
- Parry (modo Inpa): a DLL decide pelo tempo desde que se carrega no bloqueio (`[Parry] NativeInpa=1`). Se o Papyrus do Inpa nao abriu a janela (`control=2`), a DLL abre-a. O log mostra `Inpa: parry check` e `PARRY (native)`.
- Exaustao: 10 s por omissao, movimento a metade (`SpeedFactor`), mais dano de poise/postura (`PoiseDamageMult`), recupera 50 de estamina no fim (`RecoverStamina`).
- Regeneracao em combate: mais rapida, atraso curto depois de bater, mais lenta a bloquear, parada enquanto bates (`[Stamina] CombatRegen*`).
- NPCs: o dreno de estamina do mod nao desce abaixo de 25 % (`NpcStaminaFloorPercent`); ao chegar la entram em exaustao e recuperam 50 %, para a IA nao recuar/fugir.
- Ciclo de 0,3 s no script ponte (regeneracao e fim da imunidade ao stagger).

## v0.19.1 - parry
- Corrigido: a DLL punha `zzzSekiro_control = 1` e o Inpa nao o repunha a 2, por isso todo o bloqueio seguinte contava como parry. Agora, com `[Parry] NativeInpa=1`, so conta o tempo desde que se carrega no bloqueio; o `control` volta a 2 ao fim de 0,5 s (e sempre que ficar preso a 1).

## v0.20.0 - parry refeito, menu sem "Plus"
- Parry como no Sekiro, decidido so pela DLL: o golpe chega ate `[Parry] WindowMs` (300 ms) depois de carregares no bloqueio. Soltar e carregar de novo abre outra janela; segurar depois da janela e bloqueio normal.
- Efeitos do parry (faiscas, som por arma, animacao de impacto, stagger e postura no atacante, estamina) ja funcionam tambem no modo Inpa (antes estavam desligados nesse modo).
- Removidas as contramedidas: `zzzSekiro_control`, janela de 500 ms, recarga entre janelas. So fica um parry por golpe do mesmo atacante (300 ms).
- Log: linha `parry check` por golpe bloqueado, com o tempo desde o clique.
- Menu: retirados "Jogador Plus", "NPC Plus" (menos o bloco Bosses) e "Aliados Plus".

## v0.20.1 - parry hibrido, menu
- Parry (modo Inpa): a DLL abre a janela do Inpa (`zzzSekiro_control = 1`) no instante em que carregas no bloqueio, sem esperar pelo Papyrus, e fecha-a (volta a 2) ao fim de 300 ms, ao largar o bloqueio ou num golpe bloqueado fora da janela. Os sons e efeitos sao os do Inpa (a DLL nao toca os dela nesse modo). Para voltar ao parry so da DLL: `[Parry] NativeInpa=0`.
- Exaustao: 5 s por omissao. Menu: velocidade do movimento, dano de poise/postura, estamina recuperada, piso de estamina dos NPCs, regeneracao em combate (%), pausa e fator ao bloquear.
- Menu: bloquear flechas/magia e resistir veneno passaram para o ini (`[Inpa] BlockArrow/BlockMagic/ResistPoison`, ligados); a frequencia de bloqueio dos NPCs so no ini (`[NpcBlock]`); "Mudar dificuldade" fica no menu, desligada na primeira vez, com os sliders a cinzento ate ligares.
- Ciclo do Papyrus: 0,5 s em combate, 2,5 s fora.

## v0.20.2 - parry do Inpa como na 0.16.0
- Modo Inpa: a DLL volta a so ler `zzzSekiro_control` (como na 0.16.0). Deixou de escrever nele.
- Removido o filtro do duplo `blockHitStart` (v0.18.1): engolia o evento que o script do Inpa usa para disparar o som e os efeitos do parry.
- O parry da DLL (janela de 300 ms desde o clique) fica so para quando o Inpa nao esta ativo (`[Inpa] Mode=0`).

## v0.20.3 - auto-reparacao do parry do Inpa
- Log 0.20.2: em 19 golpes bloqueados, o `control` do Inpa ficou sempre a 2 (mesmo 31 ms depois do clique) e nao houve nenhum `blockHitStart`: o script de parry do Inpa nao estava a correr (a latencia do Papyrus era baixa, 31 ms).
- O menu reaplica os feiticos do Inpa 4 s depois de carregar (`[Inpa] RefreshOnLoad=1`) e quando a DLL detecta 3 falhas seguidas (`[Inpa] AutoFix=1`, 1x por minuto). E o mesmo que desligar e ligar o MOD no menu.

## v0.21.0 - shout vanilla, ESP sem registos novos, dupla reacao
- O parry do Inpa quebrou com o `NahIDWin.esp` da v0.18.0 (registos 0x846/0x847), mesmo sem a pasta DAR. Volta a usar-se o ESP da v0.11.0. A marca de animacao, a pasta DAR e `tools/add_animmark.py` deixaram de existir.
- Supremo Rage: animacao vanilla de gritar (`[Supreme] ActivationAnim=shoutStart`; o ini lista nomes alternativos a tentar). O log mostra o evento enviado.
- Dupla reacao do parry: no modo Inpa, a DLL engole so o `blockHitStart` gerado pelo proprio jogo (thread principal) quando a janela do parry esta aberta; o do Inpa (Papyrus) passa sempre. `[Parry] SwallowGameReaction=1`. O log do `PLAYER-ANIM-EVENT` passa a indicar `main=1/0`.
- Removido o auto-reparo do Inpa (`AutoFix`/`RefreshOnLoad`), que nao fez nada.

## v0.22.0 - poise reformulado + deflect continuo
- **Classes 1-4** de ataque e defesa (`[Classes]`): 1 roupa/armas leves, 2 armadura leve/armas medias, 3 pesada, 4 bloqueio ativo, gigantes e golpes carregados (golpe forte sobe uma classe). Dano de poise x `DiffBase^(ataque-defesa)`. Classe 4 do atacante da dano de postura severo (x2). A armadura conta pelo tipo (classe) e pelo valor.
- **Escaloes** (`[Tiers]`): >50% estavel (so stagger de classe superior, postura x0,25); 50-25% staggers leves (postura x0,6); <25% medios (postura x1). Acabou o stagger leve automatico em todos os golpes.
- **Staggerlock** (`[StaggerLock]`): poise a 0 = stagger pesado 3 s (NPC) / 2 s (jogador); cada golpe nesse periodo repete o stagger pesado e a postura leva x3; no fim o poise enche. Regeneracao: 3 s de espera, 10 s para encher.
- **Deflect continuo**: segurando o bloqueio com magicka, toda a magia (tambem continua) e desviada sem dano. Custo 0,6 (arma) / 0,4 (escudo) de magicka por ponto de dano; devolve 70% (arma) / 100% (escudo) a vida, poise e postura de quem lancou. Sem magicka volta ao bloqueio normal. `[Magic] Deflect*`.
- Log do `PLAYER-ANIM-EVENT` mostra o `tid` (thread) para estudar a dupla reacao do parry; o log de golpes mostra `class atacante>defesa`.

## v0.22.1 - stagger so do mod
- **Stagger vanilla bloqueado** (`[Stagger] SuppressVanilla=1`): o gancho dos eventos de animacao descarta os `stagger*`/`recoil*` do proprio jogo em todos os atores (o recuo do parry do Inpa e as animacoes do mod passam). O gancho passa a instalar-se logo no primeiro golpe. O log mostra `vanilla stagger blocked`.
- **Classe de armadura do jogador pelo peso vestido** (corpo, cabeca, maos, pes; `[Classes] WornWeightMid/Heavy` = 8/28). Os NPC continuam pelo valor da armadura (`ArmorHeavy` desceu para 100).
- **Staggerlock com repeticao**: o stagger pesado repete-se de 700 em 700 ms enquanto dura o lock e tenta de novo (150 ms, 3 vezes) se o jogo o recusar.
- **Guarda dos NPC** (`[NpcBlock]`): sem `blockStart` em stagger/lock; um bloqueio ate 250 ms depois do `blockStart` conta como golpe sem bloqueio (poise, postura e stagger). O dano de vida continua reduzido pelo motor.
