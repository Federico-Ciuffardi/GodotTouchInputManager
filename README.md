<img src="https://i.imgur.com/HxwBAK2.png" align="right" />

# Godot Touch Input Manager
Godot Touch Input Manager (GDTIM) is a script that improves touch input support (includes [new gestures](#supported-gestures)) in the Godot game engine. You just need to autoload the script and it will start analyzing the touch input and when a gesture is detected a Custom Input Event corresponding to the detected gesture will be created and fed up to the Godot built in Input Event system so  it triggers functions like [`_input(InputEvent event)`](https://docs.godotengine.org/en/3.1/classes/class_node.html#class-node-method-input). There is also a signal for each gesture if you prefer using signals to the aforementioned. 

This asset was ported to be added to Godot and is now a milestone to version 4.0, PR: [https://github.com/godotengine/godot/pull/36953](https://github.com/godotengine/godot/pull/36953).

## How to use
* Download the latest release from https://github.com/Federico-Ciuffardi/Godot-Touch-Input-Manager/releases
* Extract the downloaded *.zip* file somewhere in you project
* Locate the extracted `InputManager.gd`, and [Autoload](https://docs.godotengine.org/en/3.1/getting_started/step_by_step/singletons_autoload.html) it.
* Done! Now you can use the GodotTouchInputManager's [signals](#supported-gestures-and-its-signals) and its [Custom Input Events](#custom-input-events).

## Examples
### [GodotTouchInputManager-Demo](https://github.com/Federico-Ciuffardi/GodotTouchInputManager-Demo)
![Demo](https://media.giphy.com/media/TimI1xvghKrM20Xmhy/giphy.gif)
### [GestureControlledCamera2D](https://github.com/Federico-Ciuffardi/GestureControlledCamera2D)
![Demo](https://media.giphy.com/media/Xzdynnlx4XAqndgVe0/giphy.gif)

## Documentation

### Supported gestures 
| Name                      | Signal       |  Custom input event / Signal args                           |
|---------------------------|--------------|-------------------------------------------------------------|
| Single finger tap         | single_tap   | [InputEventSingleScreenTap](#inputeventsinglescreentap)     |
| Single finger touch       | single_touch | [InputEventSingleScreenTouch](#inputeventsinglescreentouch) |
| Single finger drag        | single_drag  | [InputEventSingleScreenDrag](#inputeventsinglescreendrag)   |
| Pinch                     | pinch        | [InputEventScreenPinch](#inputeventscreenpinch)             |
| Multiple finger drag      | multi_drag   | [InputEventMultiScreenDrag](#inputeventmultiscreendrag)     |
| Twist                     | twist        | [InputEventScreenTwist](#inputeventscreentwist)             |
| any gesture               | any_gesture  | signal_name, InputEvent                                     | 



### Custom Input Events
The purpose of these is to provide a InputEvent for the inputs that are not considered by the built-in InputsEvents.

When a gesture is detected [`_input(InputEvent event)`](https://docs.godotengine.org/en/3.1/classes/class_node.html#class-node-method-input) will be called with the input event associated to the detected gesture as the `event` parameter.


#### InputEventScreenPinch

| Type                                                                                    | Name         |  Description                                                  |
|-----------------------------------------------------------------------------------------|--------------|---------------------------------------------------------------|
| [Vector2](https://docs.godotengine.org/en/3.1/classes/class_vector2.html#class-vector2) | position     | Pinch center position.                                        |
| [float](https://docs.godotengine.org/en/3.1/classes/class_float.html)                   | distance     | Pinch distance (between the fingers involved).                |
| [float](https://docs.godotengine.org/en/3.1/classes/class_float.html)                   | relative     | Pinch distance relative to its start distance.                |
| [float](https://docs.godotengine.org/en/3.1/classes/class_float.html)                   | speed        | Pinch speed (Average speed length of all the drags involved). |

#### InputEventSingleScreenDrag

| Type                                                                                    | Name         |  Description                                                  |
|-----------------------------------------------------------------------------------------|--------------|---------------------------------------------------------------|
| [Vector2](https://docs.godotengine.org/en/3.1/classes/class_vector2.html#class-vector2) | position     | SingleScreenDrag position.                                    |
| [Vector2](https://docs.godotengine.org/en/3.1/classes/class_vector2.html#class-vector2) | relative     | SingleScreenDrag position relative to its start position.     |
| [Vector2](https://docs.godotengine.org/en/3.1/classes/class_vector2.html#class-vector2) | speed        | SingleScreenDrag speed.                                       |

#### InputEventMultiScreenDrag

| Type                                                                                    | Name         |  Description                                                           |
|-----------------------------------------------------------------------------------------|--------------|------------------------------------------------------------------------|
| [Vector2](https://docs.godotengine.org/en/3.1/classes/class_vector2.html#class-vector2) | position     | MultiScreenDrag position (Average position of all the Drags involved). |
| [Vector2](https://docs.godotengine.org/en/3.1/classes/class_vector2.html#class-vector2) | relative     | MultiScreenDrag position relative to its start position (Average relative of all the drags involved).|
| [Vector2](https://docs.godotengine.org/en/3.1/classes/class_vector2.html#class-vector2) | speed        | MultiScreenDrag speed (Average speed of all the Drags involved).       |

#### InputEventScreenTwist

| Type                                                                                    | Name         |  Description                                                           |
|-----------------------------------------------------------------------------------------|--------------|------------------------------------------------------------------------|
| [Vector2](https://docs.godotengine.org/en/3.1/classes/class_vector2.html#class-vector2) | position     | Twist center position.                                                 |
| [float](https://docs.godotengine.org/en/3.1/classes/class_float.html)                   | relative     | Twist angle relative to its start angle.                               |
| [float](https://docs.godotengine.org/en/3.1/classes/class_float.html)                   | speed        | Twist speed                                                             |


#### InputEventSingleScreenTap

| Type                                                                                    | Name         |  Description                                                           |
|-----------------------------------------------------------------------------------------|--------------|------------------------------------------------------------------------|
| [Vector2](https://docs.godotengine.org/en/3.1/classes/class_vector2.html#class-vector2) | position     | Tap position.                                                          |

#### InputEventSingleScreenTouch

| Type                                                                                    | Name         |  Description                                                           |
|-----------------------------------------------------------------------------------------|--------------|------------------------------------------------------------------------|
| [Vector2](https://docs.godotengine.org/en/3.1/classes/class_vector2.html#class-vector2) | position     | Tap position.                                                          |
| [boolean](https://docs.godotengine.org/en/3.0/classes/class_bool.html)                  | pressed      | If it is `true`, the touch is beginning. If it is `false`, the touch is ending.  |
| [boolean](https://docs.godotengine.org/en/3.0/classes/class_bool.html)                  | cancelled    | If it is `true`, the touch has been cancelled by another touch. If it is `false`, the touch is still the only one.  |

### Mouse to gesture
To enable single finger gestures go to **Project > Project Settings > Input Devices > Pointing** and turn on *Emulate Touch From Mouse* to emulate a single finger press with the left click. For the other gestures 

| Gesture                   | Mouse action                                      |
|---------------------------|---------------------------------------------------|
| Pinch outward             | Scroll up                                         |
| Pinch inward              | Scroll down                                       |
| Multiple finger drag      | Middle click                                      |

## Versioning
Using [SemVer](http://semver.org/) for versioning. For the versions available, see the [releases](https://github.com/Federico-Ciuffardi/IOSU/releases) 

## Authors
* Federico Ciuffardi

Feel free to append yourself here if you've made contributions.

## Note
Thank you for checking out this repository, you can send all your questions and feedback to Federico.Ciuffardi@outlook.com.

If you are up to contribute on some way please contact me :)


