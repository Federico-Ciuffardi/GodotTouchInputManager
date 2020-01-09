# Godot Touch Input Manager
 Script to handle touch input. It also translates mouse input to gestures.

## How to use
* Dowload the InputManager.gd
* Put it inside of a node (or use [Autoload](https://docs.godotengine.org/en/3.1/getting_started/step_by_step/singletons_autoload.html)) and [connect](https://docs.godotengine.org/en/3.1/getting_started/step_by_step/signals.html) the signals to the nodes that will use the gesture associated with said signal.

## Supported gestures and it's signals:
| Name                      | Signal       | Args                               |
|---------------------------|--------------|------------------------------------|
| Single finger touch (tap) | single_touch | Vector2 position                   |
| Single finger drag        | single_drag  | Vector2 position, Vector2 relative |
| Pinch                     | pinch        | Vector2 position, float intensity  |
| Multiple finger drag      | multi_drag   | Vector2 position, Vector2 relative |


## Versioning
Using [SemVer](http://semver.org/) for versioning. For the versions available, see the [releases](https://github.com/Federico-Ciuffardi/IOSU/releases) 

## Authors
* Federico Ciuffardi
Feel free to append yourself here if you've made contributions.

## Note
Thank you for checking out this repository, you can send all your questions and feedback to Federico.Ciuffardi@outlook.com.

If you are up to contribute on some way please contact me :)
