---
name: tz-draft
description: Turn the user's free-flow spoken monologue (10-15 min of dictated thoughts) or rough TZ draft into a complete, structured TZ — WITHOUT interrogating them. The skill structures what was said first, then sends ONE message containing the Job-to-be-Done readback plus ALL its questions as a single batch (typically 0-3, hard cap 7) — each question arriving WITH the recommended answer and why it's right. The user answers everything in one reply ("1a, 2 yes, 3 my own answer…"); skipped questions automatically take the recommendation. "FINISH" at any moment accepts all recommended answers and produces the strengthened TZ immediately. Batching is deliberate token economy: every extra Q-A round forces a re-read of the whole chat history. Technical choices are never asked; the TZ always embeds the instruction for the implementing agent to work in an isolated git worktree. Invoke when the user dictates an idea, brings a draft TZ, or says "help me create a TZ" / "run through the TZ". Works in whatever language the user writes in (Ukrainian, English, any other).
allowed-tools: Read, Write, Edit, Glob, Grep, Bash
---

# TZ Draft — structure the flow, ask only the leftovers

## Language

Work in the language the user writes or dictates in. Detect it from the dictation, the
draft, or the first message; if it is mixed or unclear, do not ask — use English.
Everything user-facing follows that language: the TZ document, the questions and their
recommended answers, the review journal, progress lines, the final report, and any commit
messages you write on the user's behalf. Keep verbatim: command names (`/tz-go`), file
names, code, config keys, and the code words — "FINISH", "DONE", and their Ukrainian
equivalent are the SAME code word in any language. The text blocks inside this skill are templates of
MEANING, not strings to paste: render them faithfully in the user's language. Prompts sent
to critic models may stay in English (models handle it best), but every finding you quote
back to the user is translated. Never switch language mid-run because a source file or a
kit template happens to be in another language.

Upstream companion to `/tz-review` and `/tz-verify`. The pipeline is:

```
dictation / draft → /tz-draft (structure → JTBD → 0-3 remaining questions → STRENGTHENED TZ)
                  → /tz-review (3 critics audit the TZ)
                  → implementation (in an isolated worktree — instruction embedded in the TZ)
                  → /tz-verify (3 critics verify implementation)
```

**Attribution.** The core concept — flow-dictation first, structure second, questions last
and only for genuine unknowns; answer-first questioning; the "FINISH" code-word exit;
strengthening an EXISTING draft rather than writing from scratch — is by this pack's
author. Only low-level question mechanics (options offered, YAGNI,
validate-before-writing) are adapted from the Superpowers `brainstorming` skill
(obra/superpowers, MIT). Superpowers' one-question-at-a-time rule is deliberately
REPLACED here by single-batch questioning — see Step 1 for why that is safe in this
design and cheaper in tokens.

## The philosophy: dictation beats interrogation

The user's best input is a **10-15 minute free-flow monologue** — spoken or typed without
structure. A person in flow gives deeper, broader context than a person answering
questions that arrive in jerks. Therefore this skill NEVER leads with questions. It leads
with LISTENING and STRUCTURING, and asks only what remains genuinely unknowable after that.

**The confidence gate (the central rule of questioning).** A question may be asked ONLY if
BOTH conditions hold:
1. Guessing wrong would be **expensive for the business** (money, access rights, mass
   communication, lost clients — not cosmetics), AND
2. You genuinely **cannot infer the answer with high confidence** from the dictation, the
   draft, or the codebase.

Everything that fails this gate you decide YOURSELF and record in the TZ (business-shaped
guesses → "⚠️ ASSUMPTION"; technical choices → "Default technical decisions").
**Typical interview: 0-3 questions. Hard cap: 7.** Zero questions is a perfectly good
outcome — it means the dictation was complete.

## The three hard rules

**Rule 1 — business only.** Questions may be ONLY about business logic. Never technology.

