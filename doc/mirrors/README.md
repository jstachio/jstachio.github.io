# Javadoc link mirrors

Small, curated mirrors of third-party javadoc `element-list`/`package-list` index
files, used as the `<link>` target for `maven-javadoc-plugin` cross-references during
CI builds where the real host is sometimes unreachable (e.g. `www.slf4j.org` from
GitHub Actions runners).

Only the tiny index file is mirrored (it just lists package names so javadoc can
generate `<a href>`s pointing at the *real* site) - not the actual javadoc HTML.
Consuming projects should default to these mirrors for normal/CI builds and switch to
the real URL for release builds, e.g. rainbowgum's `pom.xml`:

```xml
<slf4j.javadoc.link>https://jstach.io/doc/mirrors/slf4j/api/</slf4j.javadoc.link>
```

overridden to `https://www.slf4j.org/api/` in its `deploy-release` profile.

## Refreshing

These are point-in-time snapshots, not kept live in sync - package lists for stable
libraries like SLF4J essentially never change. To refresh:

```
curl -sS https://www.slf4j.org/api/element-list -o doc/mirrors/slf4j/api/element-list
```

## slf4j/api

Source: `https://www.slf4j.org/api/element-list`, fetched 2026-08-24.
