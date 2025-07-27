# Comprehensive Code Review Prompt for main.dart

Use this prompt to conduct a thorough, professional code review of the `main.dart` file in a Flutter project. This prompt ensures comprehensive analysis across all critical dimensions of code quality.

---

## Instructions for Code Reviewer

**Objective:** Conduct a 100-point comprehensive code review of the `main.dart` file, providing actionable insights for improvement across architecture, performance, security, and maintainability.

**Target Audience:** Senior developers, technical leads, and code reviewers who need detailed analysis for production-ready code assessment.

**Scoring System:** Use a 100-point scale with category breakdowns and specific line-by-line recommendations.

---

## Review Framework

### 1. **Project Relationship Analysis** (Weight: 10%)
Analyze how `main.dart` fits within the broader project architecture:
- **Integration Points**: Examine dependencies on models, controllers, widgets, and utilities
- **Design Patterns**: Identify architectural patterns (Observer, Strategy, Facade, State)
- **Layered Architecture**: Assess separation between presentation, business logic, and data layers
- **Cross-Cutting Concerns**: Evaluate how the file handles performance, responsive design, and state consistency
- **Coupling Analysis**: Determine tight vs. loose coupling with other components

### 2. **Line-by-Line Technical Analysis** (Weight: 25%)
Provide detailed examination with specific improvements:
- **Import Organization**: Check import structure and dependencies
- **Method Complexity**: Identify methods exceeding 20-30 lines
- **State Management**: Review state mutation patterns and lifecycle management
- **Error Handling**: Assess try-catch blocks, null safety, and graceful degradation
- **Performance Hotspots**: Flag expensive operations in UI thread
- **Memory Management**: Check for potential leaks and proper disposal

**For each issue found, provide:**
- Exact line numbers
- Specific refactoring recommendations
- Code examples showing improved implementation
- Performance impact assessment

### 3. **Code Organization & Readability** (Weight: 15%)
Evaluate structural quality:
- **Method Grouping**: Logical organization of related functionality
- **Naming Conventions**: Clarity and consistency of variable/method names
- **Documentation**: Inline comments and method descriptions
- **Code Duplication**: Identify repeated patterns that should be abstracted
- **Single Responsibility**: Ensure methods have clear, focused purposes

### 4. **Error Handling & Robustness** (Weight: 15%)
Critical assessment of defensive programming:
- **Input Validation**: Check for bounds checking and type validation
- **Null Safety**: Proper handling of optional values and late initialization
- **Exception Handling**: Comprehensive try-catch coverage
- **Graceful Degradation**: Fallback mechanisms for failed operations
- **User Feedback**: Error messaging and recovery options

### 5. **State Management Excellence** (Weight: 10%)
Flutter-specific state analysis:
- **State Synchronization**: Multiple controller coordination
- **Rebuild Optimization**: Unnecessary setState calls and rebuild prevention
- **Lifecycle Management**: Proper initialization and disposal
- **State Validation**: Consistency checks and invalid state prevention
- **Future Scalability**: Readiness for complex state management libraries

### 6. **Performance Optimization** (Weight: 10%)
Identify performance bottlenecks:
- **Frame Rate Impact**: Operations affecting 60fps target
- **Memory Usage**: Object creation patterns and garbage collection
- **Build Method Efficiency**: Widget tree optimization
- **Animation Performance**: Smooth transition implementation
- **Resource Management**: Controller and listener lifecycle

### 7. **Security Assessment** (Weight: 5%)
Security vulnerability analysis:
- **Input Sanitization**: Validation of user inputs and external data
- **Bounds Checking**: Array access and numeric range validation
- **Resource Access**: Safe file and network operations
- **Error Information**: Prevention of sensitive data exposure in logs

### 8. **Flutter/Dart Best Practices** (Weight: 5%)
Framework-specific quality:
- **Widget Patterns**: Proper StatefulWidget and StatelessWidget usage
- **Key Usage**: Appropriate widget keys for performance
- **Const Constructors**: Immutable widget optimization
- **Modern Dart Features**: Null safety, pattern matching, records

### 9. **Testing & Maintainability** (Weight: 3%)
Code testability assessment:
- **Unit Test Readiness**: Method isolation and dependency injection
- **Mock-Friendly Design**: Interface-based programming
- **Complexity Metrics**: Cyclomatic complexity and testing difficulty

