#  [AWS CLI version 2 Docker image](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2-docker.html)

    docker run --rm -it amazon/aws-cli command
    docker run --rm -it amazon/aws-cli --version

**Sharing host files, credentials, and configuration**
To share the host file system, credentials, and configuration to the container, mount the host system’s ~/.aws directory to the container at /root/.aws with the -v flag to the docker run command.

    docker run --rm -it -v ~/.aws:/root/.aws amazon/aws-cli <command> 

In this example, we're providing host credentials and configuration when running the s3 ls command to list your buckets in the Amazon Simple Storage Service. 

    docker run --rm -ti -v ~/.aws:/root/.aws amazon/aws-cli s3 ls

Add an alias to bash/zsh for easy use

    # basic access
    alias aws_docker='docker run --rm -it -v ~/.aws:/root/.aws amazon/aws-cli'

    # For access to the host file system and configuration settings when using aws commands: 
    alias aws_docker_volume='docker run --rm -ti -v ~/.aws:/root/.aws -v $(pwd):/aws amazon/aws-cli'