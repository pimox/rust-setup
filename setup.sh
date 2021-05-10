#
# Try to setup the build machine so that we can build the rust components of Proxmox.
# This involves a certain amount of flighting between how Debian wants to build things, how
# Rust and Cargo want to build things, how Proxmox want to build things, and the version
# nightmare that subsquently ensues.
#
# Tim <tim.j.wilkinson@gmail.com>
#

# Install rustup
if [ ! -d "${HOME}/.rustup ]; then
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
fi

# We need to install the default rustc and cargo (even though we don't want to use them as) they're dependencies
sudo apt install \
  rustc \
  cargo

# Setup the compatible toolchain
rustup tookchain install 1.51.0
# And make system use it
rustup toolchain link system 1.51.0-$(uname -m)-$(uname -i)-linux-gnu

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
sudo apt install \
  $(cat package.list)
