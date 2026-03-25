---
name: auto-novel
description: "Fully automated novel creation system entry point. Handles environment checks, MCP management, inspiration retrieval, progress file initialization, and launches the novel-supervisor agent for automated novel writing. Supports checkpoint recovery and can resume from any stage."
---

# Auto-Novel - Fully Automated Novel Creation System

The entry point skill for the fully automated novel creation system, responsible for environment preparation, progress management, and launching the creation workflow.

## Usage

`/auto-novel [--continue] [--force]`

**Examples:**
- `/auto-novel` - Start a new automated creation workflow
- `/auto-novel --continue` - Resume from the last interruption point
- `/auto-novel --force` - Force restart (clears existing progress)

## Configuration

The auto-novel system supports three levels of configuration (in priority order):

1. **auto-novel.config.json** (highest priority)
2. **Environment variables**
3. **Hardcoded defaults** (fallback)

### Configuration File

Create `auto-novel.config.json` in your project root:

```json
{
  "scrapling_mcp": {
    "host": "192.168.1.120",
    "port": 8000,
    "endpoint": "/mcp"
  },
  "paths": {
    "supervisor_dir": ".supervisor",
    "agents_dir": "tools/agents",
    "progress_dir": "docs/superpowers/progress"
  },
  "news_source": {
    "url": "https://news.sina.com.cn/world/",
    "selector": "div#subShow1 h2"
  }
}
```

An example configuration file is provided at `auto-novel.config.json.example`.

### Environment Variables (Optional)

If config file is not found, environment variables will be used:

```bash
# MCP server configuration
export AUTO_NOVEL_MCP_HOST="${AUTO_NOVEL_MCP_HOST:-192.168.1.120}"
export AUTO_NOVEL_MCP_PORT="${AUTO_NOVEL_MCP_PORT:-8000}"
export AUTO_NOVEL_MCP_ENDPOINT="${AUTO_NOVEL_MCP_ENDPOINT:-/mcp}"

# Paths
export AUTO_NOVEL_SUPERVISOR_DIR="${AUTO_NOVEL_SUPERVISOR_DIR:-.supervisor}"
export AUTO_NOVEL_AGENTS_DIR="${AUTO_NOVEL_AGENTS_DIR:-tools/agents}"
export AUTO_NOVEL_PROGRESS_DIR="${AUTO_NOVEL_PROGRESS_DIR:-docs/superpowers/progress}"

# News source
export AUTO_NOVEL_NEWS_URL="${AUTO_NOVEL_NEWS_URL:-https://news.sina.com.cn/world/}"
export AUTO_NOVEL_NEWS_SELECTOR="${AUTO_NOVEL_NEWS_SELECTOR:-div#subShow1 h2}"
```

## Workflow

### Step 1: Configuration File Loading

Before starting the workflow, load configuration from `auto-novel.config.json`:

```bash
# Load configuration using Python helper script
python tools/skills/auto-novel/config_loader.py

# Or load it programmatically in shell
CONFIG=$(python -c "
import sys
sys.path.insert(0, 'tools/skills/auto-novel')
from config_loader import load_config, export_env_vars
config = load_config()
export_env_vars(config)
print(config['scrapling_mcp']['host'])
")

# Set environment variables from config
eval $(python tools/skills/auto-novel/config_loader.py)

echo "✓ Configuration loaded"
```

**Configuration priority:**
1. Values from `auto-novel.config.json` (if exists)
2. Environment variables (if set)
3. Hardcoded defaults (fallback)

**Configuration values used throughout:**
- `$AUTO_NOVEL_MCP_HOST`, `$AUTO_NOVEL_MCP_PORT`, `$AUTO_NOVEL_MCP_ENDPOINT` - scrapling MCP connection
- `$AUTO_NOVEL_SUPERVISOR_DIR` - Supervisor working directory
- `$AUTO_NOVEL_AGENTS_DIR` - Agents directory
- `$AUTO_NOVEL_PROGRESS_DIR` - Progress files directory
- `$AUTO_NOVEL_NEWS_URL`, `$AUTO_NOVEL_NEWS_SELECTOR` - News source for inspiration

### Step 2: Environment Check

After configuration is loaded, verify the working environment is complete:

```bash
# Check if required directories exist
ls -la docs/superpowers/agents/
ls -la docs/superpowers/progress/

# Check if novel-supervisor agent is available
ls -la tools/agents/novel-supervisor/

# Check MCP server configuration
cat ~/.claude/mcp_config.json | grep scrapling
```

**Verification requirements:**
- `docs/superpowers/agents/` directory exists
- `docs/superpowers/progress/` directory exists
- `tools/agents/novel-supervisor/` directory exists
- scrapling MCP is configured (will be added in next step if not present)

