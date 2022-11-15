#!/usr/bin/env bash

AVD_NAMES=(Pixel3_API_30 Pixel3_API_30_GOOGLE Galaxy_S20_FE_API_30)

function is_apple_silicon() {
  if [[ $(sysctl -n machdep.cpu.brand_string) == *"Apple"* ]]; then
    echo "yes"
  else
    echo "no"
  fi
}

IS_APPLE_SILICON=$(is_apple_silicon)

# remove current minikube cluster IP from known_hosts to avoid man-in-the-middle attack error
# copy as a backup
cp ~/.ssh/known_hosts ~/.ssh/known_hosts.bak
# we could use sed here but there are syntax differences between mac-sed and gnu-sed
# in the case, awk is sufficient
awk '!/^'$(eval minikube ip)/'' ~/.ssh/known_hosts.bak > ~/.ssh/known_hosts

echo 'Killing any old ssh tunnel to minikube...'
lsof -t -i :40443 | xargs kill -9  >/dev/null 2>&1
lsof -t -i :40080 | xargs kill -9  >/dev/null 2>&1

echo 'Port forwarding enabled! Host:40443 -> Minikube:443'

# Setup ssh tunnel from Host to Minikube
echo 'Starting ssh tunnel from host to minikube'

if [ "$IS_APPLE_SILICON" == "yes" ]; then
  # For Apple Silicon, assuming minikube was started with `minikube start --vm=true --driver=docker`
  ssh -o IdentitiesOnly=yes -fN -oStrictHostKeyChecking=no -i $(minikube ssh-key) docker@127.0.0.1 -p $(docker inspect -f '{{(index (index .NetworkSettings.Ports "22/tcp") 0).HostPort}}' minikube) -L 40443:localhost:443
  ssh -o IdentitiesOnly=yes -fN -oStrictHostKeyChecking=no -i $(minikube ssh-key) docker@127.0.0.1 -p $(docker inspect -f '{{(index (index .NetworkSettings.Ports "22/tcp") 0).HostPort}}' minikube) -L 40080:localhost:80
else
  ssh -fN -oStrictHostKeyChecking=no -i $(minikube ssh-key) docker@$(minikube ip) -L 40443:localhost:443
  ssh -fN -oStrictHostKeyChecking=no -i $(minikube ssh-key) docker@$(minikube ip) -L 40080:localhost:80
fi

start_emulator() {
    AVD_NAME=$1

    # Start the emulator
    echo "Starting Android emulator ($AVD_NAME) ..."
    nohup emulator -avd "$AVD_NAME" -writable-system -no-boot-anim -netdelay none -netspeed full -gpu on -no-snapshot-save >/dev/null 2>&1 &
#    nohup emulator -avd "$AVD_NAME" -writable-system -no-boot-anim -netdelay none -netspeed full -gpu on -memory 4096 -no-snapshot-save >/dev/null 2>&1 &

    echo 'Waiting for Android emulator to start before enabling port forwarding...'

    # Set port forwarding as soon as emulator is started
    sh ../ci/scripts/wait-emulator-up.sh >/dev/null 2>&1
}

if [ -z "$1" ]; then
    start_emulator "${AVD_NAMES[0]}"
else
    start_emulator "$1"
fi
