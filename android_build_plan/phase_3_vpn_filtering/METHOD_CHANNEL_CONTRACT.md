# Focus Shield MethodChannel Contract

## Channel Name

focus_shield/protection

## Flutter Calls Native Android

### startProtection

Starts the Android VPN/DNS filtering service.

Payload: none

Expected response: started

### stopProtection

Stops the Android VPN/DNS filtering service.

Payload: none

Expected response: stopped

### protectionStatus

Returns native protection state.

Expected response:

vpnActive: true or false
blocklistLoaded: true or false
blockedDomainCount: number

### reloadBlocklist

Reloads saved blocked domains from local storage/database.

Expected response: reloaded

## Native Android Responsibilities

- Request VPN permission
- Start VPN service
- Maintain foreground protection service
- Read saved blocklist
- Apply DNS filtering
- Return service status to Flutter
