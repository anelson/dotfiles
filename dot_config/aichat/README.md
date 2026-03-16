# AIChat Configuration

This directory contains the configuration for AIChat, supporting both OpenAI and Anthropic Claude APIs.

## Environment Variables

API keys are stored in a `.env` file in this directory, and are intentionally not under source control. Create this file
with the following format:

```
OPENAI_API_KEY=your_openai_api_key_here
CLAUDE_API_KEY=your_claude_api_key_here
```

Replace `your_openai_api_key_here` and `your_claude_api_key_here` with your actual API keys from OpenAI and Anthropic respectively.

## Security Note

- The `.env` file is included in `.gitignore` to prevent accidental commit of sensitive information
- Never commit your actual API keys to version control
- Keep your API keys secure and do not share them

## Setup

1. Create a new `.env` file in this directory
2. Add your API keys in the format shown above
3. Make sure the `.env` file is properly loaded by your application

## Requirements

- OpenAI API key (for GPT models)
- Anthropic API key (for Claude models)