| ✅ may ask (business) | ❌ never ask (technical — decide yourself) |
|---|---|
| Who is the user, and what job does this do for them? | OS, hosting, server, cloud |
| What counts as "success", preferably in numbers? | Database, schema, ORM |
| What happens when X pays / cancels / fails? | Language, framework, library |
| Who is allowed to do what (roles, in business terms)? | Architecture, API shape |
| What is explicitly OUTSIDE scope v1? | Auth mechanism, tokens |
| Which existing flows must not break? | Deployment, CI, testing strategy |
| Business edge cases ("does the client have two contracts?") | Limits, cache, queues |
| Priorities: which half do we cut if necessary? | Any "which tool" question |

**Rule 2 — answer-first, ALWAYS.** Every question — no exceptions — arrives WITH:
(a) answer options, (b) **your recommendation: one marked answer**, and
(c) **an explanation of WHY it is the best answer in this situation** (1-3 sentences, grounded in
the dictation / draft / codebase). Options exist only to make disagreement cost one
letter rather than an essay — they do NOT transfer the choice to the person. Someone who does not understand
the options simply says "yes" to the recommendation. A bare question without a recommendation and
explanation violates the protocol.

**Rule 3 — the confidence gate** (described above): do not ask what you can answer
yourself with high confidence. If a question fails the gate, decide it yourself and record it in the TZ.

## Protocol

### Step 0 — Listen and structure (silently)

Input, in order of preference:
1. **Dictated monologue** — user talks/types freely for 10-15 min. This is the primary
   mode: "I'm going to talk it all out; organize my thoughts and turn them into a TZ."
2. **TZ draft** — file path or pasted text.
3. **Raw idea** — a few sentences.

Do NOT interrupt a monologue with questions. When it's done:
- Read the codebase around the feature area (grep models, routes, existing flows) —
  a question the code already answers is spam.
- Locate `{TZ_DIR}` per the `/tz-review` convention (`.ai-context/` → else `docs/specs/`
  or `docs/tz/` → else create `docs/tz/`).
- Structure everything said into the coverage checklist (Step 4) IN YOUR HEAD, and build
  the gap list. Run every gap through the confidence gate — most gaps die there and
  become your own recorded decisions. What survives (typically 0-3 items) is the
  interview, ordered by cost-of-guessing-wrong.

### Step 1 — ONE opening message: JTBD + warning + the ENTIRE question batch

**Send all questions in ONE message, not one at a time.** The reason is token economy:
each additional "question → answer" round forces the model to reread the entire
chat history (caching mitigates this, but does not eliminate it — and between slow human
replies, the cache has time to expire). A batch of N questions instead of N rounds saves
N-1 full rereads of the history.

**Why a batch is safe here (but not in a classic interview).** In a classic interview with
bare questions, a batch silently loses answers: the person answered 3 out of 7, and nobody
noticed. Here EVERY question carries a recommended answer — a skipped question
automatically receives it with a "✅ auto-accepted" mark in the TZ. The batch loses nothing.

The opening message contains, in this order:

**1. JTBD readback (+ non-goals + self-qualification):**

```
📋 How I understand the task (JTBD):
When [situation], [who] wants to [do what], so that [business outcome].
Success looks like this: [metric/observable outcome].
We explicitly will NOT do: [2-5 explicit non-goals — tempting additions deliberately excluded from v1].

Self-qualification: ["high confidence — I will decide the rest myself, {N} questions" /
"sufficient confidence except for {area} — which is why these {N} questions concern it"].

If this reading is wrong, correct me in the FIRST line of your reply; this is the cheapest
point to catch a wrong direction.
```

Non-goals are a mandatory part of the readback, alongside the JTBD: they protect against
scope creep, and the user must see them BEFORE the TZ is written.
Self-qualification makes the confidence gate visible: the line explains WHY there are
this many questions — the count always follows from the named unclear areas, never from a quota.

**2. Mandatory batch warning** (before the questions; preserve this exact meaning):

