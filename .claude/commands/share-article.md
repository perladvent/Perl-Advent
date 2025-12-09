---
description: Generate social media summaries for an article
arguments:
  - name: day
    description: Day of December (1-25) or full date (YYYY-MM-DD)
    required: true
  - name: year
    description: Year (defaults to 2025)
    required: false
---

# Social Media Summary Generator

Generate social media share text for a Perl Advent Calendar article.

## Step 1: Identify the Article

1. Extract the day and year from arguments:
   - If `day` is a number (1-25), use it as the December day
   - If `day` is a full date (YYYY-MM-DD), parse it to get the year and day
   - If `year` argument is provided, use it; otherwise default to 2025
   - Construct the article filename: `{YEAR}/articles/{YEAR}-12-{DAY}.pod`
     - Ensure day is zero-padded (e.g., "08" not "8")

2. Read the article file from `{YEAR}/articles/{YEAR}-12-{DAY}.pod`

3. If the article doesn't exist in `articles/`, check `incoming/` directory as a fallback

## Step 2: Extract Article Information

From the article file, extract:

1. **Author**: First line should be `Author: Name <email>`
   - Extract just the name (before the email)
   - Extract first name for use in the summary

2. **Title**: Second line should be `Title: Article Title`
   - Extract the full title

3. **Topic**: Third line should be `Topic: Module::Name`
   - Extract the module name(s)
   - If multiple modules, use the primary/first one

4. **Content Summary**: Read the first few paragraphs of actual content (after headers)
   - Identify what the article is about
   - Focus on the practical use case or problem being solved
   - Keep it factual and brief (one sentence)

## Step 3: Generate Summary Text

Create a brief, factual summary following this pattern:

**Template:**
"On day {DAY} of The Perl Advent Calendar {FIRST_NAME} {LAST_NAME} shows us how {BRIEF_SUMMARY}."

**Guidelines for the summary:**
- Use "shows us how" or "demonstrates how" or "explains how" depending on context
- Focus on the practical application or use case
- Mention the module name naturally in the summary
- Be specific but concise (one sentence)
- NO clickbait language - be direct and informative
- NO superlatives like "amazing", "incredible", "must-read"

**Example summaries:**
- "shows us how Santa's workshop uses Data::Random::Contact to generate realistic test data"
- "demonstrates how to parse complex log files with Parse::Syslog"
- "explains how Mojo::UserAgent simplifies HTTP client operations"

## Step 4: Choose Holiday Emojis

Select exactly TWO holiday-themed emojis from this curated list:

**Christmas/Winter:** 🎄 🎅 ⛄ ❄️ 🎁 🔔 ⭐ 🕯️ 🦌 🤶 🧑‍🎄

**Coding/Tech:** 💻 ⌨️ 🖥️ 📝 🐪 (camel for Perl) 🎯 ⚙️ 🔧

**Combine one from each category** or choose two that best fit the article's theme:
- For data/testing articles: 🎅 ⌨️ or 🎄 💻
- For web/network articles: 🌐 🎁 or 🔔 💻
- For system/automation: ⚙️ 🎄 or 🤖 ❄️
- Default combination: 🎅 ⌨️

## Step 5: Generate Share Text

### Basic Share Text

Format:
```
On day {DAY} of The Perl Advent Calendar {FIRST_NAME} {LAST_NAME} {SUMMARY}. {EMOJI1}{EMOJI2}

https://perladvent.org/{YEAR}/{YEAR}-12-{DAY_PADDED}.html
```

**Example:**
```
On day 8 of The Perl Advent Calendar Charlie Gonzalez shows us how Santa's workshop uses Data::Random::Contact to generate realistic test data. 🎅⌨️

https://perladvent.org/2025/2025-12-08.html
```

### Mastodon Share Text

Same as basic share text, but append two newlines and tags:

Format:
```
On day {DAY} of The Perl Advent Calendar {FIRST_NAME} {LAST_NAME} {SUMMARY}. {EMOJI1}{EMOJI2}

https://perladvent.org/{YEAR}/{YEAR}-12-{DAY_PADDED}.html

#perl @perl@a.gup.pe @tag-perl@relay.fedi.buzz #programming
```

**Example:**
```
On day 8 of The Perl Advent Calendar Charlie Gonzalez shows us how Santa's workshop uses Data::Random::Contact to generate realistic test data. 🎅⌨️

https://perladvent.org/2025/2025-12-08.html

#perl @perl@a.gup.pe @tag-perl@relay.fedi.buzz #programming
```

## Step 6: Display Results

Present both versions clearly formatted:

```
📱 BASIC SHARE TEXT
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[Basic share text here]

🐘 MASTODON SHARE TEXT
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[Mastodon share text here]
```

Also display the character counts:
- Basic text: X characters
- Mastodon text: Y characters

## Guidelines

- **Be accurate**: Extract real information from the article, don't make things up
- **Be factual**: No marketing speak or clickbait
- **Be concise**: The summary should be one clear sentence
- **Be specific**: Mention what problem is being solved or what use case is shown
- **Check the URL format**: Ensure it matches the pattern `https://perladvent.org/YYYY/YYYY-MM-DD.html`

Begin generating the social media summary for day {day} (year: {year}).
