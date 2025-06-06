# MacSetup

This repository automates the setup of a new macOS development environment. It installs essential developer tools, configures system defaults, sets up SSH and Git, installs CLI and GUI applications, and copies your dotfiles.

## What It Does

- Installs Xcode Command Line Tools and Homebrew (`scripts/install.sh`)
- Installs and configures Git and SSH keys for GitHub (`scripts/git.sh`)
- Installs CLI tools and desktop apps from the Brewfile (`scripts/brew-stuff.sh`, `Brewfile`)
- Installs SDKs and language runtimes via SDKMAN (`scripts/sdk.sh`)
- Applies sensible macOS system defaults (`scripts/os-defaults.sh`)
- Copies dotfiles to your home directory (`run.sh`, `dotfiles/`)

## Usage

1. **Clone this repository:**
   ```bash
   git clone https://github.com/yourusername/macsetup.git
   cd macsetup
   ```

2. **Run the setup script:**
   ```bash
   ./run.sh
   ```

   This will:
   - Install Xcode tools and Homebrew
   - Set up Git and SSH keys
   - Install all CLI and GUI apps from the Brewfile
   - Install SDKs and runtimes
   - Apply macOS defaults
   - Copy dotfiles to your home directory

3. **(Optional) Change your shell to the latest Bash:**
   ```bash
   echo "/usr/local/bin/bash" | sudo tee -a /etc/shells
   chsh -s /usr/local/bin/bash
   ```

4. **Restart or log out for some changes to take effect.**

## Customization

- **To add or remove apps:**  
  Edit the `Brewfile` and re-run `./scripts/brew-stuff.sh`.
- **To change dotfiles:**  
  Edit files in the `dotfiles/` directory.

## Notes

- Some steps may prompt for your password or require manual action (e.g., adding your SSH key to GitHub).
- The scripts are idempotent and can be safely re-run.

---
