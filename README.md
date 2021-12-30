# plutus-pioneer-program-docker
Plutus Pioneer Program Docker environment

## Usage
Please note:
* You need to have 6GB RAM free in your Docker environment, otherwise you will most likely get an error 137
* You need about 48GB of free disk space in your Docker environment

Just run:
```shell
docker run -d -p 8009:8009 ethiebaut/plutus-dev:3746610
```

The```3746610```version number corresponds to the plutus github project [tag](https://github.com/input-output-hk/plutus/commit/3746610).

After the image has been pulled, wait for about 30 seconds or so for all processes to start and connect to https://localhost:8009/.

All embedded demo examples should work.

You can also run the English Auction Plutus Pioneer Program with [this commit](https://github.com/input-output-hk/plutus-pioneer-program/blob/71142569d0a2732e738fe75dd002a04f995533ef/code/week01/src/Week01/EnglishAuction.hs) (don't forget to delete lines 18-30).

## To rebuild the image
In order to rebuild the docker image please note:
* It will take about 30 minutes to an hour
* It may not work if some dependencies have been updated
* You need to have 6GB RAM free in your Docker environment, otherwise the build will fail with error 137
* You need about 48GB of free disk space in your Docker environment, otherwise the build will fail with various "disk full" issues

Just run:
```shell
docker build -t plutus-dev .
```

### Trick in building the image
The``cabal build``command is run twice as it fails the first time due to missing apt dependencies.
However, the apt dependencies cannot be installed before the first build, otherwise the build fails to start.
Therefore, the build is performed a first time, its exit code ignored, then the apt dependencies are installed, and the build is run a second time.

### Acknowledgement / Source
Original Docker file can be downloaded from https://learning.lokdao.io/plutus-pioneer-program/week-1/setting-up-the-environment.

I had to update the image as a few steps were still manual and didn't work when I tried to build the image (some missing dependencies were missing).