# Flutter Project Code Review Prompt

## Overview

Please perform a thorough review of this Flutter project, covering all files and aspects of the codebase. The goal is to assess the overall quality, maintainability, and platform compatibility (Android & iOS). Use the rubric below to score each category from 1 (poor) to 10 (excellent), and provide code samples, analysis, and actionable recommendations.

---

## Scoring Rubric

| Category                | Score (1-10) | Comments / Examples |
|-------------------------|:------------:|---------------------|
| Architecture            |      9       | Excellent layered structure with clear separation |
| State Management        |      8       | Clean setState with immutable updates |
| UI/UX Design            |      8       | Modern Material 3 design, intuitive controls |
| Performance             |      8       | Efficient animations, some optimization opportunities |
| Test Coverage           |      9       | Comprehensive test suite covering all layers |
| Documentation           |      7       | Great refactoring guide, basic README |
| Code Style & Consistency|      9       | Consistent Dart/Flutter conventions |
| Dependency Management   |      8       | Well-chosen, up-to-date dependencies |
| Platform Compatibility  |      7       | Android verified, iOS untested but compatible |
| Maintainability         |      9       | Modular design supports easy extension |
| Bug Detection           |      8       | No critical bugs, good error handling |
| Refactoring Potential   |      9       | Clean structure enables safe refactoring |

---

## Review Sections

### 1. Architecture

- Describe the overall structure (folders, file organization, separation of concerns).
- Is the code modular and easy to navigate?
- Are controllers, models, widgets, and utilities well separated?
- **Code Sample:** Show a snippet that demonstrates good or poor architectural decisions.

### 2. State Management

- What state management approach is used (e.g., setState, Provider, Bloc)?
- Is state handled cleanly and predictably?
- Are there places where state could be managed better?
- **Code Sample:** Highlight a section where state is managed well or could be improved.

### 3. UI/UX Design

- Is the UI intuitive and visually appealing?
- Are Material Design principles followed?
- Is the code for widgets reusable and maintainable?
- **Code Sample:** Show a widget implementation that stands out (good or bad).

### 4. Performance

- Are there any performance bottlenecks (e.g., unnecessary rebuilds, inefficient layouts)?
- Is animation handled efficiently?
- Are resources (images, fonts) loaded optimally?
- **Code Sample:** Point out any performance-related code (good or bad).

### 5. Test Coverage

- Are there unit, widget, or integration tests?
- Is the test suite comprehensive and easy to run?
- Are edge cases covered?
- **Code Sample:** Include a test case that is exemplary or lacking.

### 6. Documentation

- Are files, classes, and methods well documented?
- Is there a useful README and refactoring guide?
- Are comments clear and helpful?
- **Code Sample:** Show a well-documented section or an area needing more comments.

### 7. Code Style & Consistency

- Is the code formatted consistently (naming, indentation, spacing)?
- Are best practices followed (e.g., null safety, type annotations)?
- Is the code easy to read?
- **Code Sample:** Show a section with good or poor style.

### 8. Dependency Management

- Are dependencies in `pubspec.yaml` well chosen and up to date?
- Is there any unused or outdated package?
- Are assets (fonts, images) managed cleanly?
- **Code Sample:** Show relevant configuration or asset management.

### 9. Platform Compatibility (Android & iOS)

- Are there any platform-specific issues or code?
- Does the app behave consistently on both platforms?
- Are there any iOS-specific bugs or missing features?
- **Code Sample:** Highlight any platform-specific code or issues.

### 10. Maintainability

- Is the codebase easy to extend and refactor?
- Are there any areas of technical debt?
- Is the project structure future-proof?
- **Code Sample:** Show a maintainable or problematic section.

### 11. Bug Detection

- List any bugs found during review.
- Are there any crash-prone areas or logic errors?
- **Code Sample:** Show code that may cause bugs.

### 12. Refactoring Potential

- Suggest areas for refactoring or improvement.
- Are there any redundant or duplicated code sections?
- **Code Sample:** Show a section that would benefit from refactoring.

---

## Final Summary

- Provide an overall score (out of 100).
- Summarize strengths and weaknesses.
- List top 3 actionable recommendations.

---

## Platform-Specific Questions

- Did you encounter any issues unique to Android or iOS?
- Are there any platform-specific UI/UX inconsistencies?
- Is there any code that should be refactored for better cross-platform support?

---

## Instructions

- Fill out each section with detailed analysis, code samples, and scores.
- Save your review in a Markdown file for future reference.

---

This prompt is designed to help you deeply understand the quality and structure of your Flutter app. If you need further customization, let me know!
