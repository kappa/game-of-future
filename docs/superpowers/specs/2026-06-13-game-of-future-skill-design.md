# Game of Future Skill Design

## Purpose

Create a Codex skill named `game-of-future` that autonomously simulates the
Game of the Future facilitation format with multiple independent AI players.
The skill should produce surprising product concepts grounded in plausible,
strategically useful forecasts.

The simulation uses a separate AI facilitator and separate persistent player
sessions. Players may run as Codex subagents or through external AI commands
such as Claude or Gemini, provided those backends satisfy the persistence and
file-access requirements.

The first version is prompt- and context-driven. It must not introduce a
custom orchestration program, structured wire format, or helper script unless
future experience demonstrates that one is necessary.

## Invocation And Defaults

The user starts a game by supplying:

- a topic.

The user may also supply:

- roster constraints;
- a control mode;
- a research policy.

The topic is required and is used as supplied. The facilitator does not
interview the user to refine it or choose a different topic.

Defaults:

- 12 players;
- four teams of three;
- autonomous control mode;
- a shared factual briefing;
- no independent player research unless enabled;
- two votes per player for projects created by other teams.

The user may override team count, team size, roster composition, provider mix,
research policy, and control mode at the start of a game.

Control modes:

- **Autonomous:** run to completion and pause only for a failure or genuine
  ambiguity that the facilitator cannot resolve without changing user intent.
- **Development:** pause after every phase so the user can inspect artifacts,
  adjust prompts or registries, and approve continuation.

## Architecture

The solution is one modular Codex skill with no custom runtime program.

### Facilitator

The active Codex agent is the facilitator. It:

- interprets the user's game parameters;
- resolves registries;
- selects and binds the roster;
- starts and resumes persistent player sessions;
- forms teams and makes random selections;
- advances phases;
- moderates public rounds;
- coordinates access to shared files;
- pauses according to the selected control mode;
- records decisions and errors;
- computes votes and writes the final analysis.

The facilitator owns both mechanics and moderation. Random choices and phase
state are recorded in the session artifacts so they remain inspectable.

### Players

Each player is a distinct persistent AI session with:

- a reusable personality profile;
- a provider binding selected for this game;
- private conversation history;
- access to public session artifacts;
- instructions to access only its assigned team's shared room;
- an obligation to respond in character without sacrificing the game's
  forecasting and product-design goals.

Personality and backend are separate concepts. A profile such as a skeptical
economist can be bound to Codex, Claude, Gemini, or another supported provider.

Persistent private history is required. Reconstructing a player by replaying
context is an exceptional, user-approved fallback, not a normal adapter
strategy. A provider may be considered unsupported if it cannot maintain
coherent persistent sessions.

### Team Rooms

Each team receives one shared Markdown file. All team members may read and
append to it. The room contains:

- members and profile summaries;
- assigned forecasts;
- discussion contributions;
- decisions and rejected alternatives;
- the selected forecast pair;
- the product concept;
- the final pitch.

The facilitator gives teammates turns to read and update the room, preventing
simultaneous edits and lost changes. Players retain their private session
histories while using the file as shared team memory.

### Skill Contents

The skill should contain:

- `SKILL.md` for the concise facilitator workflow and resource routing;
- `references/rules.md` for the canonical game protocol;
- `references/registries.md` for profiles, providers, bindings, precedence,
  and compatibility requirements;
- `references/facilitation.md` for prompts, moderation, research, control
  modes, and failure handling;
- `assets/session-template/` for the plain-text session artifact templates;
- `agents/openai.yaml` for Codex UI metadata.

Detailed rules and templates should remain outside `SKILL.md` so the core
workflow stays concise.

## Registries

The skill ships with global defaults in its `references/` directory. A project
may add local entries or override matching global entries under:

`game-of-future/registry/`

The project registry may contain:

- `players.md`;
- `providers.md`;
- `bindings.md`;
- `rosters.md`.

Registry precedence is:

1. project-local override;
2. project-local addition;
3. skill-provided global default.

Registries are human-readable Markdown, not encoded data. They cover:

- player profiles;
- provider capabilities and invocation guidance;
- preferred profile-to-provider bindings;
- reusable roster constraints.

A player profile describes perspective, expertise, temperament, biases,
communication style, and productive tensions. It does not specify a provider.

