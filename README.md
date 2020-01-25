# Godot Touch Input Manager
 Script to handle touch input. It also translates mouse input to gestures.

## How to use
* Dowload the latest release from https://github.com/Federico-Ciuffardi/Godot-Touch-Input-Manager/releases
* Extract the downloaded *.zip* file somewhere in you project
* Locate the InputManager.gd, put it inside of a node (or use [Autoload](https://docs.godotengine.org/en/3.1/getting_started/step_by_step/singletons_autoload.html)) and [connect](https://docs.godotengine.org/en/3.1/getting_started/step_by_step/signals.html) the signals to the nodes that will use the gesture associated with said signal.

For more information on how to do this see the [examples](https://github.com/Federico-Ciuffardi/Godot-Touch-Input-Manager-Examples).

## Supported gestures and it's signals:
| Name                      | Signal       | Args                                                   |
|---------------------------|--------------|--------------------------------------------------------|
| Single finger tap         | singe_tap    |  [InputEventScreenTouch](https://docs.godotengine.org/en/3.1/classes/class_inputeventscreentouch.html)                      |
| Single finger touch       | single_touch | [InputEventScreenTouch](https://docs.godotengine.org/en/3.1/classes/class_inputeventscreentouch.html)                      |
| Single finger drag        | single_drag  | [InputEventScreenDrag](https://docs.godotengine.org/en/3.1/classes/class_inputeventscreendrag.html)                       |
| Pinch                     | pinch        | [InputEventScreenPinch](#inputeventscreenpinch)        |
| Multiple finger drag      | multi_drag   | [InputEventMultiScreenDrag](#inputeventmultiscreendrag)|
| Twist                     | twist        | [InputEventScreenTwist](#inputeventscreentwist)        |
| any gesture               | any_gesture  | signal_name, InputEvent                                | 

## Custom Input Events
The purpose of these is to provide a InputEvent for the inputs that are not considered by the built-in InputsEvents.

### InputEventScreenPinch

#### Properties

* [Vector2](https://docs.godotengine.org/en/3.1/classes/class_vector2.html#class-vector2) **position**

Pinch center position.

* [float](https://docs.godotengine.org/en/3.1/classes/class_float.html) **relative**

Relative distance variation of the pinch. 

* [float](https://docs.godotengine.org/en/3.1/classes/class_float.html) **speed**

Pinch speed (Average speed length of all the Drags involved).


### InputEventMultiScreenDrag

#### Properties

* [Vector2](https://docs.godotengine.org/en/3.1/classes/class_vector2.html#class-vector2) **position**

MultiScreenDrag position (Average position of all the Drags involved).

* [Vector2](https://docs.godotengine.org/en/3.1/classes/class_vector2.html#class-vector2) **relative**

MultiScreenDrag position relative to its start position (Average relative of all the Drags involved).

* [Vector2](https://docs.godotengine.org/en/3.1/classes/class_vector2.html#class-vector2) **speed**

MultiScreenDrag speed (Average speed of all the Drags involved).

### InputEventScreenTwist

#### Properties

* [Vector2](https://docs.godotengine.org/en/3.1/classes/class_vector2.html#class-vector2) **position**

Twist center position.

* [float](https://docs.godotengine.org/en/3.1/classes/class_float.html) **relative**

Twist relative angle.

* [float](https://docs.godotengine.org/en/3.1/classes/class_float.html) **speed**

Twist speed (Average speed length of all the Drags involved).

## Mouse to gesture
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

