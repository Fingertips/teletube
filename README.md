# Teletube

A command-line interface for interacting with the SWITCHtube web service.

# Install

## macOS

    brew install fingertips/tap/teletube

## From source

    git clone https://github.com/Fingertips/teletube.git
    cd teletube
    make install

# Configure

Go into your SWITCHtube account and follow the instructions to get an authentication token for the web service.

    teletube config --token <token>

If you need to operate on a different endpoint, usually for testing purposes, you can explicitly set the endpoint.

    teletube config --endpoint https://staging.tube.switch.ch

# Channels

Most interaction is around a channel so start by listing all channels you can upload to.

    teletube channels

Alternatively you can limit the number of channels by filtering your own channels or the ones you don't own, but can upload to.

    teletube channels list --role owner
    teletube channels list --role contributor
