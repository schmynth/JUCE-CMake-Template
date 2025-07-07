cmake_minimum_required(VERSION 3.22)

project(AudioPlugin VERSION 0.1.0)


juce_add_plugin(${PROJECT_NAME}
    COMPANY_NAME schmynth_audio
    IS_SYNTH FALSE
    FORMATS VST3
    NEEDS_MIDI_INPUT FALSE
    NEEDS_MIDI_OUTPUT FALSE
    PLUGIN_MANUFACTURER_CODE SMTH # four characters you want
    PLUGIN_CODE AUPL # what you want
    PRODUCT_NAME "AudioPlugin"
)

target_sources(${PROJECT_NAME}
    PRIVATE
        src/PluginEditor.cpp
        src/PluginProcessor.cpp
)

target_include_directories(${PROJECT_NAME}
    PRIVATE
        include
)

target_link_libraries(${PROJECT_NAME}
    PRIVATE
        juce::juce_audio_utils
        juce::juce_dsp
    PUBLIC
        juce::juce_recommended_config_flags
        juce::juce_recommended_lto_flags
        juce::juce_recommended_warning_flags
)

target_compile_definitions(${PROJECT_NAME}
    PUBLIC
        JUCE_WEB_BROWSER=0
        JUCE_USE_CURL=0
        JUCE_VST3_CAN_REPLACE_VST2=0
)

# # to ignore deprecation warnings, uncomment the following lines:
# target_compile_options(${PROJECT_NAME}
#     PRIVATE
#         -Wno-deprecated-declarations
# )