# Issues

Local issue tracker. The git remote is a local bare repo, so issues live in this directory, not on a hosted service.

- One issue per file: `NNNN-short-slug.md`, numbered in creation order.
- Each file starts with frontmatter:

  ```
  ---
  title: One-line summary
  status: open | in-progress | done | invalid | rejected | superseded
  priority: low | medium | high    (not on done issues)
  labels: bug, enhancement, cleanup, test, research
  ---
  ```

- Body: what happens, where (file and line), and what done looks like.
- `issues/open` lists the open and in-progress issues, high priority first.
- Update `status` in the file when work changes state. Close by setting `status: done`; don't delete files.