### Step 3: MCP Management

Check and add the scrapling MCP server if not yet configured:

```bash
# Build MCP endpoint from environment variables
MCP_ENDPOINT="http://${AUTO_NOVEL_MCP_HOST}:${AUTO_NOVEL_MCP_PORT}${AUTO_NOVEL_MCP_ENDPOINT}"

# Check if scrapling MCP exists, add if not
if ! grep -q "scrapling" ~/.claude/mcp_config.json 2>/dev/null; then
  echo "scrapling MCP not configured. Adding now..."

  # Use claude mcp add command to add scrapling
  claude mcp add --transport http scrapling "$MCP_ENDPOINT"

  if [ $? -eq 0 ]; then
    echo "✓ scrapling MCP added successfully"
  else
    echo "✗ Failed to add scrapling MCP. Please add manually:"
    echo "  claude mcp add --transport http scrapling $MCP_ENDPOINT"
    exit 1
  fi
else
  echo "✓ scrapling MCP is already configured"
fi
```

**scrapling MCP purpose:**
- Fetch news from sina.com.cn as creative inspiration
- Support web content scraping and parsing
- Provide real-world materials for novel-planning

### Step 4: Get Creative Inspiration

Use the scrapling MCP to fetch today's hot topics from Sina News as inspiration for novel creation:

```bash
# Create .supervisor directory
mkdir -p "$AUTO_NOVEL_SUPERVISOR_DIR"

# Use MCP tool to fetch news (not CLI command)
# This should be called via MCP tool interface, not as shell command
# The skill should invoke the scrapling MCP tool with appropriate parameters

# For now, create a placeholder inspiration file
cat > "$AUTO_NOVEL_SUPERVISOR_DIR/inspiration.md" << 'EOF'
# Creative Inspiration

*Note: In actual implementation, this content should be fetched using the scrapling MCP tool.*

Today's inspiration will be extracted from current events and adapted into fictional storytelling.
EOF

echo "✓ Inspiration file created: $AUTO_NOVEL_SUPERVISOR_DIR/inspiration.md"
```

**MCP Tool Invocation (for actual implementation):**

When this skill is executed, the system should invoke the scrapling MCP tool using the proper MCP interface format:

```python
# Example MCP tool invocation (pseudo-code)
{
  "tool": "scrapling",
  "method": "fetch",
  "parameters": {
    "url": "$AUTO_NOVEL_NEWS_URL",
    "css_selector": "$AUTO_NOVEL_NEWS_SELECTOR",
    "output": "$AUTO_NOVEL_SUPERVISOR_DIR/inspiration.md"
  }
}
```

**Inspiration extraction requirements:**
- Select social, technological, and cultural news
- Extract core conflicts that can be dramatically adapted
- Generate concise inspiration descriptions (100-200 words)

**Output example:**
```
Today's Creative Inspiration:
[Tech Ethics Conflict] A tech company announces an AI system that can read human emotions,
sparking intense social debate about privacy boundaries. The protagonist, as an ethics reviewer,
discovers a shocking secret hidden behind the system...
```

### Step 5: Initialize Progress File

Create or update the creation progress tracking file:

```bash
# Create progress file
PROGRESS_FILE="$AUTO_NOVEL_SUPERVISOR_DIR/progress.json"

# Initialize progress structure (if it doesn't exist)
if [ ! -f "$PROGRESS_FILE" ]; then
  cat > "$PROGRESS_FILE" << 'EOF'
{
  "started_at": "2026-03-25T10:00:00Z",
  "last_updated": "2026-03-25T10:00:00Z",
  "version": "1.0",
  "status": "initialized",
  "current_step": "supervisor_launch",
  "retry_count": 0,
  "max_retries": 3,
  "current_chapter": 0,
  "chapters_completed": [],
  "estimated_total_chapters": 20,
  "story_complete": false,
  "inspiration_file": ".supervisor/inspiration.md",
  "story_frame_file": ".supervisor/story-frame.md",
  "outline_file": "outline.md",
  "worldview_file": "worldview.md",
  "next_chapter_suggestions": {
    "plot_points": [],
    "character_development": [],
    "recommended_prompt": null,
    "potential_challenges": []
  },
  "error_log": [],
  "last_error": null,
  "decision_history": []
}
EOF
  echo "✓ Progress file initialized: $PROGRESS_FILE"
else
  echo "✓ Progress file exists: $PROGRESS_FILE"
  # Read current progress for checkpoint recovery
  python -c "import json, sys; print(json.dumps(json.load(open('$PROGRESS_FILE')), indent=2))"
fi
```

