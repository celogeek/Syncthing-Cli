#!/bin/bash
export SYNC_CLI_HOME="$HOME/.syncthingcli"
export SYNC_CLI_ROOT="$SYNC_CLI_HOME/syncthingcli"
export PERL_CPANM_OPT="--mirror http://cpan.celogeek.fr -l $SYNC_CLI_ROOT -L $SYNC_CLI_ROOT -nq --self-contained"
export PERL=/usr/bin/perl
export CPANM=$SYNC_CLI_ROOT/bin/cpanm

set -e

echo "Installing Syncthing::Cli ..."

mkdir -p $SYNC_CLI_ROOT/bin
curl -sL http://cpanmin.us > $CPANM
$PERL $CPANM App::local::lib::helper
source $SYNC_CLI_ROOT/bin/localenv-bashrc
$PERL $CPANM Dist::Zilla
dzil authordeps | $PERL $CPANM
dzil install --install-command="$PERL $CPANM ."

mkdir -p $SYNC_CLI_HOME/bin
cat << __EOF__ > $SYNC_CLI_HOME/bin/syncthing-cli
#!/bin/bash
$SYNC_CLI_ROOT/bin/localenv $SYNC_CLI_ROOT/bin/syncthing-cli "$@"
__EOF__
chmod +x $SYNC_CLI_ROOT/bin/syncthing-cli

echo ""
echo "Installation done"
echo ""
echo "Add this to your ~/.bashrc or ~/.profile"
echo ""
echo "   export PATH=$SYNC_CLI_ROOT/bin:\$PATH"
echo ""
