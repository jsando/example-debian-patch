FROM debian:bookworm

# Add dev-src to install debian source packages
RUN set -eux; \
    sed -i 's/^Types: deb$/Types: deb deb-src/' /etc/apt/sources.list.d/debian.sources; \
    apt-get update

# Add common build deps
RUN set -eux; \
    apt-get install -y --no-install-recommends \
        build-essential fakeroot devscripts

# Get the source package we want to patch, along with its particular build dependencies
ARG HELLO_VERSION=hello-2.10
RUN set -eux; \
    mkdir -p /src/debian; \
    cd /src/debian; \
    apt-get build-dep -y hello; \
# To pin to a point in time you can update /etc/apt/sources.list.d/debian.sources to point to snapshot.debian.org (it's commented out)
# Or you can pull from git directly
    apt-get source hello; \
    cd ${HELLO_VERSION}

# Add our patch
ADD swedish-chef-greeting.patch /src/debian/${HELLO_VERSION}/debian/patches/
RUN echo "swedish-chef-greeting.patch" >> /src/debian/${HELLO_VERSION}/debian/patches/series

# Build
RUN set -eux; \
    cd /src/debian/${HELLO_VERSION}; \
    debuild -b -uc -us

# Install custom package
# If you're building an SDK docker image with this as one part, like I was, you probably want to put
# this whole build in a separate FROM layer, then use COPY --from to copy your custom .debs into the 
# final image, to avoid bringing all these build dependencies into your main image.
RUN dpkg -i /src/debian/hello_*.deb
