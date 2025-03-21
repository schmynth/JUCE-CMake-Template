#!/bin/bash

if [ $1 = "--remove-build" ]; then
	rm -rf build/
	echo "removed build directory"
fi

# build project
echo "configuring project with CMake..."
cmake -S . -B build
echo "building project..."
cmake --build build


# build juce Audio Plugin Host:
echo "make sure Audio Plugin Host is built..."
cd libs/juce
cmake -B build
cmake -B build -DJUCE_BUILD_EXTRAS=ON
cmake --build build --target AudioPluginHost

# launch Audio Plugin Host:
echo "launching Audio Plugin Host..."
./build/extras/AudioPluginHost/AudioPluginHost_artefacts/AudioPluginHost