```
⚠️ Below are ALL my questions in one block ({N} of them). This is deliberate: each separate
"question-answer" round makes me reread the entire chat history and burns tokens.
Please reply in ONE message, for example: "1a, 2 yes, 3 my own
answer: …, 4 yes". If you skip a question, that's fine: I will use my
recommended answer. If you write "FINISH", I accept my recommendations for ALL
questions at once and deliver the TZ.
```

**3. Question batch** (each answer-first, in the same format):

```
Question {N}: {question}
Why I am asking: {what would break in the business if I guessed wrong, and why I cannot
infer the answer myself}
Options:
  a) {option}
  b) {option}
  c) {option}
✅ I recommend: {letter}) — {why this is the best answer: 1-3 sentences}
```

**4. FINISH footer** (as always).

Rules:
- If ≥3 questions remain after the gate, the last item in the batch is a **pre-mortem**: "Imagine it is one month
  after launch and the feature has failed. What is the most likely reason?" — also with your
  recommended answer. Result → "Open risks".
- If ZERO questions remain after the gate, the batch warning is unnecessary: "I have no questions;
  the dictation is complete" + JTBD + proceed directly to Step 3.
- Hard cap of 7 questions per batch. There is NO second batch — decide anything that did not fit
  into the first one yourself using the confidence gate.

### Step 2 — Process the single reply

- The user's numbered answers → lock THEIRS (you may object ONCE if
  an answer creates a concrete business risk, then accept it).
- Skipped questions → lock YOUR recommendation, with a "✅ auto-accepted" mark in the TZ.
- Answers contradict one another or overturn the JTBD → ONE clarification
  message (only about the contradiction), then deliver. This is the only permitted
  additional round.
- If the answers reveal that this is two projects → say so and suggest which should be v1
  (YAGNI) — in the same message as the deliverable.

### The code word — "FINISH" / "DONE" / the Ukrainian equivalent (same word, any language)

Printed at the end of EVERY message of this skill:

> Write **"FINISH"** — I will accept my own recommendations for everything remaining and immediately deliver
> the strengthened TZ and the command for the next step (`/tz-review`).

Semantics: stop asking instantly; auto-resolve remaining gaps with YOUR recommendations;
produce the TZ (Step 4) immediately. Auto-accepted rules are marked
**"✅ auto-accepted (FINISH)"** in the document; what even you couldn't answer →
**"⚠️ ASSUMPTION"** in "Open risks". Informal stops ("enough", "take it from here",
"move on to review") count as FINISH too — the footer exists so the user never has to
wonder HOW to stop you, not to make the literal word mandatory.

### Step 3 — Summary + TZ in ONE message (no extra confirmation round)

After processing the answers, do NOT hold a separate confirmation round. In one message:
**a short summary (5-8 lines)** — goal, user, core scenario, non-goals, the 2-3
riskiest business rules, with their sources marked (answer / ✅ auto-accepted) —
and IMMEDIATELY below it, the strengthened TZ (Step 4). The summary is a navigation aid for the person, not a
gate: all disputed points have already been either confirmed by answers or honestly marked
✅/⚠️ in the document, so an error is fixed by editing, not by another round.

The only exception: answers contradict one another or overturn the JTBD → one clarification
(see Step 2), then deliver.

### Step 4 — Produce the strengthened TZ (EDIT, don't replace)

**The output is the user's material, structured and reinforced — never your document
instead of theirs.**

