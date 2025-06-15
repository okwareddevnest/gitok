#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${CYAN}🔧 Installing Gitok by Dedan Okware...${NC}"

# Get the latest version
echo -e "${BLUE}📥 Downloading Gitok...${NC}"
if curl -sL https://raw.githubusercontent.com/okwareddevnest/gitok/main/.gitok.sh -o ~/.gitok.sh; then
    chmod +x ~/.gitok.sh
    echo -e "${GREEN}✅ Gitok downloaded successfully${NC}"
else
    echo -e "${RED}❌ Failed to download Gitok${NC}"
    exit 1
fi

# Helper to update shell profiles
add_to_profile() {
    local profile_file="$1"
    local profile_name="$2"
    
    # Create the profile file if it doesn't exist
    if [[ ! -f "$profile_file" ]]; then
        touch "$profile_file"
        echo -e "${YELLOW}📄 Created $profile_name${NC}"
    fi
    
    # Check if gitok is already sourced in this profile
    if ! grep -q "source.*\.gitok\.sh" "$profile_file" && ! grep -q "\..*\.gitok\.sh" "$profile_file"; then
        {
            echo ""
            echo "# Gitok - Git CLI Aliases"
            echo "source ~/.gitok.sh"
        } >> "$profile_file"
        echo -e "${GREEN}✅ Added Gitok to $profile_name${NC}"
        return 0
    else
        echo -e "${YELLOW}⚠️  Gitok already configured in $profile_name${NC}"
        return 1
    fi
}

# Detect and configure shell profiles
echo -e "${BLUE}🔍 Detecting shell configurations...${NC}"

PROFILES_UPDATED=0

# Bash profiles
if [[ -n "$BASH_VERSION" ]] || command -v bash >/dev/null 2>&1; then
    for bash_profile in ~/.bashrc ~/.bash_profile ~/.profile; do
        if [[ -f "$bash_profile" ]] || [[ "$bash_profile" == ~/.bashrc ]]; then
            if add_to_profile "$bash_profile" "$(basename "$bash_profile")"; then
                ((PROFILES_UPDATED++))
            fi
        fi
    done
fi

# Zsh profiles
if [[ -n "$ZSH_VERSION" ]] || command -v zsh >/dev/null 2>&1; then
    if add_to_profile ~/.zshrc ".zshrc"; then
        ((PROFILES_UPDATED++))
    fi
fi

# Fish shell
if command -v fish >/dev/null 2>&1; then
    fish_config_dir="$HOME/.config/fish"
    fish_config_file="$fish_config_dir/config.fish"
    
    if [[ ! -d "$fish_config_dir" ]]; then
        mkdir -p "$fish_config_dir"
    fi
    
    if [[ ! -f "$fish_config_file" ]]; then
        touch "$fish_config_file"
        echo -e "${YELLOW}📄 Created config.fish${NC}"
    fi
    
    if ! grep -q "source.*\.gitok\.sh" "$fish_config_file"; then
        {
            echo ""
            echo "# Gitok - Git CLI Aliases"
            echo "source ~/.gitok.sh"
        } >> "$fish_config_file"
        echo -e "${GREEN}✅ Added Gitok to config.fish${NC}"
        ((PROFILES_UPDATED++))
    else
        echo -e "${YELLOW}⚠️  Gitok already configured in config.fish${NC}"
    fi
fi

# Try to source immediately in current shell
echo -e "${BLUE}🔄 Activating Gitok in current session...${NC}"
# shellcheck source=/dev/null
if source ~/.gitok.sh 2>/dev/null; then
    echo -e "${GREEN}✅ Gitok activated in current session${NC}"
    
    # Test if gitok command works
    if command -v gitok >/dev/null 2>&1; then
        echo -e "${GREEN}🎉 Installation successful!${NC}"
        echo ""
        echo -e "${CYAN}📖 Quick Start:${NC}"
        echo -e "   ${YELLOW}gitok --version${NC}     - Check version"
        echo -e "   ${YELLOW}gitcheatsheet${NC}       - View all commands"
        echo -e "   ${YELLOW}gitok --help${NC}        - Get help"
        echo -e "   ${YELLOW}gitok --update${NC}      - Update Gitok"
        echo ""
        
        # Display version
        gitok --version
    else
        echo -e "${YELLOW}⚠️  Gitok installed but command not immediately available${NC}"
    fi
else
    echo -e "${YELLOW}⚠️  Gitok installed but couldn't activate in current session${NC}"
fi

# Final instructions
echo ""
if [[ $PROFILES_UPDATED -gt 0 ]]; then
    echo -e "${GREEN}✅ Gitok configured for shell startup${NC}"
    echo -e "${BLUE}💡 New terminal sessions will have Gitok available${NC}"
else
    echo -e "${YELLOW}⚠️  No shell profiles were updated${NC}"
    echo -e "${BLUE}💡 You may need to manually add 'source ~/.gitok.sh' to your shell profile${NC}"
fi

echo ""
echo -e "${CYAN}🔗 Documentation: ${BLUE}https://github.com/okwareddevnest/gitok${NC}"
echo -e "${CYAN}💬 Support: ${BLUE}https://github.com/okwareddevnest/gitok/issues${NC}"
