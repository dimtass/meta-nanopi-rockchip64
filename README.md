meta-nanopi-rockchip64
----

This Yocto BSP meta-layer currently supports the following boards:
* nanopi-neo3
* nanopi-r2s

The layer is based on the [armbian](https://www.armbian.com/download/) image
and it uses the same u-boot and kernel patches as also other customizations
found in the Armbian image. The patches are located in:
* `u-boot`: recipes-bsp/u-boot/files/patches
* `kernel`: recipes-kernel/linux/linux-stable/patches

Also the patcher is ported from armbian and actually is the same for u-boot
and the kernel and is lcated in `scripts/armbian-patcher.sh`.

## How to use the layer
Create a folder for your project, then create a folder inside and name it
`sources`. You _have_ to use that name.

#### Cloning the needed layers
Then `git clone` this repo inside with `poky` and `meta-openembedded`.

```sh
cd sources
git clone git@bitbucket.org:dimtass/meta-allwinner-hx.git
git clone --depth 1 -b dunfell git://git.yoctoproject.org/poky
git clone --depth 1 -b dunfell git@github.com:openembedded/meta-openembedded.git
```

> Note: This layer is compatible with `warrior`, `zeus` and `dunfell`.

#### Setting the environment
Then from the `top` directory that includes the sources run this command:
```sh
ln -s sources/meta-allwinner-hx/scripts/setup-environment.sh .
ln -s sources/meta-allwinner-hx/scripts/flash_sd.sh .
```

Then your top dir contects should look like this:
```sh
flash_sd.sh
setup-environment.sh
sources
```

To setup the environment you need to choose the target SBC and set the
`MACHINE` variable and then run the script like this fromt the top directory:

```sh
MACHINE=nanopi-neo3 source ./setup-environment.sh build
```

This will setup the project and create a `build/` folder. Note that by default the
poky distro is used. Also, by default in this image all the Linux firmware
files are added in the image. If you want to save ~500MB then you can comment out the next
line, but then you need to add the specific firmware for your `MACHINE` with your own
recipe:
```sh
IMAGE_INSTALL += "armbian-firmware"
```

By default this repo is applying all the extra patches that armbian applies
in its images. Those are the `aufs` and a few extra wifi drivers.
This is enabled by default in the `local.conf` file and you can disable this
by setting the following variables to `no` instead of `yes`, which is the default.
```py
EXTRAWIFI = "yes"
AUFS = "yes"
```

> Note: For kernel versions > 5.4.x `WIREGUARD` is not used anymore, so always leave it to `off`.

#### Supported images
Currently there is only one supported image which is meant for testing the layer only
and it's this one:
* `rk-console-image`: Image with only debug console support (no GUI)

This image is provided only for testing purposes, therefore normally you should define
your own image or use this as a template and extend it further.

#### Control image extra space
Currently the extra free space for the image is set to 4GB. You can control the size
with the `ROOT_EXTRA_SPACE` variable in `classes/rk-create-wks.bbclass`.
If you want to remove all additional space then set it to `0`.

#### Build the image
To build the image use this command:

```sh
bitbake rk-console-image
```

This will build a console-only image.

## Current versions
* u-boot: `2020.07`
* Linux kernel: `5.7.17`

## Build the SDK
There's a known issue that some bb recipes that are used while the SDK is built
conflict with some packages. In this BSP the packages that are conflict are the
listed in the `SDK_CONFLICT_PACKAGES` variable, which is located in `meta-allwinner-hx/classes/package-groups.inc`.
Therefore, in case you add more packages in the image and the SDK is failing, then
you can add them in the `SDK_CONFLICT_PACKAGES`.

Then, when you setup the environment to build the image using the `meta-allwinner-hx/scripts/setup-environment.sh`
script, you can control if those packages will be added with the `REMOVE_SDK_CONFLICT_PKGS`
variable in the `local.conf`. By default this is set to `0`, but when you build the
SDK you need to set that to `1`.

To bulid the SDK run this command (after the environment is set)
```sh
bitbake -c populate_sdk rk-console-image
```

## Overlays
This layer supports overlays for the rockchip boards. In order to use them you need
to edit the `recipes-bsp/u-boot/files/rkEnv.txt` file or even better create
a new layer with your custom cofiguration and override the `rkEnv.txt` file by
pointing to your custom file in your `recipes-bsp/u-boot/u-boot_2020.07.bbappend`
with this line:

```sh
SRC_URI += "file://rkEnv.txt"
```

Of course, you need to create this file and place it in your layer file folder.
In that file you need to edit it and add the overlays you need, for example:

```sh
extra_bootargs=
rootfstype=ext4
verbosity=d
overlays=rockchip-i2c7 rockchip-spi-spidev
param_spidev_spi_bus=0
```

Some overlays (like the `spi-spidev`) get parameters as shown above. For more details
on the allwinner overlays always refer to the decumentation [here](https://docs.armbian.com/Hardware_Allwinner_overlays/)

## Flashing the image
After the image is build, you can use `bmaptool` to flash the image on your SD card.
To this you first need to install `bmap-tools`.
```sh
sudo apt-get install bmap-tools
```

Then you need to run `lsblk` to find the device path of the SD and only after
you verified the correct device then from your top directory run this:
```sh
sudo IMAGE=console MACHINE=nanopi-neo3 ./flash_sd.sh /dev/sdX
```

Or if you use the default values (`IMAGE=console` and `MACHINE=nanopi-neo3`) then:
```sh
sudo ./flash_sd.sh /dev/sdX
```

If you want to do the steps manually then:
```sh
sudo umount /dev/sdX*
sudo bmaptool copy <.wic.bz2_image_path> /dev/sdX
```

Of course you need to change `/dev/sdX` with you actuall SD card dev path.

> Note: In reality the produced images for the `nanopi-neo3` and `nanopi-r2s` are the same
and they are interchangable.


## Why bmap-tools and wic images?
Well, wic images are a no-brainer. You can create a 50GB image, but this image
probably won't be that large really. Most of the times, the real data bytes in
the image will be from a few hundreds MB, to maybe 1-2 GB. The rest will be
empty space. Therefore, if you build a binary image then this image will be
filled with zeros. You will also have to use `dd` to flash the image to the SD
card. That means that for a few MBs of real data, you'll wait maybe more than
an hour to be written in the SD. Wic creates a map of the data and creates an
image with the real binary data and a bmap file that has the map data. Then,
bmaptool will use this bmap file and create the partitions and only write the
real binary data. This will take a few seconds or minutes, even for images that
are a lot of GBs.

For example the default image size for this repo is 13.8GB but the real data
are ~62MB. Therefore, with a random SD card I have here the flashing takes
~14 secs and you get a 14GB image.

## Using Docker to build the image
For consistency reasons and also to keep your main OS clean of the bloat that
Yocto needs, you can use docker to build this repo. I've provided a Dockerfile
which you can use to build the image and I'm also listing some tips how to use
it properly, in case you have several different docker containers that need to
share the download or sstate-cache folder.

> Important: To build the docker image don't copy the `Dockerfile` from
`meta-nanopi-rockchip64/Dockerfile` to the parent folder (where `sources` folder is).
Always build the image inside `meta-nanopi-rockchip64/Docker/`, because this will save
you from sending the build context.

To build the docker image run this command:

```sh
docker build --build-arg userid=$(id -u) --build-arg groupid=$(id -g) -t yocto-builder-image .
```

This will create a new image named `yocto-builder-image` and you can run this
to verify that it exists.
```sh
docker images
```

Which returns:
```sh
REPOSITORY              TAG                 IMAGE ID            CREATED             SIZE
yocto-builder-image     latest              4e89467d537a        3 minutes ago       917MB
```

Now you can create a container and run (=attach) to it. You need to run this command
in the parent folder where you can see the `sources` folder that contains all the
meta-layers.
```sh
docker run -it --name yocto-builder -v $(pwd):/docker -w /docker yocto-builder-image bash
```

Then you can follow the standard procedure to build images. In case that you exit
the container, then you can just run it again and attach to it like this:
```sh
docker start yocto-builder
docker attach yocto-builder
```

#### Sharing download folder between several different builds
In case that you have several different yocto builds, it doens't make sense to
have a download folder for each build, because this means that you need much more
space and most of the files will be duplicated. To avoid this you can create a
`download` folder somewhere in your hard drive which can be shared from all
builds. If you don't use docker, then you just need to create this folder and
then create symlinks to every yocto build.

The problem with docker though, is that those symlinks don't work. Therefore, you
need to virtually mount the `external` folder to the docker container. To do that,
you need to create the container the first time with the correct options.

Let's assume that your shared download folder is this `/opt/yocto-downloads`.

First on the normal OS run this command:
```sh
ln -s /opt/yocto-downloads downloads
```

This is will create a symlink to the shared downloads folder.
Then to mount this folder to the docker container you need to run:
```sh
docker run -it --name yocto-builder -v $(pwd):/docker -v /opt/yocto-downloads:/docker/downloads -w /docker allwinner-yocto-image bash
```

Then you can build the yocto image inside the container as usual, e.g.:
```sh
yoctouser@dcca27f70336:/docker$ MACHINE=nanopi-neo3 source ./setup-environment.sh build
yoctouser@dcca27f70336:/docker$ bitbake rk-console-image
```

## Maintainer
Dimitris Tassopoulos <dimtass@gmail.com>