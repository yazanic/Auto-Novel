#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Configuration loader for auto-novel system.

Loads configuration from auto-novel.config.json with fallback to environment
variables and hardcoded defaults.

Priority: config.json > environment variables > hardcoded defaults
"""

import json
import os
import sys
from pathlib import Path
from typing import Dict, Any

# Set UTF-8 encoding for Windows console
if sys.platform == "win32":
    import io
    sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8')
    sys.stderr = io.TextIOWrapper(sys.stderr.buffer, encoding='utf-8')


def load_config(config_file: str = "auto-novel.config.json") -> Dict[str, Any]:
    """
    Load configuration from JSON file with fallback to environment variables.

    Args:
        config_file: Path to configuration file (default: auto-novel.config.json)

    Returns:
        Dictionary containing merged configuration
    """
    config = {
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

    # Override with environment variables FIRST (lower priority than config file)
    config["scrapling_mcp"]["host"] = os.getenv(
        "AUTO_NOVEL_MCP_HOST",
        config["scrapling_mcp"]["host"]
    )
    config["scrapling_mcp"]["port"] = int(os.getenv(
        "AUTO_NOVEL_MCP_PORT",
        str(config["scrapling_mcp"]["port"])
    ))
    config["scrapling_mcp"]["endpoint"] = os.getenv(
        "AUTO_NOVEL_MCP_ENDPOINT",
        config["scrapling_mcp"]["endpoint"]
    )

    config["paths"]["supervisor_dir"] = os.getenv(
        "AUTO_NOVEL_SUPERVISOR_DIR",
        config["paths"]["supervisor_dir"]
    )
    config["paths"]["agents_dir"] = os.getenv(
        "AUTO_NOVEL_AGENTS_DIR",
        config["paths"]["agents_dir"]
    )
    config["paths"]["progress_dir"] = os.getenv(
        "AUTO_NOVEL_PROGRESS_DIR",
        config["paths"]["progress_dir"]
    )

    config["news_source"]["url"] = os.getenv(
        "AUTO_NOVEL_NEWS_URL",
        config["news_source"]["url"]
    )
    config["news_source"]["selector"] = os.getenv(
        "AUTO_NOVEL_NEWS_SELECTOR",
        config["news_source"]["selector"]
    )

    # Try to load from JSON file (HIGHEST priority - overrides env vars and defaults)
    config_path = Path(config_file)
    if config_path.exists():
        try:
            with open(config_path, 'r', encoding='utf-8') as f:
                file_config = json.load(f)

            # Merge file config with current config (file config has highest priority)
            if "scrapling_mcp" in file_config:
                config["scrapling_mcp"].update(file_config["scrapling_mcp"])
            if "paths" in file_config:
                config["paths"].update(file_config["paths"])
            if "news_source" in file_config:
                config["news_source"].update(file_config["news_source"])

            print(f"[OK] Configuration loaded from {config_file}")
        except json.JSONDecodeError as e:
            print(f"[WARN] Failed to parse {config_file}: {e}")
            print("  Using environment variables or defaults")
        except Exception as e:
            print(f"[WARN] Failed to load {config_file}: {e}")
            print("  Using environment variables or defaults")
    else:
        print(f"[WARN] Configuration file not found: {config_file}")
        print("  Using environment variables or defaults")

    return config


def export_env_vars(config: Dict[str, Any]) -> None:
    """
    Export configuration as environment variables for shell scripts.

    Args:
        config: Configuration dictionary
    """
    print("\n# Configuration as environment variables:")
    print(f"export AUTO_NOVEL_MCP_HOST=\"{config['scrapling_mcp']['host']}\"")
    print(f"export AUTO_NOVEL_MCP_PORT=\"{config['scrapling_mcp']['port']}\"")
    print(f"export AUTO_NOVEL_MCP_ENDPOINT=\"{config['scrapling_mcp']['endpoint']}\"")
    print(f"export AUTO_NOVEL_SUPERVISOR_DIR=\"{config['paths']['supervisor_dir']}\"")
    print(f"export AUTO_NOVEL_AGENTS_DIR=\"{config['paths']['agents_dir']}\"")
    print(f"export AUTO_NOVEL_PROGRESS_DIR=\"{config['paths']['progress_dir']}\"")
    print(f"export AUTO_NOVEL_NEWS_URL=\"{config['news_source']['url']}\"")
    print(f"export AUTO_NOVEL_NEWS_SELECTOR=\"{config['news_source']['selector']}\"")


def get_mcp_endpoint(config: Dict[str, Any]) -> str:
    """
    Build MCP endpoint URL from configuration.

    Args:
        config: Configuration dictionary

    Returns:
        MCP endpoint URL
    """
    mcp = config["scrapling_mcp"]
    return f"http://{mcp['host']}:{mcp['port']}{mcp['endpoint']}"


def main():
    """Main entry point for testing configuration loader."""
    import sys

    # Allow custom config file path as argument
    config_file = sys.argv[1] if len(sys.argv) > 1 else "auto-novel.config.json"

    print("=== Auto-Novel Configuration Loader ===\n")
    config = load_config(config_file)

    print("\n=== Configuration Summary ===")
    print(json.dumps(config, indent=2))

    print(f"\nMCP Endpoint: {get_mcp_endpoint(config)}")

    export_env_vars(config)


if __name__ == "__main__":
    main()