A provider entry describes how the facilitator starts and resumes a persistent
plain-text session, the working-directory and file-access assumptions, and
known limitations. Credentials, tokens, and other secrets must never appear
in registry or session files.

The facilitator prefers curated profiles. If roster constraints cannot be met,
it may generate temporary profiles to fill diversity gaps. Temporary profiles
are copied into the session roster and are not promoted into global or local
registries automatically.

## Provider Support Contract

A provider is supported only when the facilitator can:

- start a distinct player session;
- resume that same session throughout the game;
- send plain-text prompts and receive plain-text responses;
- let the player read the relevant public and team files;
- preserve player identity and private conversational history;
- distinguish operational failure from a valid player response.

Native Codex subagents and external commands are peers behind this conceptual
contract. The skill does not require JSON, a custom protocol, or a wrapper
program. Provider-specific invocation instructions live in the registry.

If an external engine cannot satisfy persistence and file access cleanly, the
skill may drop support for that engine instead of adding context-reconstruction
complexity.

## Session Artifacts

Each run creates a project-local directory:

`game-of-future/sessions/<timestamp>-<topic-slug>/`

It contains:

- `session.md`: topic, parameters, current phase, phase history, random choices,
  and facilitator ledger;
- `roster.md`: selected profiles, provider bindings, teams, and non-secret
  persistent session handles;
- `briefing.md`: shared factual briefing, sources, and research policy;
- `public-room.md`: announcements, sequential cliché round, challenges,
  presentations, and public outcomes;
- `forecasts/<player>.md`: one private game artifact per player's forecast;
- `teams/<team>.md`: the team's shared room and final pitch;
- `votes/<player>.md`: the player's private ballot and optional rationale;
- `report.md`: vote totals, winning concepts, non-binding facilitator analysis,
  and recommended follow-up work;
- `errors.md`: failures, retries, pauses, user decisions, and resumptions.

The complete directory remains after every game, regardless of control mode.

Persistent model histories remain private to their provider sessions. Session
files expose only game-relevant outputs. Team rooms are shared only with their
members and the facilitator. The public room and final report are visible to
all participants.

File privacy is a game-level visibility rule enforced by the facilitator's
prompts and path disclosure. When a provider supports stronger filesystem
isolation, the facilitator should use it. The skill does not claim OS-level
secrecy when all agents run with access to the same project tree.

## Research Policy

The default is a shared factual briefing prepared by the facilitator before
the cliché and forecast phases. It gives every player a common baseline and
records sources.

The user may enable independent player research. Providers may use it only
when their tools support it. Each researched contribution must record its
sources and distinguish sourced facts from inference. Unequal provider tool
access must remain visible in the artifacts.

The facilitator should keep the briefing compact enough that it informs
players without pre-solving the game or collapsing personality diversity.

## Game Flow

### 1. Setup

The facilitator:

- validates the supplied topic and parameters;
- creates the session directory from templates;
- resolves global and project registries;
- selects a diverse roster satisfying user constraints;
- binds profiles to supported providers;
- starts one persistent private session per player;
- records the roster and session handles;
- creates the shared briefing.

The facilitator selects profiles for useful differences in expertise,
worldview, risk tolerance, incentives, and creative style. Vendor diversity is
desirable when requested, but personality diversity is the primary roster
criterion.

### 2. Cliché Round

Players participate sequentially in a public room. Each player sees the current
list and may:

- add one or more obvious assumptions;
- challenge an existing item as not actually obvious;
- support another player's challenge.

The facilitator adjudicates disputed items based on the room's reactions and
records removals. The final list defines what forecasts must move beyond.

### 3. Individual Forecasts

Each player privately writes one forecast answering:

- What will happen?
- Why will it happen?
- When will it happen?

A valid forecast must:

- stay within the supplied topic;
- avoid the accepted cliché list;
- be concrete and understandable;
- be plausible rather than arbitrary science fiction;
- ground its cause in a fact, established trend, or highly reliable assumption;
- normally use a three-to-five-year horizon, with a reason when another
  horizon is more appropriate.

The facilitator may request revision when a forecast fails these criteria.

### 4. Team Formation And Forecast Assignment

