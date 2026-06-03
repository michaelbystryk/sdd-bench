# Execution Plan — postal_validator

## Detailed Analysis Summary

### Change Impact Assessment
- **User-facing changes**: Yes — a CLI (`python -m postal_validator`) and an importable API.
- **Structural changes**: No (new greenfield package; no existing architecture to alter).
- **Data model changes**: Minimal — one small value object `ValidationResult`.
- **API changes**: New public API (`validate`, `normalize`, `ValidationResult`).
- **NFR impact**: Stdlib-only constraint, Python-3.9 compatibility, exit-code semantics.

### Risk Assessment
- **Risk Level**: Low — isolated, pure-function library; behavior pinned by a provided test suite.
- **Rollback Complexity**: Easy (self-contained new files).
- **Testing Complexity**: Simple — example-based tests provided; add stdlib property-based tests.

## Workflow Visualization

```mermaid
flowchart TD
    Start(["User Request"])

    subgraph INCEPTION["INCEPTION PHASE"]
        WD["Workspace Detection<br/><b>COMPLETED</b>"]
        RE["Reverse Engineering<br/><b>SKIP</b>"]
        RA["Requirements Analysis<br/><b>COMPLETED</b>"]
        US["User Stories<br/><b>SKIP</b>"]
        WP["Workflow Planning<br/><b>COMPLETED</b>"]
        AD["Application Design<br/><b>SKIP</b>"]
        UG["Units Generation<br/><b>SKIP</b>"]
    end

    subgraph CONSTRUCTION["CONSTRUCTION PHASE"]
        FD["Functional Design<br/><b>SKIP</b>"]
        NFRA["NFR Requirements<br/><b>SKIP</b>"]
        NFRD["NFR Design<br/><b>SKIP</b>"]
        ID["Infrastructure Design<br/><b>SKIP</b>"]
        CG["Code Generation<br/>(Planning + Generation)<br/><b>EXECUTE</b>"]
        BT["Build and Test<br/><b>EXECUTE</b>"]
    end

    subgraph OPERATIONS["OPERATIONS PHASE"]
        OPS["Operations<br/><b>PLACEHOLDER</b>"]
    end

    Start --> WD
    WD --> RA
    RA --> WP
    WP --> CG
    CG --> BT
    BT --> End(["Complete"])

    style WD fill:#4CAF50,stroke:#1B5E20,stroke-width:3px,color:#fff
    style RA fill:#4CAF50,stroke:#1B5E20,stroke-width:3px,color:#fff
    style WP fill:#4CAF50,stroke:#1B5E20,stroke-width:3px,color:#fff
    style CG fill:#4CAF50,stroke:#1B5E20,stroke-width:3px,color:#fff
    style BT fill:#4CAF50,stroke:#1B5E20,stroke-width:3px,color:#fff
    style RE fill:#BDBDBD,stroke:#424242,stroke-width:2px,stroke-dasharray: 5 5,color:#000
    style US fill:#BDBDBD,stroke:#424242,stroke-width:2px,stroke-dasharray: 5 5,color:#000
    style AD fill:#BDBDBD,stroke:#424242,stroke-width:2px,stroke-dasharray: 5 5,color:#000
    style UG fill:#BDBDBD,stroke:#424242,stroke-width:2px,stroke-dasharray: 5 5,color:#000
    style FD fill:#BDBDBD,stroke:#424242,stroke-width:2px,stroke-dasharray: 5 5,color:#000
    style NFRA fill:#BDBDBD,stroke:#424242,stroke-width:2px,stroke-dasharray: 5 5,color:#000
    style NFRD fill:#BDBDBD,stroke:#424242,stroke-width:2px,stroke-dasharray: 5 5,color:#000
    style ID fill:#BDBDBD,stroke:#424242,stroke-width:2px,stroke-dasharray: 5 5,color:#000
    style OPS fill:#FFF59D,stroke:#F57F17,stroke-width:2px,stroke-dasharray: 5 5,color:#000
    style Start fill:#CE93D8,stroke:#6A1B9A,stroke-width:3px,color:#000
    style End fill:#CE93D8,stroke:#6A1B9A,stroke-width:3px,color:#000

    linkStyle default stroke:#333,stroke-width:2px
```

