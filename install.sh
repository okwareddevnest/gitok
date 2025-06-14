#!/bin/bash
echo "🔧 Installing Gitok by Dedan Okware..."

curl -sL https://raw.githubusercontent.com/okwareddevnest/gitok/main/.gitok.sh -o ~/.gitok.sh

if ! grep -q "source ~/.gitok.sh" ~/.bashrc; then
  echo "source ~/.gitok.sh" >> ~/.bashrc
fi

if ! grep -q "source ~/.gitok.sh" ~/.zshrc; then
  echo "source ~/.gitok.sh" >> ~/.zshrc
fi

echo "✅ Gitok installed. Restart your terminal or run:"
echo "    source ~/.bashrc  # or source ~/.zshrc"
