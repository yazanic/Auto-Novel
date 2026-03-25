# Auto-Novel Quick Start Guide

## Setup in 3 Steps

### Step 1: Create Configuration File

Copy the example configuration and customize it for your environment:

```bash
# Copy example config
cp auto-novel.config.json.example auto-novel.config.json

# Edit with your settings
nano auto-novel.config.json
```

**Minimum required changes:**
- Verify MCP server address in `scrapling_mcp.host`
- Confirm paths in `paths` section match your project structure

### Step 2: Verify Configuration

Test that your configuration loads correctly:

```bash
# Test configuration loader
python tools/skills/auto-novel/config_loader.py
```

Expected output:
```
[OK] Configuration loaded from auto-novel.config.json
=== Configuration Summary ===
{
  ...
}
MCP Endpoint: http://your-host:port/endpoint
```

### Step 3: Start Auto-Novel

Run the auto-novel command:

```
/auto-novel
```

## What Happens Next?

The auto-novel system will:

1. **Load your configuration** from `auto-novel.config.json`
2. **Check environment** (directories, agents, MCP server)
3. **Configure MCP server** (adds scrapling if needed)
4. **Fetch creative inspiration** from news sources
5. **Initialize progress tracking** in `.supervisor/progress.json`
6. **Launch novel-supervisor agent** to coordinate the creation process

## Common First-Time Issues

### Issue: "Configuration file not found"

**Solution:** Make sure `auto-novel.config.json` is in your project root directory.

```bash
# Verify file exists
ls -la auto-novel.config.json

# If not found, create it from example
cp auto-novel.config.json.example auto-novel.config.json
```

### Issue: "MCP connection failed"

**Solution:** Verify your MCP server is running and accessible.

```bash
# Test MCP endpoint (replace with your values)
curl http://192.168.1.120:8000/mcp

# If server is down, start it or update config with correct address
nano auto-novel.config.json
```

### Issue: "Directory not found"

**Solution:** Create required directories before running.

```bash
# Create required directories
mkdir -p docs/superpowers/agents
mkdir -p docs/superpowers/progress
mkdir -p tools/agents
```

## Next Steps

Once auto-novel is running:

- **Monitor progress:** Check `.supervisor/progress.json` for status
- **Resume if interrupted:** Use `/auto-novel --continue`
- **Start fresh:** Use `/auto-novel --force`
- **View documentation:** Read `CONFIG.md` for detailed configuration options

## Need Help?

- **Configuration details:** See `CONFIG.md`
- **Full documentation:** See `tools/skills/auto-novel/SKILL.md`
- **Test your setup:** Run `bash test_config.sh`
