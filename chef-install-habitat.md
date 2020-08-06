# Install Chef Habitat on the Workstation Ubuntu 20.04

## Install Habitat

If you're using a Linux workstation, you can just execute the command below
```
$ curl https://raw.githubusercontent.com/habitat-sh/habitat/master/components/hab/install.sh | sudo bash
```

Otherwise, visit the page below and grab the habitat package for your operational system:
https://www.habitat.sh/docs/install-habitat/


## Check your installation is running and accept the EULA

```
$ hab --version
```

and type **yes**


## Define a Habitat Origin and export variable

A `Habit Origin` is a keypair used to sign packages to garantee it's authenticity.

You can use any name that identify your place/company/project to sign your package.

```
$ export HAB_ORIGIN=ronans-habitat
```

## Generate a Origin keypair

```
$ hab origin key generate ronans-habitat
```

The generated keys will live in home directory under ~/.hab/cache/keys/:

```
$ ls -l ~/.hab/cache/keys/
```

**Once your origin environment variable has been set and your origin keys generated, you've set up the Habitat CLI**