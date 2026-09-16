---
name: tz-go
description: The full TZ pipeline in ONE invocation. Asks the human exactly ONE question at the very start - answer the spec questions yourself, or let the agent answer them all (silence = agent answers) - and never blocks again. Either way it prints EVERY question with its recommended answer into the chat as soon as the list is complete, long before the code, so the human can read and overrule while work continues. Takes the user's dictation or rough draft and runs the whole cycle - isolate in a git worktree, read the project's rules and external memory, structure the input into a TZ that OPENS with Job-to-be-Done + measurable success criteria + explicit non-goals, interview ITSELF in batches of 5 questions with a self-qualification check between batches (the agent decides when it knows enough to commit to every decision; hard cap 15, verdict recorded in the TZ), run the full /tz-review 3-critic audit, falsify the spec's core hypothesis with the cheapest possible live-data test BEFORE the first line of code, then implement the final TZ phase by phase without stopping or asking, until every acceptance criterion is done (and /tz-verify confirms it, if available). The bet is explicit - ~80% of self-answered questions are right, and imperfect work delivered NOW beats perfect work blocked on a human. Invoke when the user dictates an idea and wants the whole cycle to run itself - "/tz-go", "do it end to end", "don't ask - just do it", "answer the questions yourself and get to work". Works in whatever language the user writes in (Ukrainian, English, any other).
allowed-tools: Read, Write, Edit, Glob, Grep, Bash
---

# TZ Go — from dictation to an implemented TZ without stopping

## Language

Work in the language the user writes or dictates in. Detect it from the dictation, the
draft, or the first message; if it is mixed or unclear, do not ask — use English.
Everything user-facing follows that language: the TZ document, the questions and their
recommended answers, the review journal, progress lines, the final report, and any commit
messages you write on the user's behalf. Keep verbatim: command names (`/tz-go`), file
names, code, config keys, and the code words — "FINISH", "DONE", and their Ukrainian equivalent are the SAME
code word in any language. The text blocks inside this skill are templates of
MEANING, not strings to paste: render them faithfully in the user's language. Prompts sent
to critic models may stay in English (models handle it best), but every finding you quote
back to the user is translated. Never switch language mid-run because a source file or a
kit template happens to be in another language.

Combines the entire pipeline in one invocation:

```
dictation → [Phase 0: ONE mode question + worktree + project rules]
          → [Phase 1: /tz-draft — JTBD + success criteria + self-interview]
          → [Phase 1.5: ALL questions with recommended answers — ONE block in chat]
          → [Phase 2: /tz-review — 3 independent critics, full protocol]
          → [Phase 2.5: A0 falsification of the core hypothesis on live data]
          → [Phase 3: implementation to completion, without stops or follow-up questions]
          → [Phase 4: /tz-verify (if available) + final report]
```

The smaller skills (`/tz-draft`, `/tz-review`, `/tz-verify`) remain standalone — this skill
orchestrates them rather than replacing them. When a TZ already exists and only an audit
is needed, use `/tz-review`. `/tz-go` is for the default workflow: "I've said my piece —
take it from here; I'll read it later." If you want to answer questions yourself, that is
now mode B within `/tz-go` itself (Phase 0); no separate `/tz-draft` invocation is needed.

## Philosophy: 80% correct answers now > 100% perfect answers later

A human who has to answer 10 questions is a blocked pipeline. The bet behind this skill,
explicitly stated by the user: the agent guesses answers correctly with ~80% probability,
and the value of "it is DOING something in the meantime" exceeds the value of perfect
answers that require waiting. Therefore:

- **Exactly ONE question waits for an answer — the first, about the operating mode**
  (Phase 0). The agent decides everything else. This is a deliberate exception to
  "ask nothing": choosing a mode takes one word, while guessing wrong is costly —
  someone who wanted to answer personally would otherwise receive a finished TZ
  containing someone else's decisions.
- **All questions with recommended answers appear in chat IMMEDIATELY** once
  formulated (Phase 1.5) — not at the end of the work. While the agent moves on, the
  human is already reading and thinking. Hiding them until the final report presents
  decisions to the human only after code has already been built on them.
- Each self-answer is recorded in the TZ with the label **"✅ auto-accepted (tz-go)"** —
  the user can read it later and amend anything wrong. A mistake costs an edit;
  waiting costs the entire pipeline.
- Stopping is allowed in exactly one case — **a hard external blocker**: real money,
  first contact with a real external person, a click in someone else's account,
  a missing secret/token. Such an item does NOT stop the remaining work: the agent
  puts it in the "Needed from the human" queue in the final report, designs v1 so
  that as much work as possible is independent of it, and completes everything else.

