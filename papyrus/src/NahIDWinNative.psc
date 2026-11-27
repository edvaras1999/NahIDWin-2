Scriptname NahIDWinNative Native Hidden
{ Funcoes nativas implementadas pela NahIDWin.dll. Servem so para falar com o plugin (diagnostico e configuracao). }

; Chamada uma vez quando o script ponte arranca, para o log mostrar que o Papyrus esta vivo.
Function ScriptReady() global native

; Chamada depois de cada evento tratado. "packed" e o numero recebido no evento.
Function Ack(int packed) global native

; Duracao do BleedOut em segundos (vem do .ini).
float Function GetBleedSeconds() global native

; Chamada quando o BleedOut acabou (so para o log).
Function BleedDone(int packed) global native

; Custo de estamina de um golpe do jogador (0 = desligado ou ja pago). mode: 0 balanco, 1 golpe forte, 2 escudo.
; rightType: codigo de GetEquippedItemType. A DLL junta o tipo de arma e a armadura. Forca do empurrao (0 = desligado).
float Function GetSwingCost(int mode, int rightType, float weight) global native
; Exaustao dinamica: tempo maximo (s) e estamina alvo (% do maximo) para sair dela
float Function GetExhaustMax() global native
float Function GetExhaustTarget() global native
Function ExhaustEnded() global native
float Function ExhaustSwingAgo() global native
Function SelfPoise(bool heavy) global native
float Function GetKnockbackForce() global native

; Armadura abranda a regeneracao de estamina: percentagem (100 = normal). Devolve -1 se estiver desligado (nao mexer).
float Function GetRegenPercent() global native
; Regeneracao com combate (exausto 0, a bater 0, a bloquear mais lenta, em combate mais rapida). -1 = nao mexer.
float Function GetCombatRegen(bool inCombat) global native
; v0.28.0: estado real do mod (interruptor unico, o mesmo do menu). Falso = o mod nao mexe em nada.
bool Function ModActive() global native
; v0.29.0: o Papyrus so avisa que o jogador deu um golpe (0 direita, 1 esquerda, 2 bash); a DLL le a arma, cobra a estamina e decide a exaustao
Function SwingEvent(int kind) global native
; Tipo do item da mao esquerda do jogador (10 = escudo): o deflect de magia gasta menos magicka e devolve mais com escudo.
Function SetLeftType(int t) global native
; Peso das pecas de armadura vestidas pelo jogador (define a classe de defesa 1-3).
Function SetWornWeight(float w) global native
Function SetWornScore(float sc) global native

; Exaustao (estamina a zero): duracao em segundos e pedido de entrada (false = em recarga).
float Function GetExhaustSeconds() global native
bool Function TryExhaust() global native

; Escreve uma linha no NahIDWin.log (diagnostico) e le o idioma do menu (0 English, 1 Portugues).
Function Log(string msg) global native
int Function GetLanguage() global native

; Ler e escrever o NahIDWin.ini (usado pelo menu MCM).
float Function IniGetF(string section, string key, float defaultValue) global native
Function IniSetF(string section, string key, float value) global native

; Guarda o inicio de um golpe forte (a DLL evita cobrar duas vezes). Compatibilidade com versoes antigas.
Function PowerStart() global native

; Vidas extra do jogador: quantas ja foram gastas desde o ultimo sono (o Bridge guarda no save e repoe a DLL ao carregar).
Function SetLivesUsed(int n) global native

; Os eventos de animacao enviados nos proximos ms pelo Papyrus nao sao filtrados pelo escudo de stagger.
Function OwnAnim(int ms) global native

; O grafo de animacao aceitou o ultimo BleedoutStart deste ator (formID)?
bool Function BleedAccepted(int formId) global native

; Vida extra pelo metodo essencial (SkyTweak): 1 = o jogo faz o bleedout; LifeRecover baixa a vida cheia para HealthPercent.
int Function LifeMethod() global native
Function LifeRecover() global native
Function SyncEssential() global native

; Boss: repoe a vida (HealthPercent do ini). Atacantes recentes do jogador (formID, 0 = nenhum): voltam a lutar ao reviver.
Function BossRecover(Actor b) global native
int Function RecentAttacker(int idx) global native

; Evento de animacao opcional ao ativar o Supremo Rage ([Supreme] ActivationAnim; vazio = nenhum).
string Function GetSupremeAnim() global native

; v0.29.3: modelo de stagger do Maxsu. Magnitude (0.26, 0.51, 0.76 ou 1.0) e direccao (0 frente, 0.5 costas) do evento "packed". -1 = sem modelo.
float Function StaggerMag(int packed) global native
float Function StaggerDir(int packed) global native
