#!/bin/bash



set -e

echo "=== Starting /main_work initialization ==="


if ! id "harsh" &>/dev/null; then
    echo "Creating user harsh..."
    useradd -d /main_work/home/harsh -s /bin/bash harsh 2>/dev/null || true

    
    mkdir -p /main_work/home/harsh

    
    if [ ! -f /main_work/home/harsh/.bashrc ]; then
        cp /etc/skel/.bashrc /main_work/home/harsh/ 2>/dev/null || true
        cp /etc/skel/.bash_logout /main_work/home/harsh/ 2>/dev/null || true
        cp /etc/skel/.profile /main_work/home/harsh/ 2>/dev/null || true
    fi

    
    chown -R harsh:harsh /main_work/home/harsh 2>/dev/null || true

    echo "User harsh created successfully"
else
    echo "User harsh already exists"
fi


mkdir -p /main_work/configs
echo "Created /main_work/configs directory for persistent configurations"


if [ -f /main_work/configs/custom_bashrc ]; then
    echo "Found custom bashrc in /main_work/configs/"
    cp /main_work/configs/custom_bashrc /main_work/home/harsh/.bashrc
    cp /main_work/configs/custom_bashrc /root/.bashrc
    echo "Applied custom bashrc to harsh and root"
else
    echo "No custom bashrc found at /main_work/configs/custom_bashrc"
    echo "Using default bashrc with PATH additions"
    
    
    if ! grep -q "/main_work" /main_work/home/harsh/.bashrc 2>/dev/null; then
        echo 'export PATH="/main_work:$PATH"' >> /main_work/home/harsh/.bashrc
    fi
fi


chown -R harsh:harsh /main_work/home/harsh 2>/dev/null || true


if [ ! -f /main_work/configs/custom_bashrc ]; then
    if ! grep -q "/main_work" /root/.bashrc 2>/dev/null; then
        echo 'export PATH="/main_work:$PATH"' >> /root/.bashrc
        echo "Added /main_work to root's PATH"
    fi
fi


if [ -d /etc/profile.d ]; then
    echo 'export PATH="/main_work:$PATH"' > /etc/profile.d/main_work.sh
    chmod +x /etc/profile.d/main_work.sh
    echo "Added /main_work to system-wide PATH"
fi





if getent group sudo > /dev/null 2>&1; then
    usermod -aG sudo harsh 2>/dev/null || true
    echo "Added harsh to sudo group"
fi


export PATH="/main_work:$PATH"

echo 'eval "$(/main_work/homebrew/bin/brew shellenv)"' >> /main_work/home/harsh/.bashrc

git config --global user.email "harsh.alhan@rmgx.in"
git config --global user.name "harsh-rmgx"

git config --global init.defaultBranch dev_harsh_testing
git config --global pull.rebase false