## Phase 0 — ONE mode question, then isolation and context

**The skill's very first action is a question. The only one in the entire run.** Ask it
BEFORE any other work, in one short message, and immediately explain the economy rule
(the block below is a template; say it in the user's language, see "Language";
"FINISH" = "DONE"):

```
One question before we start — I won't keep interrupting you.

I'll now unpack your dictation and compile the questions the TZ depends on.
How should we handle them?

  A) I answer all of them — you do nothing, and I work through to completion.
     You'll still see all my answers immediately and can override them.
  B) You answer — I'll show all questions with recommendations and wait.

If you don't reply, I'll take A and get to work.

⚠️ To save tokens: whenever you write to me (edits, answers, clarifications),
collect everything in ONE message. Each separate message requires rereading the
entire conversation history, and ten short replies cost several times more than
one long one. This applies to answers to questions and any later corrections.
```

Mode rules:
- **Mode A (automatic, default).** Questions and answers still appear in chat
  (Phase 1.5), but the agent does not wait — it moves on immediately. Human silence = A.
- **Mode B (human answers).** After displaying the questions, the agent **waits for one**
  message with answers. The human need not answer every question — skipped ones take
  the recommended answer. "FINISH" = accept all recommendations and continue working.
- If the request already says "don't ask", "do it yourself", or "end to end" — do NOT
  ask the mode question at all; that is already an answer of A.

1. **Git worktree.** If the session is not yet isolated, create a separate worktree
   before the first edit (use the harness's built-in tool if available; otherwise
   `git worktree add`). Branch: `feat/{slug}`. Deliver through push + Pull Request
   after checks pass. Unmerged work may be destroyed only if the human explicitly
   says "discard".
2. **Project rules.** Read everything the project treats as its laws BEFORE writing
   the specification: `CLAUDE.md` / `AGENTS.md` (root + affected subdirectories),
   canonical files (`.ai-context/`, `docs/`, `coordination/` — DECISIONS / PRODUCT_MAP /
   BACKLOG / MISTAKES, if they exist).
