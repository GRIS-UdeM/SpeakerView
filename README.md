# SpeakerView
3D view of the speaker setup for SpatGris.

Prior to version 3.3.0, SpatGRIS used OpenGL for 3D rendering. OpenGL is now deprecated on MacOS and JUCE does not facilitate the transition to Vulkan. The [GRIS](https://gris.musique.umontreal.ca/) team has chosen to separate the 3D speaker setup view from SpatGRIS. Using [Godot Engine](https://godotengine.org/), it is possible to support the main platforms (Windows, MacOS and Linux) and the hardware disparities of video graphics cards.

There are 3 SpeakerView versions.
- SpeakerView Forward uses Vulkan and support modern hardware
- SpeakerView Mobile uses Vulkan, but also supports older hardware
- SpeakerView Compatibilty uses OpenGL

SpatGRIS installer comes with SpeakerView Forward. If SpeakView does not render things correctly, replacing it (and the SpeakerView.pck file under Windows and Linux) with another version may help.

## Building
### Download Godot Engine
Download and install [Godot 4.2.1](https://github.com/godotengine/godot/releases/tag/4.2.1-stable)

### Clone SpeakerView sources
```
git clone git@github.com:GRIS-UdeM/SpeakerView.git
```

### Compiling
1. From the Godot project list, import _project.godot_ of the SpeakerView folder.
2. Select Edit the SpeakerView project.
3. [Export](https://docs.godotengine.org/en/stable/tutorials/export/index.html) the project to the platform of your choice.

## Running
It is best to launch SpeakerView from SpatGris View menu : Show Speaker View.

To function correctly, the SpeakerView executable (and the SpeakerView.pck file under Windows and Linux) must be placed in the same folder as SpatGris. SpeakerView is independent of SpatGris, but designed to be controlled by SpatGris using the UDP protocol. 

On Linux, the name of the executable must be SpeakerView.x86_64.
