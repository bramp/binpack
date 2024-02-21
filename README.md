Simple library for 2D bin packing, as used for texture atlases.

[![Pub package](https://img.shields.io/pub/v/binpack.svg)](https://pub.dev/packages/binpack)
[![Pub publisher](https://img.shields.io/pub/publisher/binpack.svg)](https://pub.dev/publishers/bramp.net/packages)
[![Dart Analysis](https://github.com/bramp/binpack/actions/workflows/dart.yml/badge.svg)](https://github.com/bramp/binpack/actions/workflows/dart.yml)

## Features

Takes a list of rectangles and packs them into a larger rectangle, with the goal
of minimizing the larger rectangle's size.

Uses the algorithm described at https://github.com/TeamHypersomnia/rectpack2D

## Usage

```dart
import 'package:binpack/binpack.dart';

// Create a list of key and rectanges.
// The key can be anything specific to your application.
final rects = [
    ('image1.png', Rectangle(0, 0, 100, 200)), // Image 100x200 pixels
    ('image2.png', Rectangle(0, 0, 32, 64)),
    ('image3.png', Rectangle(0, 0, 128, 100)),
    ('image4.png', Rectangle(0, 0, 300, 400)),
];

// Target the max size 4096 x 4096
final results = Binpacker(4096, 4096).pack(rects);

// The rectangles are now packed and their positions available:
print(results.placements);

```

## Example

Packing 168 rects (from a game) into 4060x4065, with 95.7% efficiency.
![Example Packed Image](https://github.com/bramp/binpack/blob/main/images/output.svg)