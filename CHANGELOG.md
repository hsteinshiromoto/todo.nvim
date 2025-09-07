# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased] - feature/priority_list

### Added
- **Due date support**: Tasks can now include due dates using the `due:YYYY-MM-DD` format
- **Composite priority sorting**: New intelligent sorting algorithm that combines importance, urgency, and due date proximity
- **Priority filtering**: New filter to show only tasks with importance, urgency, or due dates
- **Due date indicators**: Visual warnings for overdue tasks and tasks due soon
  - Shows "⚠ OVERDUE (Xd)" for overdue tasks
  - Shows "⚠ DUE TODAY" for tasks due today
  - Shows "⚠ DUE TOMORROW" for tasks due tomorrow
  - Shows remaining days for tasks due within a week

### Changed
- **Default filters**: Todo list now opens with incomplete, priority tasks by default
  - `completed = false` - hides completed tasks
  - `has_priority = true` - shows only tasks with importance, urgency, or due dates
- **Default sort**: Changed from "importance" to "composite_priority" for better task prioritization
- **Priority scoring system**:
  - Importance: High=30, Medium=20, Low=10 points
  - Urgency: High=30, Medium=20, Low=10 points
  - Due dates: Overdue=40, Today/Tomorrow=35, Within 3 days=25, Within a week=15, Within 2 weeks=5 points

### Enhanced
- **Parser module**: Extended to parse and store due dates from todo items
- **Finder module**: 
  - Added `has_priority` filter capability
  - Implemented `calculate_priority_score` function for composite scoring
  - Added `composite_priority` sort function
- **UI module**:
  - Improved todo display format to show all priority indicators
  - Added new keybindings:
    - `fp` - Toggle priority filter (cycles through: show priority tasks, show non-priority tasks, show all)
    - `sp` - Sort by composite priority
  - Updated help text to reflect new features

### Fixed
- Parser now correctly excludes "due" from special_tags since it's handled separately

## [0.1.0] - Previous Release

### Added
- Basic todo list functionality
- Markdown file parsing
- Importance and urgency indicators
- Project and context tags
- Calendar integration
- Visual indicators for fields