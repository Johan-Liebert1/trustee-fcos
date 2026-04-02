#!/bin/bash

set -eu

IMAGE=localhost/fcos-trustee-uki

sudo podman build --security-opt=label=disable --cap-add=all --device /dev/fuse \
    --skip-unused-stages=false -v "${PWD}:/run/src" --net=host . -t $IMAGE

truncate -s10G ./trustee-fcos.img

sudo podman run --rm --net=host --privileged --pid=host \
    --security-opt label=type:unconfined_t \
    --env RUST_LOG=debug \
    --env IMAGE="$IMAGE" \
    -v /dev:/dev \
    -v /var/lib/containers:/var/lib/containers \
    -v "$PWD:/output" \
    "$IMAGE" \
        bootc install to-disk \
            --source-imgref "containers-storage:$IMAGE" \
            --composefs-backend \
            --bootloader=systemd \
            --filesystem=ext4 \
            --uki-addon=ignition \
            --generic-image --via-loopback --wipe \
            /output/trustee-fcos.img
