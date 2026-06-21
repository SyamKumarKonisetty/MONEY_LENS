# Versioning Policy

MoneyLens V2 follows a strict release naming and versioning pattern to ensure stability and seamless upgrades.

## 1. Semantic Versioning Rules

We utilize the standard `MAJOR.MINOR.PATCH+BUILD` schema:

1.  **PATCH (e.g., `1.2.1+2`)**: Increment for minor hotfixes and backward-compatible patches that do not modify database schemas or core design systems.
2.  **MINOR (e.g., `1.3.0+3`)**: Increment for backward-compatible features, database migrations (with upgrade paths), or new MLDS design system extensions.
3.  **MAJOR (e.g., `2.0.0+4`)**: Increment for significant feature overhauls, major architectural migrations, or breaking database schema changes.
4.  **BUILD (e.g., `+5`)**: Increment with every build compiled and sent to the Google Play Store or internal testers to ensure uniqueness in the Play Console.

---

## 2. Release Branch Strategy

```
  main  ────────────────────────── (Stable Releases) 
          ▲
          │ (Merge Pull Request)
 release ─┴─── v1.2.0 (Release Candidate branch)
          ▲
          │
  dev    ─┴─────────────────────── (Integration branch)
```

1.  **dev**: All completed feature branches are merged here for validation and internal QA.
2.  **release/vX.Y.Z**: Branches branched from `dev` to freeze feature changes and perform release testing.
3.  **main**: Contains stable release candidate commits, tagged with the matching version (e.g., `v1.2.0`).
