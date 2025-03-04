<p align="left">
  <img width="150" src="https://github.com/user-attachments/assets/8ce74895-e944-4414-8dd6-b536112f78ee">
  <img width="450" src="https://github.com/user-attachments/assets/4cd12fd2-1bab-4139-95a2-73bbfadde332">
</p>

# SpeakerView
3D view of the speaker setup for SpatGRIS. SpeakerView is currently developed at the [Groupe de Recherche en Immersion Spatiale (GRIS)](https://gris.musique.umontreal.ca/) and the [Société des Arts Technologiques (SAT)](https://sat.qc.ca/en/).

Prior to version 3.3.0, SpatGRIS used OpenGL for 3D rendering. OpenGL is now deprecated on MacOS and JUCE does not facilitate the transition to Vulkan. The [GRIS](https://gris.musique.umontreal.ca/) team has chosen to separate the 3D speaker setup view from SpatGRIS. Using [Godot Engine](https://godotengine.org/), it is possible to support the main platforms (Windows, MacOS and Linux) and the hardware disparities of video graphics cards.

There are 3 SpeakerView versions.
- SpeakerView Forward uses Vulkan and support modern hardware
- SpeakerView Mobile uses Vulkan, but also supports older hardware
- SpeakerView Compatibilty uses OpenGL

SpatGRIS installer comes with SpeakerView Forward. If SpeakView does not render things correctly, replacing it (and the SpeakerView.pck file under Windows and Linux) with another version may help.

## Building
### Download Godot Engine
Download and install [Godot 4.3](https://github.com/godotengine/godot/releases/tag/4.3-stable)

### Clone SpeakerView sources
```
git clone git@github.com:GRIS-UdeM/SpeakerView.git
```

### Compiling
1. From the Godot project list, import _project.godot_ of the SpeakerView folder.
2. Select Edit the SpeakerView project.
3. [Export](https://docs.godotengine.org/en/stable/tutorials/export/index.html) the project to the platform of your choice.

## Running
It is best to launch SpeakerView from SpatGRIS View menu : Show Speaker View.

To function correctly, the SpeakerView executable (and the SpeakerView.pck file under Windows and Linux) must be placed in the same folder as SpatGRIS. SpeakerView is independent of SpatGRIS, but designed to be controlled by SpatGRIS using the UDP protocol.

On Linux, the name of the executable must be SpeakerView.x86_64.