**Progress file field descriptions:**
- `started_at`: Start time
- `last_updated`: Last update time
- `version`: Version number
- `status`: Current status (initialized, generating_story_frame, generating_outline, writing_chapters, completed, error)
- `current_step`: Current execution step
- `retry_count`: Current retry count
- `max_retries`: Maximum retry attempts
- `current_chapter`: Current chapter number
- `chapters_completed`: List of completed chapters
- `estimated_total_chapters`: Estimated total chapter count
- `story_complete`: Whether the story is complete
- `inspiration_file`: Path to creative inspiration file
- `story_frame_file`: Path to story frame file
- `outline_file`: Path to outline file
- `worldview_file`: Path to worldview file
- `next_chapter_suggestions`: Next chapter suggestions (including plot_points, character_development, recommended_prompt, potential_challenges)
- `error_log`: Error log
- `last_error`: Last error
- `decision_history`: Decision history records

### Step 6: Launch novel-supervisor Agent

Use the Agent tool to launch novel-supervisor, passing creative inspiration and current state:

```bash
# Use Agent tool to launch novel-supervisor
# Pass creative inspiration and progress state as parameters
echo "Starting novel-supervisor agent..."
```

**Agent tool invocation implementation:**

Invoke the `Agent` tool with the following parameters:

- `subagent_type`: `novel-supervisor`
- `prompt`: Include the following content
  - Creative inspiration: Read from `.supervisor/inspiration.md`
  - Current progress: Read from `.supervisor/progress.json`
  - Working directory: Current project root
  - Task requirements:
    1. If new project: Execute full planning → outline → worldview → chapter creation workflow
    2. If --continue mode: Read progress file and continue from interruption point
    3. If --force mode: Clear existing progress and restart
    4. Continuously update `.supervisor/progress.json`
    5. Report status after each major phase completion

**novel-supervisor responsibilities:**
- Coordinate workflow of various agents
- Manage creation progress and state
- Handle checkpoint recovery logic
- Call sub-agents like novel-planning, novel-chapter
- Ensure creation quality and coherence
- Evaluate story completeness and make creative decisions

### Step 7: Checkpoint Recovery Logic

Support recovery after interruption at any stage:

```bash
# Parse command line arguments
FORCE_MODE=false
CONTINUE_MODE=false

# Check parameters
while [ $# -gt 0 ]; do
  case "$1" in
    --force)
      FORCE_MODE=true
      shift
      ;;
    --continue)
      CONTINUE_MODE=true
      shift
      ;;
    *)
      shift
      ;;
  esac
done

PROGRESS_FILE="$AUTO_NOVEL_SUPERVISOR_DIR/progress.json"

# Handle --force mode
if [ "$FORCE_MODE" = true ]; then
  echo "⚠ Force mode: clearing existing progress..."

  if [ -f "$PROGRESS_FILE" ]; then
    # Backup existing progress
    cp "$PROGRESS_FILE" "$PROGRESS_FILE.backup.$(date +%Y%m%d_%H%M%S)"
    echo "✓ Previous progress backed up"
  fi

  # Delete progress file, restart fresh
  rm -f "$PROGRESS_FILE"
  echo "✓ Progress cleared. Starting fresh..."
  CONTINUE_MODE=false
fi

# Handle --continue mode
if [ "$CONTINUE_MODE" = true ]; then
  echo "📋 Resuming from previous session..."

  if [ -f "$PROGRESS_FILE" ]; then
    # Read and display current progress using Python
    echo ""
    echo "=== Current Progress ==="
    python -c "import json, sys; print(json.dumps(json.load(open('$PROGRESS_FILE')), indent=2))"
    echo ""

    # Parse current state using Python
    STATUS=$(python -c "import json; print(json.load(open('$PROGRESS_FILE'))['status'])")
    CURRENT_STEP=$(python -c "import json; print(json.load(open('$PROGRESS_FILE'))['current_step'])")

    echo "Previous status: $STATUS"
    echo "Current step: $CURRENT_STEP"

    # Decide recovery strategy based on status
    case $STATUS in
      "initialized")
        echo "→ Resuming from initialization phase..."
        # Restart supervisor
        ;;
      "generating_story_frame")
        echo "→ Resuming from story frame generation..."
        # Continue generating story frame
        ;;
      "generating_outline")
        echo "→ Resuming from outline generation..."
        # Continue generating outline
        ;;
      "writing_chapters")
        echo "→ Resuming from chapter writing phase..."
        # Continue chapter creation
        ;;
      "completed")
        echo "✓ Novel already completed!"
        echo "Use --force to start a new novel."
        exit 0
        ;;
      "error")
        echo "⚠ Previous session ended with error"
        echo "Check error_log in progress.json for details"
        # Reset retry_count, continue execution
        ;;
      *)
        echo "→ Unknown status, starting fresh..."
        ;;
    esac
  else
    echo "⚠ No progress file found. Starting fresh..."
    CONTINUE_MODE=false
  fi
fi

# If neither --continue nor --force, check for existing progress
if [ "$FORCE_MODE" = false ] && [ "$CONTINUE_MODE" = false ]; then
  if [ -f "$PROGRESS_FILE" ]; then
    EXISTING_STATUS=$(python -c "import json; print(json.load(open('$PROGRESS_FILE'))['status'])")
    if [ "$EXISTING_STATUS" != "completed" ]; then
      echo "⚠ Existing progress found (status: $EXISTING_STATUS)"
      echo "Use --continue to resume or --force to start over"
      echo "Proceeding with new session..."
    fi
  fi
fi
```

