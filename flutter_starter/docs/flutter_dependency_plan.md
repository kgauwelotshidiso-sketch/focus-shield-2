# Focus Shield Flutter Dependency Plan

Future dependencies for the real Flutter project.

## Core packages

sqflite
path
path_provider
flutter_secure_storage

## State management

provider

or

flutter_riverpod

Choose one, not both at the start.

## Android permissions

permission_handler

## Future native bridge

MethodChannel and EventChannel are built into Flutter services, so no extra package is required for the basic bridge.

## Security note

PIN hashes and protected settings should use secure storage where appropriate.
SQLite stores app data.
Secure storage protects sensitive lock material.
