#!/bin/sh
# Installs the chaintable CLI from https://github.com/haimingx/chaintable-cli releases:
#
#   curl -fsSL https://raw.githubusercontent.com/haimingx/chaintable-cli/main/install.sh | sh
#
# CHAINTABLE_VERSION selects a release tag (default: the newest release, pre-releases included).
# CHAINTABLE_INSTALL_DIR selects the directory (default: ~/.local/bin).
# The archive is always checked against checksums.txt; when cosign is installed, the signature of
# checksums.txt is verified as well.
set -eu

repo=haimingx/chaintable-cli
signer=https://github.com/haimingx/chaintable-cli-src/.github/workflows/release.yml
dir=${CHAINTABLE_INSTALL_DIR:-$HOME/.local/bin}

fail() {
	echo "chaintable install: $*" >&2
	exit 1
}
for tool in curl tar uname mktemp; do
	command -v "$tool" >/dev/null 2>&1 || fail "$tool is required"
done

case $(uname -s) in
Linux) os=linux ;;
Darwin) os=darwin ;;
*) fail "unsupported system $(uname -s); download an archive from https://github.com/$repo/releases" ;;
esac
case $(uname -m) in
x86_64 | amd64) arch=amd64 ;;
arm64 | aarch64) arch=arm64 ;;
*) fail "unsupported architecture $(uname -m)" ;;
esac

api() {
	curl -fsSL -H "Accept: application/vnd.github+json" -H "X-GitHub-Api-Version: 2022-11-28" "https://api.github.com/repos/$repo/$1"
}

tag=${CHAINTABLE_VERSION:-}
if [ -z "$tag" ]; then
	# /releases/latest skips pre-releases and the list is not in release order (v0.1.0-beta.10 sorts
	# before beta.2), so take the most recently published release.
	tag=$(api "releases?per_page=100" |
		awk -F'"' '/"tag_name":/ { tag = $4 } /"published_at": "/ { print $4, tag }' |
		sort -r | head -n 1 | cut -d ' ' -f 2) || tag=""
fi
if [ -z "$tag" ]; then
	# GitHub's cache can serve an empty release list for minutes after a release: take the highest
	# version tag instead ("~" sorts a pre-release before its final release), if it has a release.
	tag=$(api "tags?per_page=100" | awk -F'"' '/"name": "v/ { print $4 }' |
		sed 's/-/~/' | sort -V | tail -n 1 | sed 's/~/-/') || tag=""
	[ -n "$tag" ] && api "releases/tags/$tag" >/dev/null 2>&1 ||
		fail "could not find the newest release; set CHAINTABLE_VERSION to a tag from https://github.com/$repo/releases"
fi
archive="chaintable_${tag#v}_${os}_${arch}.tar.gz"
base="https://github.com/$repo/releases/download/$tag"

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
echo "Downloading chaintable $tag for $os/$arch"
curl -fsSL -o "$tmp/$archive" "$base/$archive" || fail "could not download $base/$archive"
curl -fsSL -o "$tmp/checksums.txt" "$base/checksums.txt" || fail "could not download checksums.txt"

if command -v cosign >/dev/null 2>&1; then
	curl -fsSL -o "$tmp/checksums.txt.sigstore.json" "$base/checksums.txt.sigstore.json" ||
		fail "could not download the signature"
	cosign verify-blob --bundle "$tmp/checksums.txt.sigstore.json" \
		--certificate-identity "$signer@refs/tags/$tag" \
		--certificate-oidc-issuer https://token.actions.githubusercontent.com \
		"$tmp/checksums.txt" >/dev/null 2>&1 || fail "the signature of checksums.txt does not verify"
	echo "Signature verified"
fi

expected=$(awk -v f="$archive" '$2 == f { print $1 }' "$tmp/checksums.txt")
[ -n "$expected" ] || fail "$archive is not listed in checksums.txt"
if command -v sha256sum >/dev/null 2>&1; then
	actual=$(sha256sum "$tmp/$archive" | cut -d ' ' -f 1)
else
	actual=$(shasum -a 256 "$tmp/$archive" | cut -d ' ' -f 1)
fi
[ "$expected" = "$actual" ] || fail "checksum mismatch for $archive"

tar -xzf "$tmp/$archive" -C "$tmp" chaintable
mkdir -p "$dir"
# Stage next to the target and rename: running processes keep the old file, new ones get the whole new one.
staged="$dir/.chaintable.$$"
cp "$tmp/chaintable" "$staged" && chmod 0755 "$staged" && mv -f "$staged" "$dir/chaintable" ||
	{ rm -f "$staged"; fail "could not write $dir/chaintable"; }
echo "Installed $("$dir/chaintable" --version) at $dir/chaintable"
# Keep skills from `chaintable skill install` at this version, as `chaintable update` does; releases
# without `skill sync` fail here, which is fine. Plugins are updated by Claude Code and Codex.
case $("$dir/chaintable" skill sync 2>/dev/null) in
*'"updated":["'*) echo "Refreshed the skills installed with chaintable skill install" ;;
esac
case ":$PATH:" in
*":$dir:"*) ;;
*) echo "Add $dir to your PATH to run chaintable" ;;
esac
