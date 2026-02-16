## 0.2.0

* **Feature:** Auto-include partner parents for children with single parents.
  - Children of couples now automatically appear under both parents even if only one parent was explicitly specified.
* **Fix:** Reorder parents list during level calculation to align with DFS traversal path for correct layout.
* **Fix:** Typo correction "parttner" → "partner".

## 0.1.0

* Initial release.
* Added `SimpleLayout` for standard tree structures.
* Added `WalkersTreeLayout` for complex, non-overlapping trees (Buchheim algorithm).
* Added support for Partner/Spouse relationships using `partnerId`.
* Implemented customizable node rendering with `NodeBuilder`.