3. **External memory.** If the project has a memory system (memory files, semantic
   search, summaries of past sessions), query it about the task. The goal is to avoid
   going in circles: does X already exist, was it decided differently, or was it
   deliberately rejected? Put the verdict first in the Phase 1 report ("X already
   exists there" / "X was rejected on this date because…" / "nothing in memory; building").

## Phase 1 — TZ: structure it, ask yourself questions, answer them yourself

Follow the `/tz-draft` protocol (Step 0 "Listen and structure" and Step 4 "Produce the
strengthened TZ" — including the full coverage checklist and the embedded worktree
instruction for the implementer), but **replace the user interview with a self-interview**:

1. **The JTBD gate comes first and is mandatory.** The TZ OPENS with this block:

   ```
   ## Job-to-be-Done
   When [situation], [who] wants to [do what], so that [business outcome].

   ## Success criteria
   1. [measurable criterion — a number or observable outcome]
   2. …

   ## Non-goals: what we are DEFINITELY NOT doing
   1. [explicit exclusion — something tempting to add that we deliberately omit, with a one-line reason]
   2. …
   ```

   No TZ is ready without a clearly stated JTBD, measurable success criteria, and
   explicit non-goals. **Non-goals are the task boundary, not "deferred for now"**:
   a list of the things most likely to creep into scope during implementation,
   which you commit NOT to do (the more detailed "Outside v1 scope" section in the
   TZ body complements this block, but the 2-5 main exclusions belong here beside
   JTBD, where they cannot be missed). Every requirement in the TZ must trace back
   to JTBD; a requirement that serves none of the stated jobs is cut into non-goals
   or "Outside v1 scope". This is not a formality: the Phase 2 critics will check the
   entire document against JTBD, success criteria, and non-goals (category 0 of the
   `/tz-review` checklist).

2. **Self-interview in batches of 5 — with self-qualification between batches.**
   The number of questions is NOT fixed (no "10 because it's a round number") —
   a sufficiency check determines it, and the agent decides when enough is enough:

   - **Batch 1 (5 questions):** gaps with the highest cost of guessing wrong —
     the same questions `/tz-draft` would ask the user. Each uses an answer-first
     format with an immediate self-answer:

     ```
     Question N: {question}
     Why it matters: {what breaks in the business if the answer is wrong}
     Options: a) … b) … c) …
     ✅ My answer: {letter}) — {why this is the best choice: 1-3 sentences grounded
     in the dictation / codebase / project rules}
     ```

   - **Self-qualification after EVERY batch** — honestly answer one question:
     "Can I now make ALL decisions in this TZ with high confidence — or are there
     areas where I would still be guessing blindly?" Name the uncertain areas.
     None remain → the interview is complete. Some remain → another batch of up to
     5 questions targeting EXACTLY those areas (not "five more just in case").
   - **The ceiling is 15 questions (3 batches).** If uncertainties remain after 15,
     the signal is not "keep asking" but that the task contains real business
     decision points: put them in "⚠️ ASSUMPTIONS" and the "Needed from the human"
     queue, and design v1 to depend on them as little as possible.
   - **Record the self-qualification verdict in the TZ** (in the self-interview section):
     "Self-qualification: confidence {high/sufficient}, {N} questions in {K} batches;
     uncertain areas: {none / list → ⚠️}." This is the audit trail for "why the agent
     stopped at this point" — the user must see both the answers and the moment
     the agent judged itself ready.

   The last question of the last batch is always a **pre-mortem**: "One month after
   launch, the feature has failed — what is the most likely reason?" → put the result
   in "Open risks".

3. **Where it goes.** Put the full self-interview block in an **adjacent companion file**
   (`TZ_{slug}_self_interview.md`) or a separate section of the TZ; in the TZ itself,
   give each rule derived from an answer a short reference to the question number.
   After v2/v3 rewrites of the TZ (review iterations), keeping the full block in
   the document body bloats the file — then retain a link to the companion file or
   the v1 git history instead of a copy. The goal stays the same: the user can read
   and override any answer with a single edit.
   Label every rule in the TZ derived from a self-answer "✅ auto-accepted (tz-go)".
   Anything you honestly CANNOT answer even for yourself (a real business decision
   with a high cost of error) goes under "⚠️ ASSUMPTIONS" in "Open risks" and in the
   final report's "Needed from the human" queue. There are typically 0-2 such items;
   ten "⚠️ ASSUMPTIONS" means you are avoiding the bet this skill makes.

4. **Technical decisions** — as always in `/tz-draft`: never ask them, even of
   yourself, as "options for the human"; simply decide and record them in the
   "Default technical decisions" section (the first line is the worktree
   instruction, without exceptions).

5. **Regenerability test (IMMUNE "Intent before implementation", added 01.09.2026).**
   Before treating the TZ as ready, ask yourself about every module it touches:
   "If this file were deleted and rewritten using ONLY the TZ + docs + tests,
   what would break?" The answer "everything" means knowledge lives in the code
   rather than the TZ — add exactly what is missing for regeneration (rules,
   invariants, data formats) to the TZ.

After producing the TZ, do NOT wait for confirmation. Move straight to Phase 2.

## Phase 1.5 — ALL questions and answers in chat, in one block

As soon as the self-interview is complete (self-qualification says "enough"), **show
the entire list in chat immediately**, before the audit and before the first line
of code. Not at the end: changing decisions then is too late, because code has
already been built on them.

Use a compact format so 10-15 questions can be read in a minute:

```
📋 Questions this TZ depends on ({N} total) — my answers are already accepted

1. {question} → ✅ {chosen answer}
   why: {one sentence}
2. …

⚠️ I could not decide for you ({M} total) — marked as ASSUMPTIONS in the TZ:
• {question} — {why this is a real decision point rather than a guess}

Next: [mode A] I'll proceed to audit and implementation without waiting.
      [mode B] I'll wait for your answers in ONE message.

To change anything, copy its number and write your alternative. Collect all edits
in ONE message: each separate message costs a reread of the entire conversation.
```

Display rules:
- **Everything in one message**, not one question at a time. Splitting it up costs
  exactly the same as the behavior we ask the human to avoid.
- **Always show the recommended answer**, in both modes A and B. In B it is not
  a "hint" but the default: a skipped question takes it automatically.
- More than 15 questions signals real business decision points in the task;
  do not expand the list — move the excess to ASSUMPTIONS.
- In mode A, **do not pause** after displaying the list — the next report line is
  already about Phase 2. The human reads in parallel; if they send an amendment
  later, incorporate it into the TZ through the same mechanism as any other edit.

## Phase 2 — Full /tz-review audit

Run the `/tz-review` protocol on the newly created TZ in full: 3 independent critics
from different vendors, the checklist from **category 0 (Job-to-be-Done and success
criteria)** through 11, 3 iterations, grounding, quotation and confidence filters,
and synthesis by the orchestrator.

**Run the critics through the kit's dispatcher** (`lib/llm-critic.sh` +
`providers.json`), not manual CLI calls. If you do call a CLI directly, here are
pitfalls collected during the first real run (each cost real time):

