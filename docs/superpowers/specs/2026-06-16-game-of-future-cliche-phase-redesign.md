# Game of Future Cliche Phase Redesign

## Purpose

Revise Phase 3 so AI sessions better simulate the fast human-room cliche
phase. In the real game, this phase is lightweight: participants quickly shout
short, obvious, boring, ridiculous, or game-ending futures so the room can
strike them out before serious forecasting begins.

The current skill wording asks for "genuinely obvious assumptions." In testing,
that produced two bad extremes:

- with challenge-heavy prompts, every candidate was rejected;
- with generic prompts, all 36 thoughtful assumptions were accepted.

The desired behavior is neither. The phase should produce a compact list of
short cliche forecasts to avoid, not a nuanced baseline of strategic
constraints.

## Target Behavior

Phase 3 becomes two mini-rounds:

1. **Fast Shout Round**
   Each player adds 1-3 short cliche forecasts. These should be terse and
   obvious, sometimes silly or extreme. They may include lazy defaults,
   overused predictions, and totalizing scenarios that would make the game
   uninteresting.

2. **Light Dissent Pass**
   Each player briefly reviews the candidate list and may challenge only items
   they believe are not actually obvious, boring, common, or game-ending.
   Dissent is optional, short, and one sentence per challenged item.

The facilitator keeps candidates by default, removes only candidates with
significant dissent, merges near-duplicates, and rephrases long or nuanced
items into short cliche form when possible.

## Examples

Good cliche candidates are short and blunt:

- AI does everything.
- Privacy is solved because it is local.
- Nobody trusts it.
- Everything gets regulated away.
- A giant breach kills the market.
- Nothing changes because institutions are slow.
- Assistants replace all junior workers.
- The cloud wins anyway.
- Local hardware is too weak forever.
- Global war makes this irrelevant.
- Humanity stops recreating and dies off.

Poor candidates for the cliche list are careful baseline constraints:

- Workflow integration will matter more than conversational polish.
- Accessibility will not emerge automatically from local inference.
- Procurement will demand explainability and contestability.

Those may be useful truths, but they are not necessarily cliches to forbid
unless rewritten as a tired forecast.

## Prompt Changes

The shout prompt should bias toward brevity and looseness:

```text
Fast cliche shout round. Add 1-3 short cliche forecasts for this topic: obvious
defaults, lazy assumptions, boring futures, ridiculous extremes, or
game-ending scenarios the room should strike out before forecasting. Keep each
item short. Do not write nuanced analysis. Append only to Cliche Contributions.
```

The dissent prompt should bias against over-analysis:

```text
Light dissent pass. Review the candidate cliches. Challenge only items that are
not actually common, obvious, boring, or game-ending. One sentence per
challenge. Do not debate or improve the forecasts.
```

## Adjudication Rules

The facilitator should:

- keep candidates by default;
- remove items only when significant dissent shows they are contested rather
  than common;
- merge duplicates and near-duplicates;
- rephrase long, nuanced items into short cliche form when the intent is clear;
- keep the final list compact enough to guide forecasts without becoming a
  full strategy brief;
- keep baseline constraints out of the cliche list unless they are phrased as
  tired forecasts.

## Artifact Changes

`public-room.md` should distinguish the two mini-rounds:

- `## Cliche Shout Round`
- `## Light Dissent Pass`
- `## Final Cliche List`

The final list should contain only the accepted cliches and brief facilitator
notes for removals or major merges.

## Validation

Future smoke tests should check that:

- the cliche candidates are mostly short;
- the phase includes a dissent pass;
- the final list is not empty solely because every item was challenged;
- the final list is not a 30+ item baseline brief;
- nuanced constraints are either excluded or rewritten into short cliche form.
