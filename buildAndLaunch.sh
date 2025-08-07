#!/bin/bash

scrDir=$(pwd)
ProjectName=$(grep "project" CMakeLists.txt | sed 's/project(//' | sed 's/.$//')

if [ $1 = "--remove-build" ]; then
	rm -rf build/
	echo "removed build directory"
fi

# build project
echo "configuring project with CMake..."
cmake -S . -B build -DJUCE_BUILD_EXTRAS=ON
echo "building project..."
cmake --build build


# build juce Audio Plugin Host:
echo "make sure Audio Plugin Host is built..."
cd libs/juce
if [[ ! -d "build" ]]; then
  cmake -B build
  cmake -B build -DJUCE_BUILD_EXTRAS=ON
  cmake --build build --target AudioPluginHost
else
  echo "Audio Plugin Host already built"
fi

# make plugin available from VST3_PATH:
echo "copying plugin to ~/.vst3 ..."
cp -r ${scrDir}/build/plugin/${ProjectName}_artefacts/VST3/${ProjectName}.vst3 ~/.vst3

# launch Audio Plugin Host:
echo "launching Audio Plugin Host..."
./build/extras/AudioPluginHost/AudioPluginHost_artefacts/AudioPluginHost > ${scrDir}/output.log 2>&1


