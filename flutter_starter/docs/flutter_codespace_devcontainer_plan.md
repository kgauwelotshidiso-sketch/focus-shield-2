# Focus Shield Flutter Codespace Devcontainer Plan

This document prepares a Flutter-ready Codespace without changing the current working web prototype.

## Safe approach

Do not overwrite the current Codespace setup immediately.

Keep templates under:

flutter_starter/templates/flutter_devcontainer/

Only move them to `.devcontainer/` when you intentionally want to rebuild the Codespace as a Flutter environment.

## Future devcontainer files

Template files created:

- flutter_starter/templates/flutter_devcontainer/devcontainer.json
- flutter_starter/templates/flutter_devcontainer/Dockerfile

## Future move command

Only later, when ready:

mkdir -p .devcontainer
cp flutter_starter/templates/flutter_devcontainer/devcontainer.json .devcontainer/devcontainer.json
cp flutter_starter/templates/flutter_devcontainer/Dockerfile .devcontainer/Dockerfile

Then rebuild the Codespace.

## Warning

Rebuilding a Codespace can take time and may temporarily interrupt your current workflow.

Do this only after your Git status is clean.
