# Releases

Short overview of how releases work in the AuraSpeak repos.

## What are releases?

When you push a matching tag, a **GitHub Release** is created automatically – including release notes. Each repo has its own tags and releases.

## Tag formats

- **Stable versions:** e.g. `v1.0.0`, `v2.1.3`
- **Pre-releases:** e.g. `v0.0.0-pre0.1`

Tags with a leading `v` are recognised by all workflows. Pre-release tags (e.g. with `-pre0.1`) appear on GitHub as “Pre-release”.

## Triggering a release

In the respective repo, create and push a tag:

```bash
git tag v1.0.0
git push origin v1.0.0
```

The corresponding GitHub Actions workflow (`.github/workflows/release.yml`) runs and creates the release including notes.

## Which repos build what?

| Repo      | Type    | Result                                                                 |
| --------- | ------- | ---------------------------------------------------------------------- |
| client    | Binary  | GoReleaser builds binaries (e.g. Linux/Windows/macOS, amd64/arm64)     |
| server    | Binary  | same as client                                                         |
| debug-ui  | Binary  | same as client                                                         |
| network   | Library | Source release only, no binaries – release with auto-generated notes   |
| protocol  | Library | same as network                                                        |

## Release notes

Release notes are generated automatically:

- **client, server, debug-ui:** GoReleaser uses the GitHub Compare API and lists commits since the last tag (with author).
- **network, protocol:** The GitHub API generates notes from commits and PRs.

Pre-release tags are marked as “Pre-release” on GitHub and appear separately from stable releases.
