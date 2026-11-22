#!/usr/bin/env bash

set -euo pipefail

CONFIG_DIR="${HOME}/.config"
DRY_RUN=true

if [[ "${1:-}" == "--delete" ]]; then
    DRY_RUN=false
elif [[ "${1:-}" == "--help" ]]; then
    echo "Usage: $0 [--delete]"
    echo "  Default    Show dead symlinks without deleting them"
    echo "  --delete   Remove dead symlinks"
    exit 0
fi

if [[ ! -d "$CONFIG_DIR" ]]; then
    echo "Error: Directory not found: $CONFIG_DIR" >&2
    exit 1
fi

found=0
removed=0

while IFS= read -r -d '' link; do
    found=1

    if $DRY_RUN; then
        printf 'Would remove: %s\n' "$link"
    else
        if rm -- "$link"; then
            printf 'Removed: %s\n' "$link"
            ((removed += 1))
        else
            printf 'Failed to remove: %s\n' "$link" >&2
        fi
    fi
done < <(find "$CONFIG_DIR" -xtype l -print0)

if (( found == 0 )); then
    echo "No dead symbolic links found in $CONFIG_DIR"
elif $DRY_RUN; then
    echo
    echo "Dry run complete. Run with --delete to remove these links."
else
    echo
    printf 'Cleanup complete. Removed %d dead symbolic link(s).\n' "$removed"
fi