### 10. **Accessibility & Inclusive Design** (Weight: 2%)
User accessibility evaluation:
- **Screen Reader Support**: Semantic labels and descriptions
- **Keyboard Navigation**: Focus management and shortcuts
- **Visual Accessibility**: High contrast and large text support
- **Motor Accessibility**: Touch target sizes and gesture alternatives

---

## Required Output Format

### Executive Summary
```markdown
## Executive Summary

**Overall Score: [X]/100**

**Key Strengths:**
- [List 3-4 major strengths]

**Priority Action Items:**
1. [Most critical issue with timeline]
2. [Second priority with impact assessment]
3. [Third priority with effort estimate]
```

### Detailed Analysis Template
```markdown
### [Section Name] (Lines X-Y)
**Score: [X]/10**

```dart
[Include relevant code snippet]
```

**Analysis:** [Detailed explanation of current implementation]

**Issues:**
- [Specific problem 1 with impact]
- [Specific problem 2 with risk level]

**Refactoring Suggestions:**
```dart
[Show improved code example]
```

**Performance/Security Impact:** [Quantify the improvement]
```

### Category Breakdown Template
```markdown
## Category Breakdown

### 1. [Category Name] (Score: X/10)
**Strengths:**
- [Specific positive findings]

**Areas for Improvement:**
- [Specific recommendations with examples]

**Critical Issues:**
- [High-priority problems requiring immediate attention]
```

### Action Items Template
```markdown
## Action Items (Priority Order)

### High Priority (Security & Stability)
1. **[Action]** (Lines X-Y) - [Timeline] - [Impact]
2. **[Action]** (Lines X-Y) - [Timeline] - [Impact]

### Medium Priority (Performance & UX)
3. **[Action]** (Lines X-Y) - [Timeline] - [Impact]

### Low Priority (Code Quality)
4. **[Action]** (Lines X-Y) - [Timeline] - [Impact]
```

---

## Specific Focus Areas for main.dart

### Critical Analysis Points:
1. **State Coordination Complexity**: How well does the file manage multiple animation controllers and UI state?
2. **Memory Management**: Proper disposal of controllers, listeners, and animation resources
3. **Initialization Robustness**: Safe handling of widget lifecycle and screen size dependencies
4. **Error Recovery**: Graceful handling of animation failures and invalid states
5. **Performance Under Load**: Frame rate maintenance during complex animations
6. **Responsive Design**: Adaptation to different screen sizes and orientations

### Common Flutter main.dart Issues to Check:
- Late initialization without proper null checking
- Heavy computations in build methods
- Improper animation controller disposal
- State mutations causing unnecessary rebuilds
- Missing error boundaries for layout failures
- Inadequate input validation for user controls
- Poor separation between UI and business logic

### Required Code Examples:
For each significant issue found, provide:
1. **Current problematic code** (with line numbers)
2. **Improved implementation** (with explanation)
3. **Alternative approaches** (when applicable)
4. **Performance comparison** (before/after metrics)

---

## Quality Gates

### Minimum Acceptable Standards:
- **Error Handling**: No uncaught exceptions possible (Score ≥ 7/10)
- **Memory Management**: No memory leaks in normal operation (Score ≥ 8/10)
- **Performance**: Maintains 60fps during animations (Score ≥ 7/10)
- **Code Organization**: Methods under 50 lines, clear responsibilities (Score ≥ 7/10)

### Excellence Indicators:
- **Comprehensive error recovery mechanisms**
- **Optimized rebuild patterns with minimal state changes**
- **Clear separation of concerns with testable architecture**
- **Defensive programming with input validation**
- **Accessibility features implemented**

---

## Deliverable Requirements

1. **Comprehensive Review Document** (`main.dart_code_review.md`)
2. **Line-by-line analysis** with specific recommendations
3. **Refactored code examples** for major improvements
4. **Performance optimization strategies**
5. **Security vulnerability assessment**
6. **Prioritized action plan** with timelines
7. **Category scoring breakdown** with justifications

---

## Usage Instructions

1. **Load the main.dart file** for review
2. **Apply this prompt systematically** through each category
3. **Document findings** using the provided templates
4. **Prioritize recommendations** by impact and effort
5. **Provide specific code examples** for improvements
6. **Score each category** with clear justification
7. **Create actionable next steps** with timelines

This prompt ensures consistent, thorough code reviews that provide actionable insights for improving Flutter application quality, performance, and maintainability.
