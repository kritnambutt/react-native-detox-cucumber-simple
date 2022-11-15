#!/usr/bin/env bash

AVD_NAMES=(Pixel_3a_API_30)
BASE_DIR=$PWD
# Initially setup emulator with hosts entries and install CA certificate into system store
wait_emulator_ready() {
    adb -e wait-for-device
    {
    while [ "$(adb -e shell getprop init.svc.bootanim || true)" != "stopped" ]
    do
        sleep 0.5
    done
    } >/dev/null 2>&1
    sleep 3
}

wait_package_service() {
    {
    while [ -z "$(adb -e shell service list | grep package:)" ]
    do
        sleep 0.5
    done
    } >/dev/null 2>&1
    sleep 3
}

replace_avd_config_value() {
  # $1 is config name
  # $2 is config expected value
  echo "Configuring $1 to $2"
  sed -i.bak '/^'"$1"'=/{
  h
  s/=.*/='"$2"'/
  }
  ${
  x
  /^$/{
  s//'"$1"'='"$2"'/
  H
  }
  x
  }' ./config.ini
}

reboot_emulator () {
  adb -e reboot
  echo '#####################################'
  echo 'Rebooting emulator...'
  wait_emulator_ready
}


setup_emulator () {
  AVD_NAME=$1
  INSTALL_BUTLER=$2

  # kill any running android
  adb -e emu kill || true > /dev/null

  #  need to set here to prevent coldboot
  pushd "$HOME"/.android/avd/"$AVD_NAME".avd || return 1
  replace_avd_config_value "hw.keyboard" "yes"
  popd || return 1

  cd "$BASE_DIR" || return 1
  echo "########## Current Path #############"
  echo "$BASE_DIR"
  echo '#####################################'
  echo "Starting the $AVD_NAME emulator..."
  nohup emulator -avd "$AVD_NAME" -writable-system -netdelay none -netspeed full -gpu on -no-snapshot-load -wipe-data >/dev/null 2>&1 &
#  nohup emulator -avd "$AVD_NAME" -writable-system -netdelay none -netspeed full -gpu on -memory 4096 -no-snapshot-load -wipe-data >/dev/null 2>&1 &

  wait_emulator_ready

  echo '#####################################'
  echo 'Waiting for the package service to come online...'
  wait_package_service

  if [ $INSTALL_BUTLER = "yes" ]; then
    echo '#####################################'
    echo 'Installing Test Butler 2.2.1'
    curl -f -o ./test-butler-app.apk https://repo1.maven.org/maven2/com/linkedin/testbutler/test-butler-app/2.2.1/test-butler-app-2.2.1.apk
    {
      while [ "$(adb -e install -r -t ./test-butler-app.apk | tail -1)" != "Success" ]
      do
        echo "Installation: failed. Let's wait a little bit ..."
        sleep 5
      done
    }
    echo 'Test Butler installed'
    #adb install -r -t ./test-butler-app.apk
    rm ./test-butler-app.apk
  fi

  echo '#####################################'
  echo 'Disabling verity...'
  adb -e root
  sleep 3
  adb -e shell avbctl disable-verification

  reboot_emulator

  echo '#####################################'
  echo 'Making system partition writable...'
  adb -e root
  sleep 3
  adb -e remount

  reboot_emulator

  echo '#####################################'
  echo 'Copying hosts file and root CA certificate to the emulator...'
  sleep 10
  adb -e root
  sleep 3
  adb -e remount
  adb -e push ../services/simulators/okta-simulator/src/main/resources/keystore/hosts /etc/hosts
  adb -e push ../services/simulators/okta-simulator/src/main/resources/keystore/22cd0483.0 /system/etc/security/cacerts
  adb shell chmod 664 /system/etc/security/cacerts/22cd0483.0
  reboot_emulator

  echo 'Kill the emulator now'
  sleep 30 # waiting a little bit more. hoping the image to be stable
  # adb emu kill is having problem with emulator 31.2.x on Apple Silicon
  # causing the state to not be saved properly
  # https://issuetracker.google.com/issues/226444797
  # test again after 31.3.x go to stable channel
  adb -e emu kill

  echo '#####################################'
  echo 'Customizing config.ini to force fastboot...'
  cd "$HOME"/.android/avd/"$AVD_NAME".avd || return 1
  replace_avd_config_value "fastboot.chosenSnapshotFile" ""
  replace_avd_config_value "fastboot.forceChosenSnapshotBoot" "no"
  replace_avd_config_value "fastboot.forceColdBoot" "no"
  replace_avd_config_value "fastboot.forceFastBoot" "yes"

  echo '#####################################'
  echo 'Finished!'
}
if [ -z "$1" ]; then
  setup_emulator "${AVD_NAMES[0]}" "yes"
#  setup_emulator "${AVD_NAMES[1]}" "no"
else
  if [ "$1" == "0" ]; then
    setup_emulator "${AVD_NAMES[0]}" "yes"
  elif [ "$1" == "1" ]; then
    setup_emulator "${AVD_NAMES[1]}" "no"
  elif [ "$1" == "2" ]; then
    setup_emulator "${AVD_NAMES[2]}" "yes"
  else
    setup_emulator "$1" "yes"
  fi
fi
