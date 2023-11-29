# This runs in userland

echo "

==> Setup complete, adding config files to new user plus some other config

"

mkdir /home/arch-is-best/.config

mv /home/arch-is-best/arch-dev-vm/config/* /home/arch-is-best/.config

file="/home/arch-is-best/arch-dev-vm/vscode-extensions"
while read line; do
    vscodium --install-extension "${line}"
done < "${file}"

echo "

==> We now need to change the shell to a more user-friendly one.
Please enter your password again

"

chsh -s /bin/fish

exit