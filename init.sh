#!/bin/bash

set -e

echo "=== Starting main_work initialization ==="

# 1. CREATE USER HARSH AND GIVE SUDO ACCESS
echo "Step 1: Setting up user harsh..."

if ! id "harsh" &>/dev/null; then
    echo "Creating user harsh..."
    # Create user with a proper home directory
    useradd -m -s /bin/bash harsh
    echo "User harsh created successfully"
else
    echo "User harsh already exists"
fi

# Add harsh to sudo group
if getent group sudo > /dev/null 2>&1; then
    usermod -aG sudo harsh
    echo "Added harsh to sudo group"
elif getent group wheel > /dev/null 2>&1; then
    usermod -aG wheel harsh
    echo "Added harsh to wheel group"
fi

# 2. ADD /home/ubuntu/main_work TO PATH
echo "Step 2: Configuring PATH for /home/ubuntu/main_work..."

MAIN_WORK_PATH="/home/ubuntu/main_work"

# Ensure the directory exists
mkdir -p "$MAIN_WORK_PATH"

# Add to harsh's .bashrc
if [ -f /home/harsh/.bashrc ]; then
    if ! grep -q "$MAIN_WORK_PATH/homebrew/bin" /home/harsh/.bashrc; then
        echo "" >> /home/harsh/.bashrc
        echo "# Add main_work and homebrew to PATH" >> /home/harsh/.bashrc
        echo "export PATH=\"$MAIN_WORK_PATH/homebrew/bin:$MAIN_WORK_PATH:\$PATH\"" >> /home/harsh/.bashrc
        echo "Added $MAIN_WORK_PATH to harsh's PATH"
    else
        echo "PATH already configured in harsh's .bashrc"
    fi
fi

# Add to root's .bashrc
if [ -f /root/.bashrc ]; then
    if ! grep -q "$MAIN_WORK_PATH/homebrew/bin" /root/.bashrc; then
        echo "" >> /root/.bashrc
        echo "# Add main_work and homebrew to PATH" >> /root/.bashrc
        echo "export PATH=\"$MAIN_WORK_PATH/homebrew/bin:$MAIN_WORK_PATH:\$PATH\"" >> /root/.bashrc
        echo "Added $MAIN_WORK_PATH to root's PATH"
    else
        echo "PATH already configured in root's .bashrc"
    fi
fi

# Add to ubuntu user's .bashrc (if exists)
if [ -f /home/ubuntu/.bashrc ]; then
    if ! grep -q "$MAIN_WORK_PATH/homebrew/bin" /home/ubuntu/.bashrc; then
        echo "" >> /home/ubuntu/.bashrc
        echo "# Add main_work and homebrew to PATH" >> /home/ubuntu/.bashrc
        echo "export PATH=\"$MAIN_WORK_PATH/homebrew/bin:$MAIN_WORK_PATH:\$PATH\"" >> /home/ubuntu/.bashrc
        echo "Added $MAIN_WORK_PATH to ubuntu's PATH"
    else
        echo "PATH already configured in ubuntu's .bashrc"
    fi
fi

# Add system-wide PATH configuration
if [ -d /etc/profile.d ]; then
    cat > /etc/profile.d/main_work.sh << 'EOF'
# Add main_work and homebrew to PATH
export PATH="/home/ubuntu/main_work/homebrew/bin:/home/ubuntu/main_work:$PATH"
EOF
    chmod +x /etc/profile.d/main_work.sh
    echo "Added system-wide PATH configuration"
fi

# If homebrew exists in main_work, add its shellenv
if [ -d "$MAIN_WORK_PATH/homebrew" ]; then
    echo "Configuring Homebrew..."

    # Add to harsh's .bashrc
    if [ -f /home/harsh/.bashrc ] && ! grep -q "homebrew/bin/brew shellenv" /home/harsh/.bashrc; then
        echo "" >> /home/harsh/.bashrc
        echo "# Homebrew configuration" >> /home/harsh/.bashrc
        echo "eval \"\$($MAIN_WORK_PATH/homebrew/bin/brew shellenv)\"" >> /home/harsh/.bashrc
        echo "Added Homebrew to harsh's environment"
    fi

    # Add to ubuntu's .bashrc
    if [ -f /home/ubuntu/.bashrc ] && ! grep -q "homebrew/bin/brew shellenv" /home/ubuntu/.bashrc; then
        echo "" >> /home/ubuntu/.bashrc
        echo "# Homebrew configuration" >> /home/ubuntu/.bashrc
        echo "eval \"\$($MAIN_WORK_PATH/homebrew/bin/brew shellenv)\"" >> /home/ubuntu/.bashrc
        echo "Added Homebrew to ubuntu's environment"
    fi
fi

# Set current session PATH
export PATH="$MAIN_WORK_PATH/homebrew/bin:$MAIN_WORK_PATH:$PATH"

# 3. CONFIGURE GIT
echo "Step 3: Configuring Git..."

git config --global user.email "harsh.alhan@rmgx.in"
git config --global user.name "harsh-rmgx"
git config --global init.defaultBranch dev_harsh_testing
git config --global pull.rebase false

echo "Git configured for user: $(git config --global user.name) <$(git config --global user.email)>"

echo ""
echo "=== Initialization complete ==="
echo ""
echo "Summary:"
echo "  ✓ User 'harsh' created with sudo access"
echo "  ✓ PATH configured to include $MAIN_WORK_PATH"
echo "  ✓ Git configured with user credentials"
echo ""
echo "Note: You may need to logout and login again for PATH changes to take full effect,"
echo "or run: source ~/.bashrc"

# Add miniconda to PATH
if [ -d "$MAIN_WORK_PATH/miniconda3/bin" ]; then
    echo "" >> /home/harsh/.bashrc
    echo "# Miniconda PATH" >> /home/harsh/.bashrc
    echo "export PATH=\"$MAIN_WORK_PATH/miniconda3/bin:\$PATH\"" >> /home/harsh/.bashrc

    echo "" >> /home/ubuntu/.bashrc
    echo "# Miniconda PATH" >> /home/ubuntu/.bashrc
    echo "export PATH=\"$MAIN_WORK_PATH/miniconda3/bin:\$PATH\"" >> /home/ubuntu/.bashrc

    echo "" >> /root/.bashrc
    echo "# Miniconda PATH" >> /root/.bashrc
    echo "export PATH=\"$MAIN_WORK_PATH/miniconda3/bin:\$PATH\"" >> /root/.bashrc

    echo "Added miniconda to PATH for all users"
fi
