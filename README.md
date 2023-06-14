# Teletube

A command-line interface for interacting with the SWITCHtube web service.

# Install

## macOS

    brew install fingertips/tap/teletube

If want to format or transform the resulting JSON is can be useful to install `jq`.

    brew install jq

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

Start by listing all channels you can access.

    teletube channels

Or filter the channels you own, or the channels you may contribute to.

    teletube channels list --role owner
    teletube channels list --role contributor

# Upload a video

    teletube files upload FILE.MOV

This should print a NO_CONTENT response for every 50 megabytes uploaded. Error messages are handled as long as the command keeps running.

Copy-paste the characters after 📃, this is the upload id.

You can use a channel id, upload id, and a title to create a new video with the upload.

    teletube videos create --channel-id <id> --upload-id <id> --title "Very serious video about nature."

You can set other details about the video too, please use `--help` to see them.

    teletube videos create --help

# Videos

Look up a channel id with the channels listing explained earlier. Then you can list all videos in that channel.

    teletube videos list --channel-id <id>

# Files

A video may have multiple files, one for each attempted processing job.

    teletube files list --video-id <id>

Each will have a URL and an optional original files. You can attempt to download the latest file uploaded this way.

    teletube files download --video-id <id>

Keep in mind that the download URLs will expire, so you shouldn't share them with others.

# Upload a document with a video

    teletube files upload DOCUMENT.DOCX

This should print a NO_CONTENT response for every 50 megabytes uploaded. Error messages are handled as long as the command keeps running.

Copy-paste the characters after 📃, this is the upload id.

You can use a video id and upload id, to create a new document with the upload.

    teletube documents create --video-id <id> --upload-id

# Upload a new avatar for a profile

    teletube files upload AVATAR.JPG

This should print a NO_CONTENT response for every 50 megabytes uploaded. Error messages are handled as long as the command keeps running.

Copy-paste the characters after 📃, this is the upload id.

You can create a new avatar with the upload id.

    teletube avatars create --upload-id <upload-id>

# Help

You can always end a command with `--help` to get more details. For example:

    teletube --help
    teletube browse --help
    teletube browse poster --help
    
#  JSON

Status information about the command is printed to `stderr`. JSON responses are written to `stdout` so you can use tools like `jq` to get details.

For example, you can format the JSON for readability.

    teletube channels list --role owner | jq

Or you can transform it to only show the `id` and `name`.

    teletube channels list --role owner | jq ".[] | {id: .id, name: .name}"

The best way to learn `jq` is through the tutorial [https://stedolan.github.io/jq/tutorial/](https://stedolan.github.io/jq/tutorial/) and trying it out on [https://jqplay.org](https://jqplay.org).