- **Prompts ONLY through stdin from a file.** Passing a large TZ (tens of KB) as
  argv crashes `claude -p` with "Argument list too long" and silently corrupts non-ASCII.
- **gemini** in headless mode requires workspace trust
  (`GEMINI_CLI_TRUST_WORKSPACE=true` or `--skip-trust`, depending on the version);
  on a 429 no-capacity response from the top model, do not retry the same model —
  switch to `-m *-flash`.
- **Background runs require absolute paths.** A relative `cd` in a background
  shell = silent failure of all three critics with empty response files.

**Degraded review — say so clearly (added 01.09.2026).** Before running the critics,
run `llm-critic.sh --smoke-all`. Three live slots from different vendors → normal operation.
Two live slots from different vendors → continue, but every verdict and the final report
must carry the banner "⚠️ DEGRADED REVIEW: 2 of 3 critics ran (identify the failed one)".
Fewer than two, or surviving critics from the same vendor → STOP until `providers.json`
is fixed: one model checking itself is an echo, not a review, and silently continuing
here is worse than having no review.

**Two deviations from the standard `/tz-review`:**

1. **Autonomous decisions**: whenever the protocol says "flag for user" / "surface to
   user", the orchestrator decides itself under the same synthesis rules (accept
   security criticism by default; accept or reject architectural alternatives
   that change scope WITH WRITTEN justification in RECONCILIATION.md and the TZ
   changelog). The user reads this after the fact, so every such decision must be
   findable within 10 seconds: include a "Decisions I made for you" section with
   links in the final report.
2. **Iteration 3 uses verification mode.** Iter1-2 use the full checklist as in the
   protocol. In Iter3, critics cover THE SAME 12 categories (do not narrow anything —
   the `/tz-review` anti-pattern still applies), but report ONLY blockers: "a CLEAR
   verdict or a numbered list of BLOCKERs". Validated in a real run on 2026-08-11:
   this third-iteration format caught 4 real blockers missed by two full passes —
   signal density rises when there is no obligation to fill every category with text.

**Reporting:** one progress line after each iteration ("iter 2/3: 4 findings
accepted, 1 rejected, TZ v3") + a fuller report at the boundary of EVERY skill phase
(0→1→2→2.5→3→4) — during 3+ hours of autonomous work, the human must see where the pipeline is.

## Phase 2.5 — A0 falsification of the core hypothesis (before the first line of code)

After the final TZ version and BEFORE implementation, run **the cheapest manual test
of the TZ's core hypothesis on live data**. State: "This TZ has value only if {key
rule/mechanism} produces {expected result} on real data" — and check it manually in
15-30 minutes: SQL against a live database, applying the rule to 5-10 real cases,
or manually simulating the main scenario. No code, no mocks.

- Hypothesis confirmed → one line in the TZ ("A0: confirmed on {data}") and move on.
- Hypothesis falsified or unexpected result → this is NOT a failure; it is the
  pipeline's cheapest finding: correct the design in the TZ (changelog!), run a
  focused fourth critic pass on the changed section if needed, and only then implement.

Origin: in the first real run (2026-08-11), this exact kind of test caught a design
flaw (the intersection rule excluded the most valuable case) in 30 minutes, before
the first line of code. Three critics across three iterations missed it: they read
the TZ, not the data. Mock tests fundamentally cannot catch this class of error —
the store returns whatever you tell it to return.

## Phase 3 — Implementation to completion

Immediately after A0, implement the final TZ version. Do not ask "shall I start?" —
that is the assignment.

- Work phase by phase in TZ order; each phase ends with something working; commit
  frequently and push the branch regularly.
- **Delegate self-contained modules to a separate process/account if the environment
  supports it.** If the system has a built-in offload mechanism (e.g. a global
  `/offload` skill for a second account or a separate headless CLI process), delegate
  implementation of modules that can be described in a self-contained prompt
  (code generation + tests, bulk transformations); the orchestrator session reads
  the result, applies the gates, and merges. If no such mechanism exists, do it
  yourself — that is not a blocker.
