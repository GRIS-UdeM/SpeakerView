<p align="left">
  <img width="150" src="https://github.com/user-attachments/assets/fbec48ec-1f0c-41f1-9a10-4ce993747f57">
  <img width="450" src="https://github.com/user-attachments/assets/4cd12fd2-1bab-4139-95a2-73bbfadde332">
</p>

# SpeakerView
3D view of the speaker setup for SpatGRIS. SpeakerView is currently developed at the [Groupe de Recherche en Immersion Spatiale (GRIS)](https://gris.musique.umontreal.ca/) and the [Société des Arts Technologiques (SAT)](https://sat.qc.ca/en/).

SpeakView is built with [Godot Engine](https://godotengine.org). Godot has 3 rendering engines.
- Forward uses Vulkan and support modern hardware
- Mobile uses Vulkan, but also supports older hardware
- Compatibilty uses OpenGL

SpatGRIS installer comes with SpeakerView Forward. If SpeakView does not render things correctly, replacing it (and the SpeakerView.pck file under Windows and Linux) with another version may help.

## Building
### Download Godot Engine
Download and install [Godot 4.5](https://github.com/godotengine/godot/releases/tag/4.5-stable)

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

To function correctly, the SpeakerView executable (and the SpeakerView.pck file under Windows and Linux) must be placed in the same folder as SpatGRIS. SpeakerView is independent of SpatGRIS, but designed to be controlled by SpatGRIS using the UDP protocol. It is also possible to run SpeakerView in standalone mode (by running the executable file directly) and configure UDP ports accordingly.

On Linux, the executable file name must be SpeakerView.x86_64.
