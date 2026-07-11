# Sourced by run_*.sh (after SCRIPT_DIR is set) to make BRAIN_PATH follow
# VAULT_BASE_PATH from .claude/settings.md, so the index always reflects the
# vault configured there instead of a silently diverging repo-local copy.
# Export BRAIN_PATH yourself before calling a run_*.sh script to override.
if [ -z "$BRAIN_PATH" ]; then
    SETTINGS_FILE="$SCRIPT_DIR/../../.claude/settings.md"
    if [ -f "$SETTINGS_FILE" ]; then
        # Extract just the VAULT_BASE_PATH=... line rather than sourcing the
        # whole file — other lines (e.g. DOCUMENT_INSIGHTS_PATH) contain
        # unquoted spaces that aren't safe to `source` as shell.
        VAULT_BASE_PATH="$(grep -m1 '^VAULT_BASE_PATH=' "$SETTINGS_FILE" | cut -d= -f2-)"
        [ -n "$VAULT_BASE_PATH" ] && export BRAIN_PATH="$VAULT_BASE_PATH"
    fi
fi