### Text Alternative (always included)
```
INCEPTION
  - Workspace Detection ....... COMPLETED
  - Reverse Engineering ....... SKIP (no implemented system)
  - Requirements Analysis ..... COMPLETED
  - User Stories .............. SKIP (clear spec, no personas)
  - Workflow Planning ......... COMPLETED
  - Application Design ........ SKIP (single module)
  - Units Generation .......... SKIP (single unit)
CONSTRUCTION
  - Functional Design ......... SKIP (pure functions, rules already specified)
  - NFR Requirements .......... SKIP (folded into requirements.md)
  - NFR Design ................ SKIP
  - Infrastructure Design ..... SKIP (no infra)
  - Code Generation ........... EXECUTE  (unit: postal-validator-core)
  - Build and Test ............ EXECUTE
OPERATIONS
  - Operations ................ PLACEHOLDER
```

## Phases to Execute

### 🔵 INCEPTION PHASE
- [x] Workspace Detection (COMPLETED)
- [x] Reverse Engineering (SKIPPED) — *Rationale*: greenfield; no implemented system to analyze.
- [x] Requirements Analysis (COMPLETED)
- [x] User Stories (SKIPPED) — *Rationale*: internal utility + CLI; behavior fully pinned by tests; no personas/UX flows.
- [x] Workflow Planning (COMPLETED)
- [ ] Application Design — **SKIP** — *Rationale*: one small module, no service layer or component graph.
- [ ] Units Generation — **SKIP** — *Rationale*: a single unit of work; no decomposition needed.

### 🟢 CONSTRUCTION PHASE
- [ ] Functional Design — **SKIP** — *Rationale*: logic is pure functions whose rules are exhaustively
  specified in `reference/formats.md`; testable properties captured in requirements.md and the code-gen plan.
- [ ] NFR Requirements — **SKIP (folded)** — *Rationale*: NFRs are minimal and already documented in
  `requirements.md` (stdlib-only, 3.9 compatibility, exit codes); PBT-09 framework decision recorded in `aidlc-state.md`.
- [ ] NFR Design — **SKIP** — *Rationale*: no cross-cutting NFR patterns/components to design.
- [ ] Infrastructure Design — **SKIP** — *Rationale*: no infrastructure, deployment, or cloud resources.
- [ ] Code Generation — **EXECUTE (ALWAYS)** — *Rationale*: implement the package + CLI + tests (single unit).
- [ ] Build and Test — **EXECUTE (ALWAYS)** — *Rationale*: run the full test suite and document build/test.

### 🟡 OPERATIONS PHASE
- [ ] Operations — PLACEHOLDER

## Units of Work
1. **postal-validator-core** — the `postal_validator` package (core validation/normalization + CLI)
   and its tests. Single unit; no inter-unit dependencies.

## Estimated Timeline
- **Total executing stages**: 5
- **Estimated Duration**: Short — single implementation pass plus test run.

## Success Criteria
- **Primary Goal**: A stdlib-only `postal_validator` package whose `validate`/`normalize` and CLI
  behave exactly per `reference/formats.md`.
- **Key Deliverables**:
  - `postal_validator/__init__.py` exporting `validate`, `normalize`, `ValidationResult`.
  - Core rule engine for CA/US/UK.
  - `postal_validator/__main__.py` CLI (single, `--json`, stdin batch, exit codes, `--help`).
  - Property-based tests (stdlib) complementing the provided example-based tests.
- **Quality Gates**:
  - All tests in `tests/` pass (`test_core.py`, `test_cli.py`).
  - Added property-based tests pass.
  - No third-party runtime dependencies; runs under Python 3.9.
