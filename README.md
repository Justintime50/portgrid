# PortGrid

> The Grid. A digital frontier...

PortGrid is an agentic harness for Claude or Copilot to port code from one project to another.

[![CI](https://github.com/Justintime50/portgrid/workflows/ci/badge.svg)](https://github.com/Justintime50/portgrid/actions)
[![Version](https://img.shields.io/github/v/tag/justintime50/portgrid)](https://github.com/justintime50/portgrid/releases)
[![Licence](https://img.shields.io/github/license/justintime50/portgrid)](LICENSE)

PortGrid opens a dedicated tmux session followed by a window for every project your code needs to be ported to. In my workflows at EasyPost, I'd write code once in Python and use PortGrid to port that to our other six client libraries that were different languages. I could then orchestrate the work of six AI agents at once to ensure consistency across the board while not needing to focus on the boilerplate code.

## Install

```sh
# Setup the tap
brew tap justintime50/formulas

# Install portgrid
brew install portgrid
```

## Usage

Store all the repos you want your code ported to in the `parent_dir`, write a prompt to shape how your agent will port your code (see example), and optionally specify which agent to use (`claude` - default, or `copilot`).

```sh
# Basic Usage
portgrid path/to/parent_dir path/to/prompt.md <agent>

# Agents accept params
portgrid path/to/parent_dir path/to/prompt.md 'copilot --model gpt-4.1 --yolo'
```

## Known Issues

Copilot startup is incredibly slow compared to Claude, to combat that, we inject the prompt with a delayed timer to ensure Copilot is ready to receive the input. If using Copilot, you will notice a delay in the agents initial response due to this.