The facilitator creates four teams of three by default. Teams should combine
players who are not too similar in perspective or provider.

Each team receives three randomly selected forecasts. A team may discard one
and must design from the intersection of the remaining two. The facilitator
records the random assignment before team work begins.

### 5. Product Design

Players collaborate through their team's shared Markdown room. The facilitator
coordinates turns until the team produces:

- name;
- core idea;
- target audience;
- underlying need;
- unique value;
- where and how it is used;
- what prevents it from existing now;
- first implementation step;
- why the team considers it important.

The product must genuinely depend on both selected forecasts. It should not be
a pre-existing idea with the forecasts attached afterward.

### 6. Presentations

Each team publishes a concise pitch in the public room. Other players may ask
a small number of clarifying questions. The facilitator prevents extended
debate and keeps attention on the product's logic and future niche.

### 7. Voting

Every player privately selects two projects created by other teams. Players
vote in character and may include a short rationale. A ballot containing the
player's own team is invalid and must be corrected.

Player votes determine the official result. The facilitator reports totals and
then adds separate, non-binding commentary on:

- originality;
- forecast plausibility;
- strategic usefulness;
- strength of forecast intersection;
- promising ideas that voting may have undervalued.

### 8. Final Report

The facilitator writes `report.md`, confirms all expected artifacts exist, and
marks the session complete. The report should preserve uncertainty and treat
the products as hypotheses for further research rather than validated strategy.

## Control And Pause Behavior

In development mode, the facilitator pauses after setup and after every game
phase. It summarizes what changed and points the user to the relevant files.

In autonomous mode, the facilitator proceeds without approval between phases.
It pauses only when:

- a player session cannot be resumed;
- a required file cannot be read or updated;
- a provider violates identity or persistence assumptions;
- roster constraints cannot be satisfied;
- user intent is genuinely ambiguous in a way that changes the game;
- continuing would require silently replacing, removing, or reconstructing a
  player.

The facilitator may make ordinary moderation judgments without pausing.

## Failure Handling

When a persistent player session fails:

1. Preserve all current artifacts.
2. Record the failure in `errors.md`.
3. Stop advancing the affected team and any dependent phase.
4. Pause and ask the user how to proceed.

The facilitator must not silently:

- substitute another backend;
- recreate the player's context;
- remove the player;
- shrink the team;
- fabricate the missing contribution.

Context reconstruction is permitted only after the user explicitly approves it
for that incident.

## Quality Goals

The primary quality goals are:

1. diverse and surprising product concepts;
2. plausible, concrete, strategically useful forecasts.

Distinct personalities are instrumental: they should create productive
differences that improve forecasts and products. Personality performance must
not become theatrical noise that weakens the primary goals.

The facilitator should check:

- whether clichés were actually obvious;
- whether forecasts are specific, causal, and plausible;
- whether forecast combinations create a meaningful future niche;
- whether products rely on both chosen forecasts;
- whether concepts differ materially across teams;
- whether voting rules were followed.

## Out Of Scope

The first version excludes:

- the optional gesture or sign-language translation phase;
- a custom orchestration program;
- JSON or another structured agent wire format;
- automatic promotion of generated profiles;
- silent player substitution or context reconstruction;
- precise forecasting claims or final strategic decisions;
- automatic topic selection or topic-refinement interviews.

## Verification

Initial verification uses development mode and phase gates.

Verify:

- registry precedence and override behavior;
- roster constraint satisfaction and perspective diversity;
- persistent private history for every player;
- readable and writable team rooms for all assigned members;
- sequential public cliché interaction and challenges;
- forecast quality against the stated criteria;
- random assignment of three forecasts per team;
- genuine use of two forecasts in each product;
- complete structured pitches;
- private ballots with no own-team votes;
- correct vote totals and separate facilitator commentary;
- complete retained session artifacts;
- pause-with-state-preserved behavior on a simulated provider failure.

After the skill passes direct verification, forward-test it with isolated agents
on realistic topics. Forward tests should exercise at least:

- a Codex-only roster;
- a mixed-provider roster when compatible external commands are available;
- development mode;
- autonomous mode;
- a provider failure during team work.

The skill is successful when another Codex instance can follow it without
hidden knowledge, complete a coherent game, preserve all artifacts, and pause
safely when persistence assumptions fail.
