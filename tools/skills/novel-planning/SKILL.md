---
name: novel-planning
description: Generate novel outline and world-building using the interstellar-novelist agent. Creates outline.md and worldview.md files.
---

# Novel Planning Assistant

Use the interstellar-novelist agent to generate a comprehensive novel outline and world-building, then save them to files.

## Usage

`/novel-planning [novel concept description]`

## Workflow

1. Understand the user's novel concept/prompt
2. Call the interstellar-novelist agent to generate:
   - **Novel Outline**: story premise/logline, main characters and their arcs, chapter-by-chapter breakdown, key plot points and conflicts, themes
   - **World-building**: setting (time, place, social/political context), rules of the world, cultures, factions, history, geography
3. Save the outline as `outline.md`
4. Save the world-building as `worldview.md`

## Agent Prompt Template

```
Please create a complete novel outline and world-building based on this concept:

【$ARGUMENTS】

Please provide:
1. Novel outline - including story premise, main characters and their arcs, chapter breakdown, key conflicts, and themes
2. World-building - including era/setting, geographical context, social/political structure, cultural elements, and historical background

Please develop this thoroughly to support a complete novel.
```

## Output Files

- `outline.md` - Novel outline
- `worldview.md` - World-building details
