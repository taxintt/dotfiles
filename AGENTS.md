Please also reference the following documents as needed. In this case, `@` stands for the project root directory.

<Documents>
  <Document>
    <Path>@.codex/memories/go-cli.md</Path>
    <Description>Project overview and general development guidelines for CLI Application in Go</Description>
    <FilePatterns>**/*</FilePatterns>
  </Document>
</Documents>

# Additional Conventions Beyond the Built-in Functions

As this project's AI coding tool, you must follow the additional conventions below, in addition to the built-in functions.# Project Overview

## General Guidelines

- Follow consistent naming conventions
- Write self-documenting code with clear variable and function names
- Prefer composition over inheritance
- Use meaningful comments for complex business logic

## Code Style

- Use 2 spaces for indentation
- Use semicolons
- Use double quotes for strings
- Use trailing commas in multi-line objects and arrays

## Architecture Principles

- Organize code by feature, not by file type
- Keep related files close together
- Use dependency injection for better testability
- Implement proper error handling
- Follow single responsibility principle