# Publican

🧔 The package that will help you out with Dart's Pub 🎯

## Getting started

Bring **publican** to your global dependencies:

```shell
pub global activate publican
```

## Commands

### `publican init`

Initializes a `pubspec.yaml` file.

```shell
mkdir my_awesome_app
cd  my_awesome_app
publican init
```

It will generate a `pubspec.yaml` file with the following defaults:

```yaml
name: my_app
version: 0.1.0
description: My awesome Dart app
```

You can override default values throught the options:

```shell
-n, --name           (defaults to "my_app")
-v, --version        (defaults to "0.1.0")
-d, --description    (defaults to "My awesome Dart app")
```

_Note: it will not override your current pubspec.yaml file, if you already have one, its safe._

