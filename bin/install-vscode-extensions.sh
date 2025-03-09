#!/bin/bash

# Install VSCode extensions

echo "Installing VSCode extensions..."

# AWS extensions
code --install-extension amazonwebservices.aws-toolkit-vscode
code --install-extension AmazonWebServices.codewhisperer-for-command-line

# AWS CDK extensions
code --install-extension hbenl.vscode-test-explorer
code --install-extension ms-vscode.test-adapter-converter
code --install-extension ms-vscode.vscode-typescript-next
code --install-extension msoffice.microsoft-office-add-in-debugger
code --install-extension redhat.vscode-yaml

# Cline extension
code --install-extension saoudrizwan.claude-dev

# TypeScript extensions
code --install-extension dbaeumer.vscode-eslint

# Vim
code --install-extension vscodevim.vim

# ESLint extension
code --install-extension dbaeumer.vscode-eslint

# Other useful extensions
code --install-extension eamodio.gitlens
code --install-extension esbenp.prettier-vscode
code --install-extension ms-azuretools.vscode-docker
code --install-extension ms-vscode-remote.remote-containers
code --install-extension ms-vscode-remote.remote-ssh
code --install-extension ms-vscode-remote.remote-ssh-edit
code --install-extension ms-vscode.remote-explorer
code --install-extension yzhang.markdown-all-in-one

echo "VSCode extensions installation complete!"
