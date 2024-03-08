# Patching a debian source package

This is an example of applying a custom patch to a debian source package, in this case the 'hello' package.

Recently I needed to make a custom version of a debian -dev package.  This was not any kind of fix or feature that should go upstream, it was simply there was a C++ header defining a type slightly different than a library we were using and the simplest path was to change both typedefs to be the same.

Building and running:

```bash
docker build -t patch-demo .
docker run --rm -it patch-demo hello
```

Output:

```
Hellu, vurld! Bork Bork Bork!
```

# Creating the patch

Edit the dockerfile to comment out the build, build it and run bash in the docker image.

https://wiki.debian.org/UsingQuilt

```bash
export QUILT_PATCHES=debian/patches
export QUILT_REFRESH_ARGS="-p ab --no-timestamps --no-index"
apt-get install quilt vim
quilt new swedish-chef-greeting.patch
quilt add src/hello.c 
vi src/hello.c ...
quilt refresh
quilt pop -a
```

To add more changes later ie, when you realize the test are now broken and have to be patched as well ;)

```bash
quilt push swedish-chef-greeting.patch
quilt add tests/hello-1
vi tests/hello-1 ...
quilt refresh
quilt pop -a
```