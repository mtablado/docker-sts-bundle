# docker-sts-bundle
This image will empower you to work with Spring Tools Suite in a Docker container.

## What's inside the image?
 - Open JDK 8
 - Spring Tool Suite.
 - Maven

## How to configure

### Configure X11
The selected way of running `X11` inside the container is by sharing the X socket. So a volume must be created like this:`/tmp/.X11-unix:/tmp/.X11-unix `
Also, you need to add the following environment property `DISPLAY=$DISPLAY`

### Creating the correct user
This image is prepared for working with user home directory so that you can share your user maven configuration with any of the containers that you run.

So, you the image will need to create the same user and group (id's included!).

To configure it properly run `id` command and look at the results to configure your build.

An example:
```
mtablado@saib-mtablado-ubuntu:~/devel/work$ id
uid=1001(mtablado) gid=1001(mtablado) grupos=1001(mtablado),27(sudo)
```
So the `args` section would be:
```
args:
	- user=mtablado
    - uid=1001
    - group=mtablado
    - gid=1001
```
### Binding volumes
- Bind your `.m2` directory if you want to persist configuration and already downloaded dependencies.
- Bind your sources directory to keep your code after removing your container.
- Bind your workspaces directory to avoid configuring your IDE once and again

```
volumes:
	- /tmp/.X11-unix:/tmp/.X11-unix 
    - /home/mtablado/devel:/home/mtablado/devel
    - /home/mtablado/.m2:/home/mtablado/.m2
```
**NOTE:** sources and workspaces are in `/home/mtablado/devel` directory.

## Notes
- This solution has been tested on ubuntu 16.04 (as Docker host)
- You must add port binding to meet your requirments, usually `"8080:8080"`
- You can add extra volume binding for your purposes
