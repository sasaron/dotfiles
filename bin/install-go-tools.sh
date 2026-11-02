#!/bin/bash
set -e

# Go tools installation script
echo "Installing Go tools..."

# Create custom Go binary directory if it doesn't exist
CUSTOM_GOBIN="$HOME/.go/bin"
mkdir -p "$CUSTOM_GOBIN"

# List of Go tools to install
GO_TOOLS=(
  "github.com/go-delve/delve/cmd/dlv@latest"
  "github.com/golangci/golangci-lint/cmd/golangci-lint@latest"
  "golang.org/x/tools/cmd/goimports@latest"
  "github.com/fatih/gomodifytags@latest"
  "github.com/haya14busa/goplay/cmd/goplay@latest"
  "golang.org/x/tools/gopls@latest"
  "github.com/cweill/gotests/gotests@latest"
  "github.com/josharian/impl@latest"
  "github.com/mgechev/revive@latest"
  "honnef.co/go/tools/cmd/staticcheck@latest"
  "github.com/google/wire/cmd/wire@latest"
  "github.com/fe3dback/go-arch-lint@latest"
  "mvdan.cc/gofumpt@latest"
  "github.com/pressly/goose/v3/cmd/goose@latest"
  "github.com/securego/gosec/v2/cmd/gosec@latest"
)

# Store original GOBIN value
ORIGINAL_GOBIN="$GOBIN"

# Set custom GOBIN
export GOBIN="$CUSTOM_GOBIN"

# Install each tool
for tool in "${GO_TOOLS[@]}"; do
  echo "Installing $tool..."
  go install $tool
done

# Restore original GOBIN
if [ -z "$ORIGINAL_GOBIN" ]; then
  unset GOBIN
else
  export GOBIN="$ORIGINAL_GOBIN"
fi

echo "Go tools installation completed! Binaries installed to $CUSTOM_GOBIN"
echo "Make sure to add $CUSTOM_GOBIN to your PATH if it's not already included."