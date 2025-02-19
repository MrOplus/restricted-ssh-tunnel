#!/bin/bash

# Set defaults if env vars are not provided
SSH_USERNAME=${SSH_USERNAME:-"tunneluser"}
SSH_PASSWORD=${SSH_PASSWORD:-"tunnelpass"}

# Create the user only if it doesn't exist
if ! id "$SSH_USERNAME" &>/dev/null; then
    echo "Creating user: $SSH_USERNAME"
    useradd -m -s /bin/false "$SSH_USERNAME"
    echo "$SSH_USERNAME:$SSH_PASSWORD" | chpasswd
    echo "User created with no shell access."
else
    echo "User $SSH_USERNAME already exists."
fi

# Ensure SSH allows tunneling but blocks shell access
echo "Match User $SSH_USERNAME" >> /etc/ssh/sshd_config
echo "  PermitTTY no" >> /etc/ssh/sshd_config
echo "  AllowTcpForwarding yes" >> /etc/ssh/sshd_config
echo "  PermitOpen any" >> /etc/ssh/sshd_config
echo "  X11Forwarding no" >> /etc/ssh/sshd_config
echo "  ForceCommand /bin/false" >> /etc/ssh/sshd_config  # Blocks shell access but allows forwarding

# Start SSH server
exec "$@"
