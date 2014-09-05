# libressl Debian packaging

Intended for use with git-buildpackage. Upstream sources are imported into the
`upstream` branch with orig tarballs managed on the `pristine-tar` branch.
Packaging for a given release is under ubuntu/DIST, to work on packaging
check out the appropriate distribution branch(s) and make commits there.

Version numbering uses the following format

    "<libressl-version>+git<YYYYMMDDHHmmss>+<portable-commit>+<openbsd-commit>-<package-version>"

e.g. `2.1.0+git20140905142821+3a44b6f+3f944e8-1` for

- the first build of version 2.1.0
- checkout from git on 2014-09-05 14:28:21 (UTC)
- libressl-portable commit 3f944e8
- libressl-openbsd commit 3a44b6f
