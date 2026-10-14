---
name: unslop
description: >-
  Find and fix LLM-generated code slop: unnecessary comments, speculative
  complexity, low-value tests, and Rust API mistakes.  Recheck affected code after subsequent LLM edits.
---

# Unslop

Find and fix the specific problems below before presenting code for human review.
An invocation such as "review the code and /unslop" requests repairs, not just a
list of findings. Make well-supported fixes directly unless the user explicitly
requests a read-only review.

## Scope

Follow the repository's instructions and any scope the user supplies. By default,
review local, uncommitted changes: the combined staged and unstaged changes, plus
relevant untracked source and test files. Review the current working-tree contents,
not just an intermediate staged version. Do not include ignored files, generated
artifacts, or unrelated local files.

Read unchanged surrounding code, tests, and configuration as needed to understand
the changes. Do not turn that investigation into a cleanup of unchanged code.
Review an entire repository or module only when directed to do so.

## Review and repair

1. Inspect the changes and their purpose. Establish the intended behavior and any
   compatibility requirements from the request and repository evidence, including
   manifests, tests, documentation, and existing callers.
2. Apply the checks below. For each suspected problem, identify a concrete reason
   it adds maintenance cost without enough benefit. Do not treat a stylistic
   preference or a short implementation as proof of slop.
3. Make targeted fixes within scope. Preserve intended behavior, required
   compatibility, security properties, and unrelated user changes. Do not stage,
   commit, or reset files as part of this pass. Do not discard unrelated changes.
   If a material tradeoff remains uncertain after inspecting the available
   evidence, ask the user rather than inventing a requirement or removing a
   safeguard.
4. Review the affected changes again after editing. Repeat only when a concrete
   issue remains or a fix introduces one; stop when the applicable checks reveal
   no further justified fixes. Do not keep rewriting acceptable code to satisfy
   this skill. If later LLM edits touch reviewed code, recheck those changes and
   their effects rather than restarting an unrelated whole-repository review.
5. Run the relevant formatter, lint checks, and tests required by the project and
   affected by the edits. If another edit follows verification, rerun the affected
   checks. Report checks that could not be run; do not imply they passed.
6. Summarize what changed and why, with file locations and verification results.
   Report unresolved findings separately, with the reason each remains unresolved.
   If nothing needed fixing, say so without manufacturing work. In a read-only
   review, give locations, reasons, and proposed fixes instead of making edits.

## Parallel review

For a sufficiently large diff, use separate subagents for independent categories
of checks if delegation is available and permitted. For a small diff, review it
directly; parallelism should save work, not create it.

Give each reviewer a bounded scope and ask for findings with locations, reasons,
and proposed fixes. Reviewers should not edit files. One coordinator reconciles
the findings, makes the justified edits, and verifies the resulting code. Do not
recursively delegate follow-up reviews.

## General checks

### Comments

Inspect changed comment lines and the code they describe. Remove narration of
obvious operations and explanations of distant implementation details that are
likely to become stale. Keep concise explanations of non-obvious constraints,
invariants, and reasons a seemingly unnecessary step must remain. Correct a stale
comment when a useful explanation is still needed; do not simply delete it.

Remove historical narration that does not explain a current requirement: what a
previous implementation did, when a refactor happened, or which version first
introduced an otherwise ordinary behavior. Keep history only where it explains a
present constraint or the user explicitly requested it. For example, a comment
explaining why an older supported server requires a fallback is useful; a story
about how the fallback was developed is not. Establish compatibility requirements
from repository evidence, not just what the user happened to mention.

### Speculative complexity

Remove branches, abstractions, configuration options, and defensive machinery
added for unsupported or implausible scenarios rather than actual requirements.
Engineering requires sane, informed tradeoffs, not an attempt to accommodate every
imagined environment.

Distinguish speculation from realistic input boundaries, trust boundaries,
documented failure modes, and supported environments. Do not remove validation or
error handling merely because the normal path works without it. When the evidence
does not settle a consequential tradeoff, ask the user.

### Tests

Examine every added or substantially changed test, and each new test module. Start
from the position that a new test must earn its maintenance cost. Ask what
plausible defect it would catch, whether that defect matters, and whether existing
tests already catch it.

Keep tests of error-prone algorithms, meaningful integrations, reproduced bugs,
and important behavioral contracts. Simple code can still enforce an important
contract, such as an authorization decision, a default value, or a serialization
rule. Implementation length is not a measure of test value.

Remove tests that merely reproduce the implementation as assertions, confirm their
own mock setup, exercise only a third-party library's behavior, or duplicate
existing coverage without checking a distinct failure mode or requirement.
Distinguish tests of a library itself from useful tests of our integration with
it. Extensive mocking is a reason to inspect a test closely, not an automatic
reason to delete it.

When deleting a test, verify that it does not provide distinct coverage of a
required behavior. Do not delete a meaningful failing test to make verification
pass.

## Rust checks

### Free functions and conversions

Audit every new free function. If it takes one of our types by reference or value
and operates on it, consider whether it belongs in that type's `impl` block.
Make the design judgment explicitly; touching a type does not by itself make a
function a method.

If a free function is only called from within an `impl` block (not counting tests), then it belongs in the `impl` block
by default.

If a function converts between types and we control at least one of them,
consider whether it should implement `From` for an infallible conversion or
`TryFrom` for a fallible one. Prefer those traits over direct `Into` or `TryInto`
implementations: the corresponding blanket implementations provide the latter.
Check that the conversion semantics and Rust's coherence rules fit; do not force
context-dependent operations or conversions requiring extra policy into a trait.

### Visibility

Audit new or changed `pub` items. Keep `pub` only where the intended external API
requires it; otherwise use `pub(crate)` or narrower visibility as appropriate.
Check callers and the existing API contract before narrowing visibility.

Externally reachable library APIs generally do not receive `dead_code` warnings,
so unnecessary exposure can hide unused code. A `pub` item inside a private module
or binary crate can still be diagnosed; the keyword alone does not determine
reachability or lint behavior.