- **A new question during the work** (and there will be some) → the same rule as
  Phase 1: ask yourself, answer in the answer-first format, record it in the TZ
  changelog, and keep working. NEVER stop to ask the user unless it is a hard
  external blocker (money / external person / someone else's account / missing secret).
- **Loop semantics:** after each phase, check against the TZ (which AC are complete,
  which are not) and proceed immediately to the next. Stop only in two states:
  (a) all AC are complete, (b) only items in the "Needed from the human" queue remain.
  "I've done 4/6 and will ask" is forbidden — it reads as "everything is ready"
  and loses work.
- Passing project checks (lint / typecheck / build / tests — whatever the project
  treats as its gate) are required before a PR. Never hand over failing checks.
- **Projection check before the PR (IMMUNE "Mutations preserve coherence", added 01.09.2026).**
  A diff changes concepts, not just files, and a concept has several projections:
  code, data schema, API, tests, docs/the TZ itself, configs/crontab. List the concepts
  touched by the diff and review their projections: update an inconsistent one in
  the same PR or explicitly put it in the backlog in the same commit. A change is
  complete only when all projections tell the same truth.
- **Unexpected states — fail loudly, do not guess (IMMUNE "Unexpected states fail loud").**
  Do not write code that silently substitutes a "convenient" value for unknown
  input or swallows an error in an empty try/catch. An unknown is an error with
  a message, not a default zero.

## Phase 4 — Verify completion and produce the final report

1. If `/tz-verify` is available in the kit, run it on the completed work. `FIX-FIRST` →
   fix and verify again (up to 2 cycles); `BLOCK` → fix or honestly report exactly
   what remains unfinished and why.
2. **Final report** (one message, for a human who stepped away and returned):
   - JTBD in one line and the status of success criteria (how many can already be verified).
   - What was done: phases, PR link, tz-verify verdict.
   - **"Decisions I made for you"**: N self-answers from Phase 1 (where to read them),
     M synthesis decisions from Phase 2 (where to read them). Put the top 3 riskiest
     ones directly in the report.
   - **"Needed from the human"**: the external blocker queue, each item a ready-to-execute
     action (exact URL, exact amount, exact button), with no placeholders.
   - **"Live evidence"** (IMMUNE "Every state is explainable", added 01.09.2026): for
     every success criterion, state the proof rather than "done": a real request
     and response code, an actual database figure, a screenshot, command output.
     Passing mock tests do not prove that it works with data. Without live evidence,
     write "not proven", not "done".
   - A "⚠️ DEGRADED REVIEW" banner if fewer than three critics ran in Phase 2.
   - ⚠️ ASSUMPTIONS, if any.

## When NOT to invoke

- A bug fix or trivial change → just do it; the pipeline wastes effort.
- The user wants to answer questions personally → `/tz-go` already supports this
  (mode B in Phase 0); a separate `/tz-draft` invocation is no longer needed.
- A TZ is already written and only an audit is needed → `/tz-review`.
- The work is already done and needs verification → `/tz-verify`.

## Anti-patterns

- **Ask the user ANY question except the initial mode question and wait** —
  the main violation. Exactly one stop is allowed: the mode question in Phase 0
  (and waiting for answers in mode B). Everything else is either answered by the
  agent or put in the "Needed from the human" queue WITHOUT stopping the remaining work.
- **Show questions only in the final report.** The list goes into chat in Phase 1.5,
  before audit and code. Changing decisions at the end is too late — implementation
  already rests on them.
- **Present questions one by one.** The entire block belongs in one message;
  splitting it costs exactly as much as the behavior we ask the human to avoid.
- A TZ without JTBD, measurable success criteria, and explicit non-goals at the very start.
- **A fixed number of questions for a round number's sake** — self-qualification
  determines the count (uncertain areas → another batch; clear → stop), not a quota.
- A self-interview without a recorded self-qualification verdict — "stopped because
  I stopped" cannot be audited.
- Another batch of questions "just in case", without named uncertainties it targets.
- Self-answers not recorded in the document — "guessed and forgot" prevents the user
  from overriding a wrong answer.
- A dozen "⚠️ ASSUMPTIONS" instead of answers — avoiding the skill's bet.
- A pause between phases ("TZ ready, start review?", "review passed, start coding?") —
  the phases are tightly connected.
- The first line of code without A0 falsification — critics read the TZ, not the data;
  only a live test catches a flaw in the core hypothesis.
- Silently applying a review finding that changes scope without recording the reason.
- Departing from the TZ during implementation without a changelog entry.
- Stopping at "most of it is done" — finish only with all AC complete or a queue
  containing only blockers.
- A final report without a "Decisions I made for you" section.
