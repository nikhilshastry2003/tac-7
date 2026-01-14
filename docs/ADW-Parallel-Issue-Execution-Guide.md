# ADW Parallel Issue Execution Guide

## Understanding Agentic Development Workflows (ADW) - A Complete Walkthrough

This document explains how we implemented GitHub issues #5 and #6 in parallel using the ADW (Agentic Development Workflow) system, including the challenges faced, solutions implemented, and the complete data flow.

---

## Table of Contents

1. [Intent & Issues Created](#1-intent--issues-created)
2. [How We Triggered the Workflows](#2-how-we-triggered-the-workflows)
3. [Why Single Command Failed Initially](#3-why-single-command-failed-initially)
4. [How Claude Fixed the Parallel Execution Error](#4-how-claude-fixed-the-parallel-execution-error)
5. [Understanding the Trees Directory](#5-understanding-the-trees-directory)
6. [Why Multiple Folders for 2 Issues](#6-why-multiple-folders-for-2-issues)
7. [Data Flow When Triggering Issues](#7-data-flow-when-triggering-issues)
8. [Flowchart: Issue to Implementation](#8-flowchart-issue-to-implementation)
9. [Summary: Parallel Issue Implementation](#9-summary-parallel-issue-implementation)

---

## 1. Intent & Issues Created

### Our Intent
We wanted to demonstrate and test the ADW system's capability to handle **parallel development workflows** - processing multiple GitHub issues simultaneously without conflicts. This is crucial for:
- Reducing development time
- Simulating real-world scenarios where multiple features are developed concurrently
- Testing the isolation mechanism of git worktrees

### Issues Created

#### Issue #5: Increase Drop Zone Surface Area
```
Title: increase the drop zone surface area
Type: /feature

Description: Let's increase the drop zone surface area, instead of clicking
'upload data', the user can drag and drop right on the upper div or lower div.
Also the UI will update to 'Drop to create the table'.
This has the exact functionality, but a bit user friendly.
```

#### Issue #6: Update JSON Export
```
Title: update json export
Type: /feature (inferred)

Description: Update to support table and query result 'json export',
similar to csv export, but this is specifically for json export.
```

Both issues represent **feature enhancements** to the Natural Language SQL Interface application.

---

## 2. How We Triggered the Workflows

### Method 1: PowerShell Script (run_adw_issues.ps1)
We created a dedicated PowerShell script that:

```powershell
# Step 1: Clean up old worktrees and agent states
git worktree remove ... --force
Remove-Item agents\* -Recurse -Force
git worktree prune

# Step 2: Run Plan for Issue 5
uv run adw_plan_iso.py 5

# Step 3: Run Build for Issue 5
uv run adw_build_iso.py 5 $Issue5AdwId

# Step 4: Run Plan for Issue 6
uv run adw_plan_iso.py 6

# Step 5: Run Build for Issue 6
uv run adw_build_iso.py 6 $Issue6AdwId
```

### Method 2: Direct Command Line
```bash
# For single issue SDLC (complete workflow)
uv run adw_sdlc_iso.py 5

# For parallel execution (separate terminals)
# Terminal 1:
uv run adw_sdlc_iso.py 5

# Terminal 2:
uv run adw_sdlc_iso.py 6
```

### Why `uv run`?
- `uv` is a fast Python package manager that handles dependencies inline
- The script header declares dependencies: `dependencies = ["python-dotenv", "pydantic"]`
- No virtual environment activation needed - `uv` handles it automatically

---

## 3. Why Single Command Failed Initially

### The Problem
We ran `uv run adw_sdlc_iso.py 5` and `uv run adw_sdlc_iso.py 6` separately (not as `uv run adw_sdlc_iso.py 5 6`). Initially, Claude threw an error saying it **cannot run both issues together**.

**Note:** The script is designed for single-issue processing - each command handles one issue at a time:

```python
# From adw_sdlc_iso.py
def main():
    if len(sys.argv) < 2:
        print("Usage: uv run adw_sdlc_iso.py <issue-number> [adw-id]")
        sys.exit(1)

    issue_number = sys.argv[1]  # Only takes ONE issue number
    adw_id = sys.argv[2] if len(sys.argv) > 2 else None  # Second arg is ADW ID to resume, not second issue
```

**However**, Claude later fixed the parallel execution issue automatically and successfully ran both issues together.

### Why This Design?
1. **Isolation Requirement**: Each issue needs its own isolated environment
2. **Port Allocation**: Each worktree gets unique ports (e.g., 9101/9201 for issue 5, 9102/9202 for issue 6)
3. **State Management**: Each issue has its own `adw_state.json` tracking progress
4. **Git Worktree Limitation**: Each worktree represents ONE branch for ONE issue

### The Error
When Claude Code instances were started simultaneously on Windows, we encountered:
```
ncrypto::CSPRNG assertion error
```
This was a **cryptographic random number generator initialization race condition** on Windows.

---

## 4. How Claude Fixed the Parallel Execution Error

### The Root Cause
On Windows, when multiple Claude Code CLI processes start simultaneously, they compete to initialize the cryptographic random number generator (CSPRNG), causing assertion failures.

### The Solution: ClaudeStartupLock
A file-based mutex system was implemented in `adws/adw_modules/agent.py`:

```python
class ClaudeStartupLock:
    """Context manager for serializing Claude Code startup on Windows.

    This prevents the ncrypto::CSPRNG assertion error that occurs when
    multiple Claude Code instances try to initialize simultaneously.
    """

    def __init__(self, timeout: float = 60.0):
        self.timeout = timeout
        self.lock_path = os.path.join(tempfile.gettempdir(), "claude_code_startup.lock")

    def __enter__(self):
        # Add initial random delay to stagger startup attempts (3-5 seconds)
        initial_delay = random.uniform(3.0, 5.0)
        time.sleep(initial_delay)

        if sys.platform == "win32":
            # Windows: Use exclusive file creation as a lock
            while time.time() - start_time < self.timeout:
                try:
                    fd = os.open(self.lock_path, os.O_CREAT | os.O_EXCL | os.O_WRONLY)
                    os.write(fd, str(os.getpid()).encode())
                    os.close(fd)
                    self.acquired = True
                    break
                except FileExistsError:
                    time.sleep(random.uniform(1.0, 2.0))  # Wait and retry
```

### How It Works
1. **Random Initial Delay**: Each process waits 3-5 seconds randomly to stagger starts
2. **Exclusive Lock File**: Uses `os.O_CREAT | os.O_EXCL` for atomic lock acquisition
3. **Retry Logic**: If lock exists, wait and retry up to 60 seconds
4. **Post-Lock Delay**: Additional 2-second delay after acquiring lock for Windows crypto init
5. **Automatic Cleanup**: Lock file removed when process exits

### Result
With this fix, multiple ADW workflows can now run in parallel on Windows without the CSPRNG assertion error.

---

## 5. Understanding the Trees Directory

### What is the Trees Directory?
The `trees/` directory contains **git worktrees** - isolated copies of the repository where each issue is developed independently.

```
tac-7/
├── trees/
│   ├── 79447884/          # Worktree for Issue #5
│   │   ├── app/
│   │   │   ├── client/    # Frontend code
│   │   │   └── server/    # Backend code
│   │   ├── specs/         # Implementation plans
│   │   └── .ports.env     # Port configuration
│   │
│   ├── da3a30ce/          # Worktree for Issue #6
│   │   ├── app/
│   │   ├── specs/
│   │   └── .ports.env
│   │
│   └── [other worktrees...]
```

### What's Inside Each Worktree?

| Directory/File | Purpose |
|---------------|---------|
| `app/` | Complete copy of the application code |
| `app/client/` | React frontend with Vite |
| `app/server/` | Python FastAPI backend |
| `specs/` | Implementation plan markdown files |
| `.ports.env` | Port configuration for this worktree |
| `.env` | Environment variables (API keys, etc.) |

### Why is it Important?

1. **Isolation**: Changes in one worktree don't affect others
2. **Parallel Development**: Multiple issues can be worked on simultaneously
3. **No Git Conflicts**: Each worktree has its own branch
4. **Independent Testing**: Each worktree runs on different ports
5. **Clean Rollback**: Entire worktree can be deleted without affecting main repo

### How Worktrees Are Created

```python
# From worktree_ops.py
def create_worktree(adw_id: str, branch_name: str, logger):
    # Construct worktree path
    worktree_path = os.path.join(project_root, "trees", adw_id)

    # Create the worktree with a new branch from origin/main
    cmd = ["git", "worktree", "add", "-b", branch_name, worktree_path, "origin/main"]
    subprocess.run(cmd)
```

### Port Allocation
Each worktree gets unique ports based on its ADW ID:
```python
def get_ports_for_adw(adw_id: str) -> Tuple[int, int]:
    # Convert ADW ID to index (0-14)
    index = int(adw_id[:8], 36) % 15
    backend_port = 9100 + index   # Range: 9100-9114
    frontend_port = 9200 + index  # Range: 9200-9214
    return backend_port, frontend_port
```

---

## 6. Why Multiple Folders for 2 Issues

### Current Trees Directory Structure
```
trees/
├── 0390a27b/
├── 14435e3c/
├── 36fbc47f/
├── 74ce18f8/
├── 79447884/    <-- Issue #5 (latest successful run)
├── 9270b7f5/
├── da3a30ce/    <-- Issue #6 (latest successful run)
├── f6592677/
└── issue6-json/
```

### Why So Many Folders?
Each folder represents a **previous ADW workflow run**. Here's why there are many:

1. **Failed/Interrupted Runs**: Earlier attempts that failed due to:
   - CSPRNG errors before the fix
   - Network issues
   - Claude Code timeouts
   - Missing dependencies

2. **Testing Iterations**: Each test run creates a new ADW ID:
   ```python
   def make_adw_id() -> str:
       return uuid.uuid4().hex[:8]  # Random 8-character ID
   ```

3. **Incremental Development**: As we fixed issues, we re-ran the workflows

4. **No Automatic Cleanup**: Worktrees persist until manually removed

### What Each Folder Contains
Each folder represents a complete state snapshot:
```
agents/<adw_id>/
├── adw_state.json           # Workflow state
├── issue_classifier/        # Classification agent outputs
├── branch_generator/        # Branch name generation
├── sdlc_planner/           # Planning agent outputs
├── sdlc_implementor/       # Implementation agent outputs
├── test_runner/            # Test execution outputs
├── reviewer/               # Code review outputs
├── documenter/             # Documentation outputs
├── kpi_tracker/            # KPI tracking outputs
└── [phase]_committer/      # Commit message generation
```

### Cleaning Up Old Worktrees
```powershell
# Remove all worktrees
git worktree list --porcelain | Select-String "worktree" | ForEach-Object {
    $wt = $_.Line -replace "worktree ", ""
    if ($wt -like "*trees*") {
        git worktree remove $wt --force
    }
}
git worktree prune

# Or use the cleanup script
./scripts/cleanup_worktrees.ps1
```

---

## 7. Data Flow When Triggering Issues

### Files Created During Workflow

When you run `uv run adw_sdlc_iso.py <issue-number>`, here's what gets created:

```
Phase 1: PLANNING (adw_plan_iso.py)
├── agents/<adw_id>/adw_state.json         # Created: Initial state
├── agents/<adw_id>/issue_classifier/       # Created: Issue classification
├── agents/<adw_id>/branch_generator/       # Created: Branch name
├── agents/<adw_id>/sdlc_planner/          # Created: Implementation plan
├── trees/<adw_id>/                         # Created: Git worktree
├── trees/<adw_id>/.ports.env              # Created: Port config
└── trees/<adw_id>/specs/issue-*.md        # Created: Plan file

Phase 2: BUILDING (adw_build_iso.py)
├── agents/<adw_id>/sdlc_implementor/      # Created: Implementation logs
├── trees/<adw_id>/app/client/src/*        # Modified: Frontend changes
└── trees/<adw_id>/app/server/*            # Modified: Backend changes

Phase 3: TESTING (adw_test_iso.py)
├── agents/<adw_id>/test_runner/           # Created: Test results
└── [Test files in worktree]               # Modified: Test updates

Phase 4: REVIEW (adw_review_iso.py)
├── agents/<adw_id>/reviewer/              # Created: Review feedback
└── [Patches if needed]                    # Modified: Code fixes

Phase 5: DOCUMENTATION (adw_document_iso.py)
├── agents/<adw_id>/documenter/            # Created: Doc generation
├── agents/<adw_id>/kpi_tracker/           # Created: KPI tracking
└── trees/<adw_id>/docs/*                  # Created: Documentation
```

### Complete Data Flow Diagram

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                        ADW SDLC Data Flow                                    │
└─────────────────────────────────────────────────────────────────────────────┘

GitHub Issue #5                           GitHub Issue #6
      │                                         │
      ▼                                         ▼
┌─────────────┐                          ┌─────────────┐
│ gh issue    │                          │ gh issue    │
│ fetch #5    │                          │ fetch #6    │
└──────┬──────┘                          └──────┬──────┘
       │                                        │
       ▼                                        ▼
┌──────────────────┐                    ┌──────────────────┐
│ /classify_issue  │                    │ /classify_issue  │
│ → /feature       │                    │ → /feature       │
└────────┬─────────┘                    └────────┬─────────┘
         │                                       │
         ▼                                       ▼
┌──────────────────┐                    ┌──────────────────┐
│ /generate_branch │                    │ /generate_branch │
│ → feat-issue-5-* │                    │ → feat-issue-6-* │
└────────┬─────────┘                    └────────┬─────────┘
         │                                       │
         ▼                                       ▼
┌──────────────────┐                    ┌──────────────────┐
│ git worktree add │                    │ git worktree add │
│ trees/79447884   │                    │ trees/da3a30ce   │
│ Ports: 9101/9201 │                    │ Ports: 9102/9202 │
└────────┬─────────┘                    └────────┬─────────┘
         │                                       │
         ▼                                       ▼
┌──────────────────┐                    ┌──────────────────┐
│ /feature (plan)  │                    │ /feature (plan)  │
│ → specs/*.md     │                    │ → specs/*.md     │
└────────┬─────────┘                    └────────┬─────────┘
         │                                       │
         ▼                                       ▼
┌──────────────────┐                    ┌──────────────────┐
│ /implement       │                    │ /implement       │
│ → code changes   │                    │ → code changes   │
└────────┬─────────┘                    └────────┬─────────┘
         │                                       │
         ▼                                       ▼
┌──────────────────┐                    ┌──────────────────┐
│ /test            │                    │ /test            │
│ → run tests      │                    │ → run tests      │
└────────┬─────────┘                    └────────┬─────────┘
         │                                       │
         ▼                                       ▼
┌──────────────────┐                    ┌──────────────────┐
│ /review          │                    │ /review          │
│ → code review    │                    │ → code review    │
└────────┬─────────┘                    └────────┬─────────┘
         │                                       │
         ▼                                       ▼
┌──────────────────┐                    ┌──────────────────┐
│ /document        │                    │ /document        │
│ → generate docs  │                    │ → generate docs  │
└────────┬─────────┘                    └────────┬─────────┘
         │                                       │
         ▼                                       ▼
┌──────────────────┐                    ┌──────────────────┐
│ /pull_request    │                    │ /pull_request    │
│ → create PR      │                    │ → create PR      │
└──────────────────┘                    └──────────────────┘
         │                                       │
         └───────────────┬───────────────────────┘
                         ▼
              ┌──────────────────┐
              │   GitHub PRs     │
              │  Ready to Merge  │
              └──────────────────┘
```

---

## 8. Flowchart: Issue to Implementation

### Simplified Visual Flow

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    PARALLEL ADW WORKFLOW EXECUTION                          │
└─────────────────────────────────────────────────────────────────────────────┘

                    ┌───────────────────┐
                    │  User Creates     │
                    │  GitHub Issues    │
                    │   #5 and #6       │
                    └─────────┬─────────┘
                              │
              ┌───────────────┴───────────────┐
              ▼                               ▼
    ┌─────────────────┐             ┌─────────────────┐
    │   Terminal 1    │             │   Terminal 2    │
    │ uv run adw_     │             │ uv run adw_     │
    │ sdlc_iso.py 5   │             │ sdlc_iso.py 6   │
    └────────┬────────┘             └────────┬────────┘
             │                               │
             ▼                               ▼
    ┌─────────────────┐             ┌─────────────────┐
    │ ClaudeStartup   │             │ ClaudeStartup   │
    │ Lock Acquired   │◄───────────►│ Lock Waiting    │
    │ (3-5s delay)    │             │ (retry loop)    │
    └────────┬────────┘             └────────┬────────┘
             │                               │
             ▼                               ▼
    ┌─────────────────┐             ┌─────────────────┐
    │ Phase 1: PLAN   │             │ Phase 1: PLAN   │
    │ • Fetch issue   │             │ • Fetch issue   │
    │ • Classify      │             │ • Classify      │
    │ • Create branch │             │ • Create branch │
    │ • Create wktree │             │ • Create wktree │
    │ • Generate plan │             │ • Generate plan │
    └────────┬────────┘             └────────┬────────┘
             │                               │
             ▼                               ▼
    ┌─────────────────┐             ┌─────────────────┐
    │ trees/79447884  │             │ trees/da3a30ce  │
    │ Port: 9101/9201 │             │ Port: 9102/9202 │
    └────────┬────────┘             └────────┬────────┘
             │                               │
             ▼                               ▼
    ┌─────────────────┐             ┌─────────────────┐
    │ Phase 2: BUILD  │             │ Phase 2: BUILD  │
    │ • /implement    │             │ • /implement    │
    │ • Code changes  │             │ • Code changes  │
    │ • Commit        │             │ • Commit        │
    └────────┬────────┘             └────────┬────────┘
             │                               │
             ▼                               ▼
    ┌─────────────────┐             ┌─────────────────┐
    │ Phase 3: TEST   │             │ Phase 3: TEST   │
    │ • Run tests     │             │ • Run tests     │
    │ • Fix if needed │             │ • Fix if needed │
    └────────┬────────┘             └────────┬────────┘
             │                               │
             ▼                               ▼
    ┌─────────────────┐             ┌─────────────────┐
    │ Phase 4: REVIEW │             │ Phase 4: REVIEW │
    │ • Code review   │             │ • Code review   │
    │ • Apply patches │             │ • Apply patches │
    └────────┬────────┘             └────────┬────────┘
             │                               │
             ▼                               ▼
    ┌─────────────────┐             ┌─────────────────┐
    │ Phase 5: DOCS   │             │ Phase 5: DOCS   │
    │ • Generate docs │             │ • Generate docs │
    │ • Track KPIs    │             │ • Track KPIs    │
    └────────┬────────┘             └────────┬────────┘
             │                               │
             ▼                               ▼
    ┌─────────────────┐             ┌─────────────────┐
    │ Create PR #X    │             │ Create PR #Y    │
    │ for Issue #5    │             │ for Issue #6    │
    └────────┬────────┘             └────────┬────────┘
             │                               │
             └───────────────┬───────────────┘
                             ▼
                  ┌──────────────────┐
                  │  Both PRs Ready  │
                  │  for Code Review │
                  │  and Merging     │
                  └──────────────────┘
```

### State Transitions

```
┌────────────────────────────────────────────────────────────────────────────┐
│                      adw_state.json Transitions                             │
└────────────────────────────────────────────────────────────────────────────┘

Initial State (after ensure_adw_id):
{
  "adw_id": "79447884",
  "issue_number": "5"
}
            │
            ▼
After Classification:
{
  "adw_id": "79447884",
  "issue_number": "5",
  "issue_class": "/feature"
}
            │
            ▼
After Branch Generation:
{
  "adw_id": "79447884",
  "issue_number": "5",
  "issue_class": "/feature",
  "branch_name": "feat-issue-5-adw-79447884-expand-drag-drop-zone"
}
            │
            ▼
After Worktree Creation:
{
  "adw_id": "79447884",
  "issue_number": "5",
  "issue_class": "/feature",
  "branch_name": "feat-issue-5-adw-79447884-expand-drag-drop-zone",
  "worktree_path": "C:\\...\\trees\\79447884",
  "backend_port": 9101,
  "frontend_port": 9201
}
            │
            ▼
After Planning Complete:
{
  "adw_id": "79447884",
  "issue_number": "5",
  "issue_class": "/feature",
  "branch_name": "feat-issue-5-adw-79447884-expand-drag-drop-zone",
  "worktree_path": "C:\\...\\trees\\79447884",
  "backend_port": 9101,
  "frontend_port": 9201,
  "plan_file": "specs/issue-5-adw-79447884-sdlc_planner-expand-drag-drop-zone.md",
  "all_adws": ["adw_plan_iso"]
}
            │
            ▼
Final State (after all phases):
{
  "adw_id": "79447884",
  "issue_number": "5",
  "issue_class": "/feature",
  "branch_name": "feat-issue-5-adw-79447884-expand-drag-drop-zone",
  "worktree_path": "C:\\...\\trees\\79447884",
  "backend_port": 9101,
  "frontend_port": 9201,
  "plan_file": "specs/issue-5-adw-79447884-...",
  "model_set": "base",
  "all_adws": [
    "adw_plan_iso",
    "adw_build_iso",
    "adw_test_iso",
    "adw_review_iso",
    "adw_document_iso"
  ]
}
```

---

## 9. Summary: Parallel Issue Implementation

### What We Achieved

By running GitHub issues #5 and #6 in parallel, we demonstrated:

| Aspect | Achievement |
|--------|-------------|
| **Parallel Execution** | Two complete SDLC workflows running simultaneously |
| **Complete Isolation** | Each issue in its own git worktree with unique ports |
| **No Conflicts** | Changes to Issue #5 didn't affect Issue #6 and vice versa |
| **Windows Compatibility** | Fixed CSPRNG race condition with ClaudeStartupLock |
| **Automated Pipeline** | Full SDLC: Plan → Build → Test → Review → Document |

### Key Benefits

1. **Time Savings**: Two features developed in parallel instead of sequentially
2. **Risk Isolation**: A failure in one workflow doesn't affect the other
3. **Resource Efficiency**: Each worktree has dedicated ports, no conflicts
4. **Audit Trail**: Complete logging in `agents/<adw_id>/` for each workflow
5. **Reproducibility**: State files allow resuming interrupted workflows

### Technical Highlights

```
┌─────────────────────────────────────────────────────────────┐
│                    Architecture Summary                      │
├─────────────────────────────────────────────────────────────┤
│ Component          │ Technology                              │
├─────────────────────────────────────────────────────────────┤
│ Workflow Engine    │ Python + uv (fast package manager)     │
│ AI Agent           │ Claude Code CLI with slash commands    │
│ Isolation          │ Git Worktrees                          │
│ State Management   │ JSON files (adw_state.json)            │
│ Port Allocation    │ Deterministic hash-based (9100-9114)   │
│ Concurrency Lock   │ File-based mutex (Windows compatible)  │
│ Version Control    │ Git with automatic branch creation     │
│ CI/CD Integration  │ GitHub Issues → PRs                    │
└─────────────────────────────────────────────────────────────┘
```

### Commands Reference

```bash
# Run complete SDLC for a single issue
uv run adw_sdlc_iso.py <issue-number>

# Run specific phases
uv run adw_plan_iso.py <issue-number>     # Planning only
uv run adw_build_iso.py <issue-number>    # Build only
uv run adw_test_iso.py <issue-number>     # Testing only
uv run adw_review_iso.py <issue-number>   # Review only
uv run adw_document_iso.py <issue-number> # Documentation only

# Cleanup
./scripts/cleanup_worktrees.ps1           # Remove all worktrees
./scripts/purge_tree.ps1 <adw-id>         # Remove specific worktree
```

### Conclusion

The ADW (Agentic Development Workflow) system successfully enables **parallel development** of multiple GitHub issues by:

1. Creating isolated git worktrees for each issue
2. Allocating unique ports to prevent service conflicts
3. Using file-based locking to prevent Windows-specific race conditions
4. Maintaining separate state files for workflow tracking
5. Automating the complete SDLC pipeline with Claude Code

This approach mirrors real-world development teams where multiple developers work on different features simultaneously, demonstrating the power of AI-assisted development workflows.

---

*Document generated on: January 2026*
*ADW System Version: tac-7*
