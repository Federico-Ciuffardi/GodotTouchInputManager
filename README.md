<img src="https://i.imgur.com/HxwBAK2.png" align="right" />

# Godot Touch Input Manager
Godot Touch Input Manager (GDTIM) is an asset that improves touch input support (includes [new gestures](#supported-gestures)) in the Godot game engine. You just need to autoload a script and it will start analyzing the touch input. When a gesture is detected a Custom Input Event corresponding to the detected gesture will be created and [fed up](https://docs.godotengine.org/en/stable/classes/class_input.html#class-input-method-parse-input-event) to the Godot built in Input Event system so it triggers functions like [`_input(InputEvent event)`](https://docs.godotengine.org/en/stable/classes/class_node.html#class-node-method-input). There is also a signal for each gesture if you prefer using signals to the aforementioned.

There are two active PRs that add some GDTIM gestures as native Godot events, one for [version 3.x](https://github.com/godotengine/godot/pull/37754) and one for [version 4.x](https://github.com/godotengine/godot/pull/39055), if you are interested, please show your support there.

## Table of contents
* [How to use](#how-to-use)
* [Examples](#examples)
* [Documentation](#documentation)
* [FAQ](#faq)

## How to use
* Download the latest release from https://github.com/Federico-Ciuffardi/Godot-Touch-Input-Manager/releases
* Extract the downloaded *.zip* file somewhere in you project
* Locate the extracted `InputManager.gd`, and [Autoload](https://docs.godotengine.org/en/3.4/tutorials/scripting/singletons_autoload.html) it.
* Done! Now you can use GDTIM [signals and Custom Input Events](#supported-gestures).

## Examples
### [GodotTouchInputManager-Demo](https://github.com/Federico-Ciuffardi/GodotTouchInputManager-Demo)
![Demo](https://media.giphy.com/media/wnMStTBUdhQcnXLXpB/giphy.gif)
### [GestureControlledCamera2D](https://github.com/Federico-Ciuffardi/GestureControlledCamera2D)
![Demo](https://media.giphy.com/media/Xzdynnlx4XAqndgVe0/giphy.gif)

## Documentation

* [Supported gestures](#supported-gestures)
* [Gesture emulation](#gesture-emulation)
* [Configuration](#configuration)

### Supported gestures 

| Gesture name               | Signal            | Custom input event / Signal arg                                                                                                       | Description                                  |
|----------------------------|-------------------|---------------------------------------------------------------------------------------------------------------------------------------|----------------------------------------------|
| Single finger touch        | single_touch      | [InputEventSingleScreenTouch](https://github.com/Federico-Ciuffardi/Godot-Touch-Input-Manager/wiki/InputEventSingleScreenTouch)       | Touch with a single finger                   |
| Single finger tap          | single_tap        | [InputEventSingleScreenTap](https://github.com/Federico-Ciuffardi/Godot-Touch-Input-Manager/wiki/InputEventSingleScreenTap)           | Fast press and release with a single finger  |
| Single finger long press   | single_long_press | [InputEventSingleScreenLongPress](https://github.com/Federico-Ciuffardi/Godot-Touch-Input-Manager/wiki/InputEventSingleScreenLongPress)   | Press and hold with a single finger          |
| Single finger drag         | single_drag       | [InputEventSingleScreenDrag](https://github.com/Federico-Ciuffardi/Godot-Touch-Input-Manager/wiki/InputEventSingleScreenDrag)         | Drag with a single finger                    |
| Single finger swipe        | single_swipe      | [InputEventSingleScreenSwipe](https://github.com/Federico-Ciuffardi/Godot-Touch-Input-Manager/wiki/InputEventSingleScreenSwipe)       | Fast drag and release with a single finger   |
| Multiple finger tap        | multi_tap         | [InputEventMultiScreenTap](https://github.com/Federico-Ciuffardi/Godot-Touch-Input-Manager/wiki/InputEventMultiScreenTap)             | Fast press and release with multiple fingers |
| Multiple finger long press | multi_long_press  | [InputEventMultiScreenLongPress](https://github.com/Federico-Ciuffardi/Godot-Touch-Input-Manager/wiki/InputEventMultiScreenLongPress) | Press and hold with multiple fingers         |
| Multiple finger drag       | multi_drag        | [InputEventMultiScreenDrag](https://github.com/Federico-Ciuffardi/Godot-Touch-Input-Manager/wiki/InputEventMultiScreenDrag)           | Drag with multiple fingers (same direction)  |
| Multiple finger swipe      | multi_swipe       | [InputEventMultiScreenTap](https://github.com/Federico-Ciuffardi/Godot-Touch-Input-Manager/wiki/InputEventMultiScreenTap)             | Fast drag and release with multiple fingers  |
| Pinch                      | pinch             | [InputEventScreenPinch](https://github.com/Federico-Ciuffardi/Godot-Touch-Input-Manager/wiki/InputEventScreenPinch)                   | Drag with multiple fingers (inward/outward)  |
| Twist                      | twist             | [InputEventScreenTwist](https://github.com/Federico-Ciuffardi/Godot-Touch-Input-Manager/wiki/InputEventScreenTwist)                   | Drag with multiple fingers (rotate)          |
| Raw gesture              | raw_gesture       | [RawGesture](https://github.com/Federico-Ciuffardi/Godot-Touch-Input-Manager/wiki/RawGesture)                                   | Raw gesture state

When one of these gestures is detected a Custom Input Event corresponding to the detected gesture will be created and [fed up](https://docs.godotengine.org/en/stable/classes/class_input.html#class-input-method-parse-input-event) to the Godot built in Input Event system so it triggers functions like [`_input(InputEvent event)`](https://docs.godotengine.org/en/stable/classes/class_node.html#class-node-method-input).

### Gesture emulation

The gestures can be triggered by named [input actions](https://docs.godotengine.org/en/stable/tutorials/inputs/input_examples.html#inputmap) with specific names. If the input
action does not exists there is a default event that will trigger the gesture.

The following table shows the default event and the names of the input actions
that will trigger each of the gestures that can be emulated.

| Gesture name                       | Input action name       | Default event |
|------------------------------------|-------------------------|---------------|
| Single touch                       | single_touch            | **\***        |
| Multiple touch (2 fingers)         | multi_touch             | Middle click  |
| Pinch (outward)                    | pinch_outward           | Scroll up     |
| Pinch (inward)                     | pinch_inward            | Scroll down   |
| Twist                              | twist                   | Right click   |
| Single finger swipe (up)           | single_swipe_up         | w             |
| Single finger swipe (up-right)     | single_swipe_up_right   | e             |
| Single finger swipe (right)        | single_swipe_right      | d             |
| Single finger swipe (down-right)   | single_swipe_down_right | c             |
| Single finger swipe (down)         | single_swipe_down       | x             |
| Single finger swipe (down-left)    | single_swipe_down_left  | z             |
| Single finger swipe (left)         | single_swipe_left       | a             |
| Single finger swipe (left-up)      | single_swipe_up_left    | q             |
| Multiple finger swipe (up)         | multi_swipe_up          | i             |
| Multiple finger swipe (up-right)   | multi_swipe_up_right    | o             |
| Multiple finger swipe (right)      | multi_swipe_right       | l             |
| Multiple finger swipe (down-right) | multi_swipe_down_right  | .             |
| Multiple finger swipe (down)       | multi_swipe_down        | ,             |
| Multiple finger swipe (down-left)  | multi_swipe_down_left   | m             |
| Multiple finger swipe (left)       | multi_swipe_left        | j             |
| Multiple finger swipe (left-up)    | multi_swipe_up_left     | u             |

**\*** There are two options to enable single finger gestures:
1. Go to **Project > Project Settings > General > Input Devices > Pointing**
   and turn on *Emulate Touch From Mouse* to emulate a single finger touch with
   the left click. 
2. Go to **Project > Project Settings > General > Input Devices > Pointing**
   and turn off both *Emulate Touch From Mouse* and *Emulate Mouse From Touch*.
   Then set an input action called `single_touch`.

## Configuration

These are located in the first lines of [InputManager.gd](https://github.com/Federico-Ciuffardi/Godot-Touch-Input-Manager/blob/master/InputManager.gd), to change them modify the 
values on the script.

| Name                           | Default value | Description                                                                                                                                                                                                                                                                            |
|--------------------------------|---------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| DEFAULT_BINDIGS                | true          | Enable or disable default events for [gesture emulation](#gesture-emulation)                                                                                                                                                                                                           |
| DEBUG                          | false         | Enable or disable debug information                                                                                                                                                                                                                                                    |
| DRAG_STARTUP_TIME              | 0.2           | Seconds from the first native drag event to the first [single finger drag](#gestures-supported) custom event                                                                                                                                                                           |
| FINGER_SIZE                    | 100.0         | The distance between the fingers must be less than `fingers*FINGER_SIZE` pixels for the [multiple finger tap](#supported-gestures) and [multiple finger swipe](#supported-gestures) gestures to be recognized. Setting it to `INF` removes this restriction.                         |
| MULTI_FINGER_RELEASE_THRESHOLD | 0.1           | All fingers must be released within `MULTI_FINGER_REALEASE_THRESHOLD` seconds before the gesture ends for the [multiple finger tap](#gestures-supported) and [multiple finger swipe](#gestures-supported) gestures to be recognized                                                  |
| TAP_TIME_LIMIT                 | 0.2           | The time between the first press and the last release must be less than `TAP_TIME_LIMIT` seconds for the [single finger tap](#supported-gestures) and [multiple finger tap](#supported-gestures)  gestures to be recognized                                                          |
| TAP_DISTANCE_LIMIT             | 25.0          | The centroid of the finger presses must differ less than `TAP_DISTANCE_LIMIT` pixels from the centroid of the finger releases for the [single finger tap](#supported-gestures) and [multiple finger tap](#supported-gestures)  gestures to be recognized.                            |
| SWIPE_TIME_LIMIT               | 0.5           | The time between the first press and the last release must be less than `SWIPE_TIME_LIMIT` seconds for the [single finger swipe](#supported-gestures) and [multiple finger swipe](#supported-gestures)  gestures to be recognized.                                                   |
| SWIPE_DISTANCE_THRESHOLD       | 200.0         | The centroid of the finger presses must differ by more than `SWIPE_DISTANCE_THRESHOLD` pixels from the centroid of the finger releases for the [single finger swipe](#supported-gestures) and [multiple finger swipe](#supported-gestures) gestures to be recognized.                |
| LONG_PRESS_TIME_THRESHOLD      | 0.75          | The fingers must press for `LONG_PRESS_TIME_THRESHOLD` seconds for [single-finger long press](#gestures-supported) and [multi-finger long press](#gestures-supported) gestures to be recognized.                                                                                     |
| LONG_PRESS_DISTANCE_LIMIT      | 25.0          | The centroid of the finger presses must differ less than `LONG_PRESS_DISTANCE_LIMIT` pixels from the centroid of the fingers last positions for the [single finger long press](#supported-gestures) and [multiple finger long press](#supported-gestures) gestures to be recognized. |

## FAQ
### How can I get GDTIM to work when using control nodes?

By default, the control nodes consume events and therefore GDTIM cannot analyze them. To prevent this, set `Mouse>Filter` to `Ignore` on control nodes as needed.

![image](https://user-images.githubusercontent.com/45585143/235382152-1c99f7eb-eed3-4f96-b1b2-ba0a899d5225.png)

For more information see the [documentation](https://docs.godotengine.org/en/stable/classes/class_control.html#enum-control-mousefilter).

### GDTIM events don't trigger collisions, is there a way to fix it?

Custom input events do not trigger collisions, at the moment the solution is to manually check for collisions between shapes and events. For more information and ideas on how to do this see [this issue](https://github.com/Federico-Ciuffardi/GodotTouchInputManager/issues/16).

## Versioning
Using [SemVer](http://semver.org/) for versioning. For the versions available, see the [releases](https://github.com/Federico-Ciuffardi/Godot-Touch-Input-Manager/releases).

## Authors
* Federico Ciuffardi

Feel free to append yourself here if you've made contributions.

## Note
Thank you for checking out this repository, you can send all your questions and comments to Federico.Ciuffardi@outlook.com.

If you are willing to contribute in any way, please contact me.
