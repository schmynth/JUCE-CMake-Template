# JUCE & CMAKE

## anatomy of a plugin

Each plugin has a processor (DSP) class and an editor (GUI) class.

<!---
▄▖▄▖▄▖▄▖▄▖▄▖▄▖▄▖▄▖
▙▌▙▘▌▌▌ ▙▖▚ ▚ ▌▌▙▘
▌ ▌▌▙▌▙▖▙▖▄▌▄▌▙▌▌▌
-->

# Processor

### Audio Processing

The processor contains the DSP code and parameters that produce or manipulate audio and/or midi data.
It also creates the editor (see below).

The realtime processing happens in 
```cpp
void AudioPluginAudioProcessor::processBlock()
```
>[!WARNING]
>Do ***not*** use slow or unpredictable code in this function as it runs on the audio thread!  
>**Only realtime-safe code allowed!**

#### prepareToPlay()

The ```prepareToPlay()``` function is called each time playback is started.  
It gets important information from the host like blockSize, sampleRate, numChannels etc.:

### Parameters and value tree

#### create parameters

In PluginProcessor.h (public) add this:  

```cpp
using APVTS = juce::AudioProcessorValueTreeState;
static APVTS::ParameterLayout createParameterLayout();
APVTS apvts;
```

Then in PluginProcessor.cpp, define this this function and add the parameters you need (like CHANCE in this example):

```cpp
juce::AudioProcessorValueTreeState::ParameterLayout AudioPluginAudioProcessor::createParameterLayout()
{
    const int versionHint = 1;
    APVTS::ParameterLayout layout;
    layout.add(std::make_unique<juce::AudioParameterFloat>(juce::ParameterID{"CHANCE", versionHint},           // CHANCE: parameter name
                                                        "CHANCE",                                              // parameterLabel
                                                        juce::NormalisableRange<float>(0.0f, 1.f, 0.01f, 1.f), // NormalisableRange (see note below)
                                                        0.2f,                                                  // Default value
                                                        ""));

    return layout;
}
```

>[!NOTE]
>```juce::NormalisableRange<type>(rangeStart, rangeEnd, interval, skewFactor)```

#### save/load plugin state

Saving the plugin state on close is done in:
```cpp
void PluginProcessor::getStateInformation()
```

Loading the plugin state on open is done in:
```cpp
void PluginProcessor::setStateInformation()
```


<!---
▄▖▄ ▄▖▄▖▄▖▄▖
▙▖▌▌▐ ▐ ▌▌▙▘
▙▖▙▘▟▖▐ ▙▌▌▌
-->


# Editor

The editor contains the GUI. The editor is created by the processor in
```cpp
juce::AudioProcessorEditor* AudioPluginAudioProcessor::createEditor()
{
    return new AudioPluginAudioProcessorEditor (*this);
}
```
and is given a pointer to the processor so that the editor can access members of processor.

The editor is **created each time the GUI is launched in the DAW** and destroyed when the window is closed.
