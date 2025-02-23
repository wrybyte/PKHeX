#!/usr/bin/env bash

# Pre-requisites:
# - Wine + Wine prefix with SDK installed
# - Dotnet (installed on system and inside wine prefix)

shopt -s expand_aliases

# Use a wine prefix that has the .NET SDKs installed.
alias wine='env WINEPREFIX=~/wine/pkhex-net9.0/ WINEDEBUG=-all wine'
alias dotnet-wine='wine dotnet'

# Compile PKHeX
dotnet-wine clean
dotnet restore \
    --runtime=win-x64
dotnet-wine build \
    --no-restore \
    --configuration=Release

# Location to save PKHeX data.
outdir="$HOME/programs/PKHeX"
# Location to link binary.
outbin="$HOME/bin/PKHeX"
# Desktop file for ease of use.
desktop="$HOME/.local/share/applications/PKHeX.desktop"
# Application icon location.
icon="$HOME/.local/share/icons/hicolor/64x64/apps/pkhex.png"

# Move compiled files to an easily accessible location.
mkdir --parents "$outdir"/{bak,pkmdb}
cp ./PKHeX.WinForms/bin/Release/net9.0-windows/* "$outdir" 2>/dev/null
cp ./icon.png "$icon"

# Also create a command to make it easier to configure the wine prefix.
tee <<EOF >"$outbin-config"
#!/usr/bin/env sh

cd $outdir || exit 1
env WINEPREFIX=\$HOME/wine/pkhex-net9.0 WINEDEBUG=-all winecfg "\$@"
EOF

# Create a shell script to run PKHeX inside the wine prefix.
tee <<EOF >"$outbin"
#!/usr/bin/env sh

cd $outdir || exit 1
env WINEPREFIX=\$HOME/wine/pkhex-net9.0 WINEDEBUG=-all wine ./PKHeX.exe "\$@"
EOF

chmod u+x "$outbin-config" "$outbin"

# This is a must-have in modern Linux desktop environments.
tee <<EOF >"$desktop"
[Desktop Entry]
Version=1.0
Name=PKHeX
Type=Application
Icon=$icon
Exec=$outbin %f
Comment=Pokémon core series save editor
GenericName=Pokémon Save File Editor
Terminal=false
Categories=Game;Development;
Keywords=Nintendo;Pkm;Editor;Pokémon
StartupWMClass=pkhex.exe
EOF
