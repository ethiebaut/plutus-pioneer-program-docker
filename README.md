# plutus-pioneer-program-docker
Plutus Pioneer Program Docker environment.

## Usage
Please note:
* You need to have 6GB RAM free in your Docker environment, otherwise you will most likely get an error 137
* You need about 48GB of free disk space in your Docker environment

Just run:
```shell
docker run -d -p 8009:8009 ethiebaut/plutus-dev:3746610-ba0f4f3
```

The```3746610```version number corresponds to the plutus github project [tag](https://github.com/input-output-hk/plutus/commit/3746610) and the ```ba0f4f3``` tag matches the Plutus Pioneer Program [tag](https://github.com/input-output-hk/plutus-pioneer-program/commit/ba0f4f3).
This corresponds to the [updated](https://github.com/input-output-hk/plutus-pioneer-program/tree/updated) branch.

Docker images are available for the following version numbers:

| Plutus | Plutus Pioneer Program | Comment |
|--------|------------------------|---------|
| 3746610 | ba0f4f3 | First Cohort - [week 1](https://github.com/input-output-hk/plutus-pioneer-program/blob/71142569d0a2732e738fe75dd002a04f995533ef/code/week01/src/Week01/EnglishAuction.hs) & week 2<br/>_(Don't forget to delete the module statement for both weeks)_|
| 3aa8630 | ba0f4f3 | First Cohort - weeks 3- |


After the image has been pulled, wait for about a minute or so for all processes to start (you can check with```docker logs```) and connect to https://localhost:8009/.

All embedded demo examples should work.

You can also run the English Auction Plutus Pioneer Program with [this commit](https://github.com/input-output-hk/plutus-pioneer-program/blob/71142569d0a2732e738fe75dd002a04f995533ef/code/week01/src/Week01/EnglishAuction.hs) (don't forget to delete lines 18-30 if using Plutus 3746610).

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

### Acknowledgement / Source
Original Docker file can be downloaded from https://learning.lokdao.io/plutus-pioneer-program/week-1/setting-up-the-environment.

I had to update the image as a few steps were still manual and didn't work when I tried to build the image (libsodium-dev was missing).
The original code also didn't checkout a specific tag of the Plutus Pioneer Program github repository and therefore didn't work with the legacy Plutus code.

## Plutus Pioneer Program and Plutus documentation
| Page               | Location                                                                 |
|--------------------|--------------------------------------------------------------------------|
| Home & Apply | https://testnets.cardano.org/en/plutus-pioneer-program/ |
| Documentation      | https://plutus-pioneer-program.readthedocs.io/en/latest/ |
| Videos             | https://www.youtube.com/playlist?list=PLnPTB0CuBOBypVDf1oGcsvnJGJg8h-LII |
| Plutus documentation | https://docs.cardano.org/plutus/learn-about-plutus |
| Community Doc | https://docs.plutus-community.com/docs/setup/DockerCompose.html |
| Additional Docker-compose files | https://github.com/maccam912/ppp |
