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

Then in PluginProcessor.cpp, define this this function and add the parameters you need:

```cpp
juce::AudioProcessorValueTreeState::ParameterLayout AudioPluginAudioProcessor::createParameterLayout()
{
    const int versionHint = 1;
    APVTS::ParameterLayout layout;
    
    // int parameter
    layout.add(std::make_unique<juce::AudioParameterInt>("grooveVariant", // parameter ID
                                                        "Groove Variant", // parameter name
                                                        0,                // minValue
                                                        2,                // maxValue
                                                        0))               // defaultValue

    // float parameter
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

## Editor Layout

The layout of the editor should be divided into areas for easier resizing and positioning of elements.  
The [```juce::Rectangle``` Class](https://docs.juce.com/master/classRectangle.html) is used for that.

It works like this:

```cpp

// save full available area as rectangle in area:
auto area = getLocalBounds(); 

// take a portion from area (40 pixels from top) and save it in topArea
// IMPORTANT: area will be changed to window - topArea!
auto topArea = area.removeFromTop(40); 

// take another portion from (now smaller area) and save it in middleArea
auto middleArea = area.removeFromTop(40);
// area will now be the rest of the window (window - topArea - middleArea)

// To define a subArea of an Area, you can reduce the area itself ( reduce() )
// Or return a reduced version of an area into a new area variable ( reduced(x,y) ) like so:
// IMPORTANT: the distinction is made by the subtle difference in names of the functions!
auto patternSelectorArea = topArea.reduced(30,1);

```

>[!CAUTION]
>If f.e. you place three rotary sliders in a row in middleArea,  
>you remove a third of middleArea from left and place slider1 in it.  
>Now you are left with the rest of middleArea. To get an equally large  
>area for slider two and three, you have to removeFromLeft only half of  
>middleAreas width, because middleArea lost a third already.  
>Finally, slider3 gets the whole rest of middleArea.  


## Labels

If you created a slider and want to add a label to it, this is how *not* to do it:

```cpp
// Chance Slider and Label
chanceSlider.setSliderStyle(juce::Slider::RotaryHorizontalVerticalDrag);
chanceSlider.setTextBoxStyle(juce::Slider::TextBoxBelow, false, 60, 20);

chanceLabel.setText("Chance", juce::dontSendNotification);
chanceLabel.setJustificationType(juce::Justification::centred);
chanceLabel.attachToComponent(&chanceSlider, false);
chanceAttachment = std::make_unique<juce::AudioProcessorValueTreeState::SliderAttachment>(processorRef.apvts, "CHANCE", chanceSlider);
addAndMakeVisible(chanceSlider);
```

>[!ǸOTE]
>addAndMakeVisible() is only called on the slider, NOT on the label.
>Label visibility is handled by attachToComponent.

>[!CAUTION]
>This is not the best way to do it, because the label can not be placed manually.
>Better position it manually and call addAndMakeVisible on the label as well.
>If you manually position it, you can **not** call attachToComponent() on the Label!

<!--
▄ ▄▖▖ ▖▄▖▄▖▖▖  ▄ ▄▖▄▖▄▖
▙▘▐ ▛▖▌▌▌▙▘▌▌  ▌▌▌▌▐ ▌▌
▙▘▟▖▌▝▌▛▌▌▌▐   ▙▘▛▌▐ ▛▌
-->

# Binary Data

To include binary data, such as image files for knobs etc. add this to your ```CMakeLists.txt``` in ```plugin/``` :  

## Step 1

```cmake
juce_add_binary_data(BinaryData     # can be any name, has to be used in Step 2
    SOURCES 
        data/img/knob1.png          # has to be relative path and no variables
)
```

## Step 2

Link to the BinaryData library in the same ```CMakeLists.txt```:  

```cmake
target_link_libraries(${PROJECT_NAME}
    PRIVATE
        juce::juce_audio_utils
        juce::juce_audio_basics
        juce::juce_audio_processors
        juce::juce_gui_basics
        juce::juce_graphics
        juce::juce_dsp
        BinaryData # <--- Important Line
    PUBLIC
        juce::juce_recommended_config_flags
        juce::juce_recommended_lto_flags
        juce::juce_recommended_warning_flags
)
```

## Step 3 (optional)

For IntelliSense to work correctly and find the ```BinaryData::``` members,
uncomment line 7 in ```c_cpp_properties.json```.  
IntelliSense can not find the header file in build directory unless
it is explicitly added (down to parent directory of the BinaryData.h header file).