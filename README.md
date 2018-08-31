# Mew (μ)

iOS MicroViewController support library.

## Installation

### Carthage
The latest version is 0.1.0
```
github "mercari/Mew"
```

### CocoaPods
```
pod 'Mew', :git => 'https://github.com/mercari/Mew.git'
```

## Usage

### ContainerView with Manual Control 
1. Add `ContainerView` in your xib/code.
1. Add childViewController using `containerView.addArrangedViewController`.
1. 🎉

### ContainerView with `Container<T>`
1. Conform your ViewController classes as `Instantiatable`.
1. Conform your ViewController classes `Injectable`, `Interactable` if need.
1. Add `ContainerView` in your xib/code.
1. Add childViewController using `containerView.makeContainer`.
1. 🎉

## Reference
Replace with iOSDC presentation link.

## Supporting
|  | Supported |
----|---- 
| ContainerView | ✅ |
| Container<T> | ✅ |
| Environment, Testing support | WIP |
| UITableView support | WIP |
| UICollectionView support | WIP |

## Committers

All Mercari iOS team.

## Contribution

Please read the CLA below carefully before submitting your contribution.

https://www.mercari.com/cla/

## License

Copyright 2018 Mercari, Inc.

Licensed under the MIT License.
