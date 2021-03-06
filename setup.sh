#
# Try to setup the build machine so that we can build the rust components of Proxmox.
# This involves a certain amount of flighting between how Debian wants to build things, how
# Rust and Cargo want to build things, how Proxmox want to build things, and the version
# nightmare that subsquently ensues.
#
# Tim <tim.j.wilkinson@gmail.com>
#

# Set to "-t buster-backports" if necessary
BP=

# Install rustup
if [ ! -d "${HOME}/.rustup" ]; then
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
fi
. "$HOME/.cargo/env"

# We need the latest debcargo
sudo apt install ${BP} pkg-config libssl-dev libcurl4-gnutls-dev quilt
# Currently building a working version for arm is buggy, so we include one
#cargo install debcargo --locked
cp binaries/debcargo $HOME/.cargo/bin/debcargo

# We need to install the default rustc and cargo (even though we don't want to use them as) they're dependencies
sudo apt install ${BP} \
  rustc \
  cargo

# Setup the compatible toolchain
TV=1.51.0
TC="${TV}-$(uname -m)-$(uname -i)-linux-gnu"
rustup toolchain install ${TV}
# And make system use it
rustup toolchain link system "${HOME}/.rustup/toolchains/${TC}"
rustup default ${TV}

# Replace the default debian cargo wrapper
# This just removes the hard-coded /usr/bin/cargo path as well as the -Z option which doesnt work on stable compilers
P=/usr/share/cargo/bin
if [ ! -f ${P}/cargo.pimox ]; then
  echo "Replacing the default Debian cargo wrapper in ${P} with our tweaked version"
  echo "If I was a better person I'd port the debian cargo package and make these tweaks there"
  sudo cp ${P}/cargo ${P}/cargo.debian
  sudo cp cargo.pimox ${P}/cargo.pimox
  sudo cp cargo.pimox ${P}/cargo
fi

# Install the very specific dependencies
sudo apt install ${BP} \
  $(cat package.list)
