# NAH-I-D-WIN (NahIDWin)

Sekiro-style **Poise + Posture + Stamina** combat for Skyrim **Legendary Edition** (1.9.32.0, SKSE 1.7.3).
An SKSE plugin does the calculations; a small Papyrus bridge and a SkyUI menu handle what needs scripts.
Designed to run on top of Inpa Sekiro Combat LE (parry, block, execution, difficulty); the Inpa files are not part of this repository.

Config: `Data/SKSE/Plugins/NahIDWin.ini`. Log: `Documents/My Games/Skyrim/SKSE/NahIDWin.log`.
Optional: TrueHUD LE for the poise bar.

## Combat model

**Classes.** Every attacker and defender has a class from 1 to 4.
- Attack: 1 light weapon, 2 medium, 3 heavy, 4 power attack / shield bash / giant.
- Defense: player by total weight of worn body, head, hands and feet pieces (under 8 = 1, under 28 = 2, above = 3); NPCs by armor rating (40 / 100 limits).
- Poise damage is multiplied by `1.5 ^ (attack class - defense class)`. A normal hit one class above counts as the same class.

**Poise** (fast bar). Poise is lost per hit. Tiers by the fraction left before the hit:
- above 50%: stable, no stagger from normal hits of the same or one class above;
- 50% to 25%: light stagger;
- below 25%: medium stagger.
Max poise grows with mass and armor class.

**Staggerlock.** Poise reaching 0 locks the victim in stagger (3.5 s NPC, 1.75 s player by default). Posture damage is multiplied meanwhile and poise refills at the end. The game's own hit reactions are suppressed, so only the mod decides staggers.

**Posture** (slow bar). Hits fill it, it empties on its own. Full posture = BleedOut (kneeling, defenseless; execution window). Blocked hits add little posture and never stagger.

**Parry.** A window opens when block is pressed. A parry blocks all damage, adds posture to the attacker and staggers it, and returns posture, poise and stamina to the defender.

**Magic deflect.** After parrying a spell, holding block returns the spell. It costs magicka per point of damage and returns part of the damage as health, poise and posture damage to the caster.

**NPC guard.** NPCs cannot block while stagger-locked, bleeding out, staggered or attacking, and raise their guard with a delay after a stagger or an attack.

**Rage / Supreme Rage.** Rage (G) trades health for damage reduction, damage bonus and stagger immunity. NPCs use it when posture is high and poise low. Supreme Rage (H) adds a fire aura with a long cooldown.

**Bosses, giants, perilous attacks.** High-level unique NPCs get two lives and more poise/posture; giants and dragons get more poise/posture. Boss and giant attacks may be perilous: they ignore blocking and must be dodged or parried.

**Extra lives.** The player gains extra lives at levels 30 and 60.

## Stamina

Stamina is linked to poise and posture.

- **Swing cost** (paid when the weapon swings, hit or miss): `(base + weapon weight x per-weight) x weapon type multiplier`. Power attacks multiply the cost; a shield bash uses the shield weight. The game's own attack and block costs are zeroed. NPCs pay the same.
- **Block cost:** `damage x factor x 1.5^(attack class - armor class)`, shield x0.6. Stamina at 0 while blocking = guard break: poise 0, staggerlock, posture +%.
- **Low stamina zone** (below 25%): slower regen and more poise damage taken.
- **Poise-linked regen:** poise below 50% / 25% slows stamina regen; during staggerlock there is none.
- **Armor class** slows regen per class above 1.
- **Exhaustion:** stamina 0 from swinging = no stamina regen and reduced movement speed for at least the minimum time; it ends when stamina reaches the target % or at the maximum time.
- **Parry** returns a fraction of max stamina (the Inpa parry script applies it; the plugin caps the total).

Presets (Hard = strictest):

| Setting | Easy | Normal | Hard |
|---|---|---|---|
| Swing base + per weight | 4 + 0.6 | 5 + 0.75 | 6 + 0.9 |
| Power attack cost | x1.8 | x2.0 | x2.2 |
| Shield bash cost | x1.2 | x1.35 | x1.5 |
| Block cost factor | 0.20 | 0.28 | 0.35 |
| Guard break posture | +15% | +20% | +25% |
| Exhaustion min / max / target | 1.5 s / 6 s / 30% | 2 s / 7 s / 35% | 2 s / 8 s / 40% |
| Regen during exhaustion | x0.8 | x0.7 | x0.6 |
| Parry returns stamina | 50% | 30% | 15% |
| Armor class regen penalty | -5% | -8% | -10% |
| Low zone regen / poise damage | x0.8 / x1.1 | x0.7 / x1.2 | x0.6 / x1.25 |
| Regen at poise < 50% / < 25% | x0.85 / x0.7 | x0.8 / x0.6 | x0.75 / x0.5 |

## Menu (SkyUI)

Five tabs: **General & System**, **Stamina**, **Poise & Posture**, **Stagger & Behaviors**, **Special & HUD**.
- Each tab (except General) has a mode: **Preset** (Easy / Normal / Hard) or **Manual**. In Preset mode the individual rows are hidden; in Manual mode the preset selector is greyed and every value can be edited.
- Manual values are stored separately, so switching to a preset does not lose them.
- The **master preset** in General & System sets all tabs to one preset.
- Changes are applied when the menu closes. In Special & HUD, presets only cover the Special part (rage, supreme, bosses, perilous); the HUD is always manual.
- General & System also holds the Inpa options (parry timer, magic reflect, melee resist, execution, difficulty, resistances), extra lives and the on/off switch for the whole mod.

## Troubleshooting

- Movement speed stuck low: set `[Exhaustion] RepairSpeedOnLoad=1`, load a save; the speed is reset once and the key returns to 0. Console alternative: `player.getav speedmult`, then `player.modav speedmult <missing amount>`.

## License

GPL-3.0 (see `nahidwin/LICENSE`). Build base and addresses from SoftTarget LE. Stagger spell records follow "SGC Stagger on hit". References: doodlum "Poise" (SE), TrueHUD LE API (Mhacks79, based on Ersh's TrueHUD).