- Draft file → edit THAT file (bump the version in the heading: "v2 — strengthened by /tz-draft,
  {date}"). Dictation/pasted text → write `{TZ_DIR}/TZ_{slug}.md`, preserving
  the user's wording and emphasis wherever they are sound.
- **Insert, don't overwrite.** Rewrite a passage only if the interview disproved it
  — and then record that in the changelog.
- At the top, a changelog block:

  ```markdown
  > **What was strengthened relative to the dictation/draft ({date}):**
  > - added: {rule} — from the answer to question N
  > - added: {…} — ✅ auto-accepted (FINISH)
  > - changed: {before → after} — because {user's answer}
  ```

- **Coverage checklist** — after your edits, the document must answer everything below
  (add a section only if it is actually missing; match the user's heading style):
  1. Goal and JTBD (+ success metric + a "Non-goals: what we explicitly will NOT do" block immediately
     alongside them — the 2-5 main exclusions from Step 1; the detailed "Outside scope v1" below
     supplements these rather than replacing them) — from the confirmed Step 1
  2. Users and roles
  3. Main scenario (from the user's perspective)
  4. Business rules — numbered; each: confirmed / ✅ auto-accepted (FINISH)
  5. Edge cases (business)
  6. Outside scope v1 (explicit exclusions + YAGNI cuts)
  7. Implementation order — 2-4 phases, each ending with something WORKING; phase 1 =
     the thinnest end-to-end slice
  8. Acceptance Criteria — AC-1..N; one criterion = one verifiable statement without "and";
     a format that `/tz-verify` can parse
  9. Default technical decisions — everything you did NOT ask about: decision + 1 sentence
     explaining why. **The first line of this section — ALWAYS, without exception:**

     > Implement in an isolated git worktree (branch `feat/{slug}`): the agent
     > creates the worktree BEFORE the first edit, commits frequently, delivers via push + Pull Request
     > after checks pass, and removes the worktree after merge. Unmerged work
     > may only be destroyed with the person's explicit word "discard".

     This is an instruction to the implementing agent, embedded in the TZ. The user does not manage it and does not need
     to understand git — the implementer reads the TZ and creates the isolation itself.
  10. Open risks — pre-mortem result + ⚠️ ASSUMPTION

### Step 5 — Hand off

```
✅ TZ ready: {path}
Changes relative to the dictation are in the changelog block at the top of the document.
{if any were auto-accepted: N rules were accepted automatically — marked ✅}
{if there were assumptions: ⚠️ check the "Open risks" section}

Next step — an audit by three independent models:
/tz-review {path}
```

Do NOT auto-run `/tz-review` — it is expensive; the user triggers it.

## Anti-patterns

- Leading with questions instead of listening — the monologue comes first, always.
- JTBD readback without "We explicitly will NOT do" or without the self-qualification line — the user
  must see both the task boundary and why there are this many questions.
- **Asking a question you could answer yourself with high confidence** — the #1 way this
  skill becomes annoying. The confidence gate is not optional.
- A question without a recommended answer AND the reasoning why it's the most correct one.
- **Scattering questions across separate messages** — each extra round means
  rereading the entire chat history. All questions go in one batch in one message.
- A batch without the warning "reply in one message; skipped questions → I will use my
  recommendation" — the person must know the rules BEFORE the block of questions arrives.
- A second question batch after the first — decide what did not fit yourself (confidence gate).
- Anything from the ❌ column — catch yourself, decide it, section 9.
- Interrupting the dictation.
- A message without the "FINISH" footer.
- Ignoring an informal stop because it wasn't the literal code word.
- An unnecessary confirmation round before delivering the TZ when answers are consistent —
  the summary and TZ go in one message.
- Rewriting the user's sound text with your own phrasing — insert and augment; their
  words are the backbone, you are the reinforcement.
- Inventing business rules that trace to nothing — everything in section 4 is confirmed,
  ✅ auto-accepted, or doesn't exist.
- Omitting the worktree instruction from section 9 — it is mandatory in every TZ.

## When NOT to invoke

- The TZ is already complete and confirmed → go directly to `/tz-review`.
- Bug fix or trivial change → just do it, without an interview.
- The input already answers the entire checklist → zero questions, proceed directly to the Step 3 summary, with the note
  "there were no questions — the input was complete", but the JTBD opening (Step 1) is still mandatory.
