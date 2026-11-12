## ADDED Requirements

### Requirement: The task list keeps the reader's place

When a refresh puts tasks above the first line the reader can see while the task list is scrolled away from its
top, the list SHALL keep those tasks out until asked, so the line in view does not move. It SHALL float a pill over
its top edge reading "N new, show" with their count. Pressing the pill, or scrolling back to the top, SHALL draw
them; pressing it also scrolls to the top, at once under reduced motion.

#### Scenario: Tasks arrive above the reader

- **WHEN** two tasks arrive at the top of the list while the reader is reading further down
- **THEN** the row they were reading stays where it was and the pill says "2 new, show"

#### Scenario: The reader asks for them

- **WHEN** the reader presses the pill
- **THEN** the two tasks are drawn and the list scrolls to them

#### Scenario: The reader is at the top

- **WHEN** tasks arrive while the list is at its top
- **THEN** they are drawn at once and no pill shows
