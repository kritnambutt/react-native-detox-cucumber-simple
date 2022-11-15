#!/bin/bash

adb devices | grep "emulator-" | while read -r line ; do
    suffix="	device"
    emulatorInstanceName=${line%${suffix}}
    if [ "$emulatorInstanceName" != "offline" ]; then
      echo "Killing $emulatorInstanceName"
      adb -s "${emulatorInstanceName}" emu kill
    fi
done