**Recovery strategies:**
- **--force mode**: Clear existing progress and restart
- **--continue mode**:
  - **initialized phase**: Restart supervisor
  - **generating_story_frame phase**: Continue generating story frame
  - **generating_outline phase**: Continue generating outline
  - **writing_chapters phase**: Continue from current_chapter
  - **completed status**: Display completion message, suggest using --force for new project
  - **error status**: Display error information, reset retry_count and continue
- **No parameters**: If incomplete progress detected, prompt user to use --continue or --force

### Step 8: Usage Instructions and Troubleshooting

#### Normal usage workflow:

1. **First time use**:
   ```
   /auto-novel
   ```
   - Automatically check environment
   - Configure MCP (if needed)
   - Get creative inspiration
   - Launch automated creation workflow

2. **Resume after interruption**:
   ```
   /auto-novel --continue
   ```
   - Read progress file
   - Continue from checkpoint
   - Avoid duplicate work

3. **Force restart**:
   ```
   /auto-novel --force
   ```
   - Backup existing progress
   - Clear progress file
   - Start creation from scratch

#### Troubleshooting:

**Problem 1: scrapling MCP not configured**
```bash
# Symptom: Prompt "scrapling MCP not configured"
# Solution: auto-novel will attempt to add automatically, if that fails, execute manually:
MCP_ENDPOINT="http://${AUTO_NOVEL_MCP_HOST}:${AUTO_NOVEL_MCP_PORT}${AUTO_NOVEL_MCP_ENDPOINT}"
claude mcp add --transport http scrapling "$MCP_ENDPOINT"
```

**Problem 2: agent file not found**
```bash
# Symptom: Prompt "novel-supervisor agent not found"
# Solution: Check tools/agents/ directory
ls -la tools/agents/novel-supervisor.md
# If not present, need to create novel-supervisor agent first
```

**Problem 3: Progress file corrupted**
```bash
# Symptom: Unable to parse progress file
# Solution: Use --force to restart
/auto-novel --force
# This will backup existing progress and restart
```

**Problem 4: Network request failed**
```bash
# Symptom: Unable to fetch news inspiration
# Solution:
# 1. Check network connection
# 2. Confirm scrapling MCP service is running at configured endpoint
# 3. Manually create .supervisor/inspiration.md and provide inspiration
```

#### Debugging tips:

```bash
# View complete progress
python -c "import json, sys; print(json.dumps(json.load(open('.supervisor/progress.json')), indent=2))"

# View creative inspiration
cat .supervisor/inspiration.md

# View story frame
cat .supervisor/story-frame.md

# Check MCP server status
cat ~/.claude/mcp_config.json | python -m json.tool
```

## Implementation Steps

1. **Environment verification**: Check all required directories and agents
2. **MCP configuration**: Ensure scrapling MCP is available
3. **Inspiration retrieval**: Extract creative materials from Sina News
4. **Progress initialization**: Create or load progress file
5. **Supervisor launch**: Invoke novel-supervisor agent
6. **State monitoring**: Track creation progress
7. **Checkpoint recovery**: Support continuation after interruption

## Output Files

- `.supervisor/progress.json` - Creation progress tracking file
- `.supervisor/inspiration.md` - Creative inspiration (fetched from Sina News)
- Console output - Real-time display of creation status and progress reports

## Dependencies

- novel-supervisor agent - Coordinates the automated novel creation workflow, manages progress, and makes creative decisions
- scrapling MCP server - Fetches news content for creative inspiration
- novel-planning agent - Generates story outlines and worldviews
- novel-chapter skill - Writes individual chapters
- logic-reviewer agent - Reviews content for quality and consistency
