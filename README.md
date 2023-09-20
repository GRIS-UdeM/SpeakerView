# SpeakerView
3D view of the speaker setup for SpatGris.

## Building
### Download Godot Engine
Download and install [Godot 4.1.1](https://github.com/godotengine/godot/releases/tag/4.1.1-stable)

### Clone SpeakerView sources
```
git clone git@github.com:GRIS-UdeM/SpeakerView.git
```

### Compiling
1. From the Godot project list, import _project.godot_ of the SpeakerView folder.
2. Select Edit the SpeakerView project.
3. [Export](https://docs.godotengine.org/en/4.1/tutorials/export/index.html) the project to the platform of your choice.

## Running
It is best to launch SpeakerView from SpatGris View menu : Show Speaker View.

To function correctly, the SpeakerView executable (and the SpeakerView.pck file under Windows and Linux) must be placed in the same folder as SpatGris. SpeakerView is independent of SpatGris, but designed to be controlled by SpatGris using the UDP protocol. 

On Linux, the name of the executable must be SpeakerView.x86_64.