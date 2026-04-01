## Snapshot Diagnostics Runbook

Purpose: make HuntScanner snapshot failures diagnosable even when they are intermittent or hard to reproduce.

### 1) One-time setup before testing

1. Enable addon debug in Preydator settings.
2. Keep BugSack/BugGrabber enabled if installed.
3. Confirm Hunt module is enabled.
4. Keep one active prey hunt available for field tests.

### 2) Fast reproduction matrix

Run each case for 2-3 minutes while engaging combat and hovering world-map POIs when applicable.

1. Open world, active prey, no instance.
2. Delve in same prey zone (bountiful).
3. Delve in same prey zone (non-bountiful).
4. Delve in different zone than active prey.
5. Scenario or party instance with no hunt table interaction.

Expected: no repeated chat spam containing "Preydator HuntScanner: snapshot error".

### 3) If error appears (capture-on-incident flow)

Do this immediately after the first spam/error line:

1. Run `/pd huntdebug`.
2. Run `/pd huntdebug bs`.
3. If needed, run `/pd huntdebugcopy` and paste payload into issue notes.
4. Record:
- zone name
- map id if known
- instance type
- prey difficulty
- whether mission/hunt table UI was open in last 60 seconds
- whether this is first error since login or after zone transition

### 4) Incident report template

Use this exact template in issue comments:

- Build: `x.y.z`
- Character/level: `...`
- Active prey quest id (if known): `...`
- Zone: `...`
- Instance type: `...`
- Repro case id (from matrix): `1-5`
- Trigger action: `combat / mouseover / zone transition / UI open-close`
- First error timestamp: `...`
- Repeats per minute: `...`
- `/pd huntdebug bs` sent: `yes/no`
- `/pd huntdebugcopy` payload attached: `yes/no`
- BugSack stack attached: `yes/no`

### 5) Triage buckets (for quick root-cause routing)

1. Event gate leak:
- Errors start in restricted instances and continue on combat/event churn.

2. Payload coercion leak:
- Error text references string or number conversion on protected/secret values.

3. UI-widget taint propagation:
- Stack touches Blizzard widget/layout files (TextWithState, LayoutFrame, AreaPoiUtil).

4. Reward tooltip/money taint:
- Stack touches MoneyFrame/Quest reward tooltip flow.

### 6) Pass/fail release gate

Mark release candidate as pass only if all are true:

1. Zero repeated snapshot chat spam across matrix cases 2-4.
2. No TextWithState/LayoutFrame taint stacks during map mouseover in active prey sessions.
3. No MoneyFrame taint stack during quest reward tooltip hover.
4. At least one `/pd huntdebug bs` payload reviewed from a clean run and one from a stress run.

### 7) Optional stress loop (if tester has time)

1. Enter/exit delve 3 times with active prey.
2. Engage combat after each load screen.
3. Open/close map and hover 3-5 POIs.
4. Run `/pd huntdebug` after each loop.

If still clean after this loop, confidence is high for this build.
