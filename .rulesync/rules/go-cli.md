---
root: true
targets: ["*"]
description: "Project overview and general development guidelines for CLI Application in Go"
globs: ["**/*"]
---

# Development Steps for CLI Application in Go

## 1. Overall Design
- Define the purpose and scope of the CLI application.
- Identify the target audience and their needs.
- Outline the main features and functionalities.
- Create a high-level architecture diagram.
- **Improve Specifications/Features:**
  - Enhance the design from a UX and beauty perspective.
  - Consider user feedback and usability testing to refine features.
  - Ensure that the CLI is intuitive and visually appealing.
- **Write a Design Document** in Markdown format at `design-doc/{feature name}` for any new or updated features.
- **Create a To-Do List** for tasks in `todo.txt` to track progress and responsibilities.

## 2. Detailed Design
- Break down features into individual commands and subcommands.
- Define the input and output for each command.
- Specify the data structures and types to be used.
- Plan error handling and logging mechanisms.
- Create a flowchart for command execution paths.
- **TDD Steps:**
  - Write a test for each command before implementation.
  - Define expected behavior and edge cases in the tests.
  - Implement the command to pass the tests.
  - Refactor the code as necessary while ensuring all tests pass.
  - Update the `todo.txt` with TDD tasks for each command and feature.

## 3. Implementation
- Set up the Go project structure (e.g., using `go mod`).
- **Step-by-Step Implementation:**
  - For each task in `todo.txt`:
    - Implement the unit tests first.
    - Write the implementation code for the feature.
    - After each action, verify that the results match expectations.
    - Continue this process until all tasks in `todo.txt` are completed.
- Implement commands using the `cobra` library.
- Ensure adherence to Go's coding standards and best practices.
- Use version control (e.g., Git) for tracking changes.

## 4. Check
- Perform code reviews with peers to ensure quality. ✅
- Run all tests and check for coverage. 📊
- Validate the CLI against the initial requirements. ✔️
- **Output Results:**
  - Summarize the results of plans, tasks, and outcomes with emojis for clarity and beauty. 🎉
  - Example:
    - **Tasks Completed:** 5/5 ✅
    - **Tests Passed:** 20/20 🎉
    - **Bugs Found:** 0 🐞
- Gather feedback from users and iterate on the design as needed. 🗣️
