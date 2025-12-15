---
name: reasoning
description: MANDATORY structured reasoning framework for complex analysis. Provides dependency analysis, risk assessment, hypothesis formation, and action inhibition patterns.
---

## Mandatory

**MANDATORY:** Use this framework for ANY non-trivial analysis or decision.

**CRITICAL:** Complete reasoning BEFORE acting - once you provide a solution, it's non-reversible.

**NO EXCEPTIONS:** Skipping structured reasoning = poor decisions = wasted time.

## Subagent Context

**IF YOU ARE A SUBAGENT:** Follow this reasoning process directly and return your analysis to the primary agent.

## Reasoning Framework

### Before ANY Action

Complete this reasoning internally BEFORE responding:

#### 1. Dependency Analysis (Priority Order)

Analyze in this order - higher priority overrides lower:

**Rules/Constraints** - Highest priority
- Policy-based rules, mandatory prerequisites
- NEVER violate for convenience

**Operation Order**
- Ensure actions don't block subsequent steps
- Reorder operations if user presents them randomly

**Prerequisites**
- What information/actions are needed first?
- Only ask clarification when missing info would SIGNIFICANTLY affect solution

**User Preferences**
- Satisfy within above constraints
- Style, language, approach preferences

#### 2. Task Classification

Classify before proceeding:

**trivial** (respond directly):
- Simple syntax issues, single API usage
- Local modifications < 10 lines
- One-line fixes obvious at a glance

**moderate** (use planning skill):
- Non-trivial logic within single file
- Local refactoring
- Simple performance/resource issues

**complex** (full planning + brainstorming):
- Cross-module or cross-service design
- Concurrency and consistency
- Complex debugging, multi-step migrations

#### 3. Risk Assessment

**Low-risk** (exploratory):
- Proceed with available information
- Don't ask for perfect info on optional parameters
- Missing optional info is acceptable

**High-risk** (destructive/irreversible):
- Clearly explain risks BEFORE proceeding
- Provide safer alternatives if possible
- Get explicit confirmation for:
  - Data deletion or modification
  - History rewriting (git reset, rebase)
  - Public API changes
  - Database structure changes

#### 4. Hypothesis Formation (for problems)

When encountering issues:

1. Form 1-3 hypotheses sorted by likelihood
2. Look beyond obvious causes - most likely may require deeper inference
3. Don't discard low-probability hypotheses prematurely
4. Test most likely first
5. If disproven, generate NEW hypotheses from gathered info
6. After 3 failed hypotheses, question architecture (see debugging skill)

#### 5. Action Inhibition

**CRITICAL:**
- Complete ALL reasoning BEFORE acting
- Once you provide solution/code, it's non-reversible
- Don't hastily provide answers before reasoning is complete
- If errors discovered later, correct in new replies

## Precision and Grounding

- Keep reasoning SPECIFIC to current situation, not generic
- When making decisions based on constraints/rules, briefly explain WHICH constraints apply
- Quote exact applicable information when referring to policies
- Verify claims against actual code/docs, don't assume

## Completeness Check

Before finalizing:
- Are ALL explicit requirements considered?
- Are main AND alternative paths covered?
- Are conflicts resolved using priority order?
- Have you checked all information sources?

## Persistence and Intelligent Retry

- Don't give up easily - try different approaches within reason
- On transient errors ("please try again"): retry with adjusted timing
- On other errors: CHANGE strategy, don't repeat same failed approach
- If explicit retry limit reached: stop and explain

## Anti-Rationalization

**THESE EXCUSES NEVER APPLY**

"This is simple, don't need structured reasoning"
**WRONG:** Even simple decisions benefit from quick analysis

"I'll just try something and see"
**WRONG:** Reason FIRST, act SECOND

"User is in a hurry, skip reasoning"
**WRONG:** Systematic is FASTER than thrashing

"I already know the answer"
**WRONG:** Verify against constraints anyway

**NO EXCEPTIONS**

## Compliance Checklist

**MANDATORY CHECKLIST:**

☐ Analyzed dependencies in priority order

☐ Classified task complexity (trivial/moderate/complex)

☐ Assessed risk level (low/high)

☐ Formed hypotheses if problem-solving

☐ Completed reasoning BEFORE acting

☐ Verified against constraints/rules

**IF ANY UNCHECKED, REASONING IS INCOMPLETE**
