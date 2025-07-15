# JUCE & CMAKE

## anatomy of a plugin

### Processor

| Processor | Editor | 

The processor contains the DSP code and parameters that produce or manipulate audio and/or midi data.
It also creates the editor (see below).

The realtime processing happens in 
```cpp
void AudioPluginAudioProcessor::processBlock()
```
>[!WARNING]
>Do ***not*** use slow or unpredictable code in this function as it runs on the audio thread!  
>**Only realtime-safe code allowed!**

### Editor

The editor contains the GUI. The editor is created by the processor in
```cpp
juce::AudioProcessorEditor* AudioPluginAudioProcessor::createEditor()
{
    return new AudioPluginAudioProcessorEditor (*this);
}
```
and is given a pointer to the processor so that the editor can access members of processor.

The editor is **created each time the GUI is launched in the DAW** and destroyed when the window is closed.


## Parameters and value tree

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
    APVTS::ParameterLayout apvts;
    apvts.add(std::make_unique<juce::AudioParameterFloat>(juce::ParameterID{"CHANCE", versionHint}, 
                                                        "CHANCE",
                                                        juce::NormalisableRange<float>(0.0f, 1.f, 0.01f, 1.f), 0.2f, ""));

    return apvts;
}
```