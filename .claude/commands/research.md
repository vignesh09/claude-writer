# Research Command

Use this command to develop and refine content ideas before writing.

## Usage
`/research [topic]`

## What This Command Does
1. Explores the topic from multiple angles
2. Identifies key insights and unique perspectives  
3. Suggests compelling hooks and storylines
4. Researches supporting data and examples
5. Outlines potential article structure

## Process
- **Archive Check**: FIRST, check `research/archive/INDEX.md` to avoid re-researching published topics
- **Priority Source Check**: Start with sources in @context/research-sources.md - check these FIRST
- **Gap Analysis**: Identify what perspectives are missing from trusted source coverage
- **Trend Investigation**: Check Google Trends, industry reports, social media discussions
- **Counter-narrative Search**: Look for contrarian views or unexplored angles
- **Data Mining**: Find recent studies, surveys, or statistics to support points
- **Expert Voices**: Identify who else is talking about this and what they're missing
- **Audience Pulse**: Research what questions people are actually asking about this topic
- **Broader Web Search**: Expand beyond priority sources for comprehensive coverage

### Archive Exclusion Rules
When researching a topic:
1. Read `research/archive/INDEX.md` to see what's been covered
2. If the exact topic exists in archive:
   - Inform the user it's already been published
   - Suggest a fresh angle or related unexplored topic
   - Only proceed if user confirms they want to re-research
3. If a related topic exists:
   - Note what angle was previously covered
   - Focus on different aspects or new developments
   - Ensure the new research brings fresh perspective

## Output
Provides a research brief with:
- **Trend Context**: What's currently happening in this space
- **Unique Angle**: Your differentiated perspective vs. existing content
- **Core Thesis**: Main argument supported by fresh data/insights
- **Supporting Evidence**: Recent examples, studies, expert quotes
- **Audience Questions**: What people are actually asking about this topic
- **Platform Hooks**: Compelling angles for each repurposing agent
- **Contrarian Elements**: Unexpected or challenging viewpoints to explore

## File Management
After completing the research, automatically save the brief to:
- **File Location**: `research/research-brief-[topic-slug]-[YYYY-MM-DD].md`
- **File Format**: Markdown with clear sections and headers
- **Naming Convention**: Use lowercase, hyphenated topic slug and current date

### Metadata Header
Include at the top of each research brief:
```markdown
---
status: draft
created_date: [YYYY-MM-DD]
topic: [Topic Name]
archived: false
---
```

Example: `research/research-brief-remote-work-productivity-2024-01-15.md`

This ensures all research briefs are systematically stored and easily referenced for future writing projects.

## Lifecycle
Research briefs follow this lifecycle:
1. **Created**: Saved to `research/` with `status: draft`
2. **Used**: Article written based on research
3. **Published**: Moved to `research/archive/` when `/publish` is run
4. **Excluded**: Future research checks archive to avoid duplication