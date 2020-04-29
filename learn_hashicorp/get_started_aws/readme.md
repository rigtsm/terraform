
# Get Started - AWS
 [Providers](https://www.terraform.io/docs/providers/aws/index.html)

Build, change, and destroy AWS infrastructure using Terraform. Step-by-step, command-line tutorials will walk you through the Terraform basics for the first time.

## 1 Introduction to Infrastructure as Code with Terraform

[Download Terraform](https://www.terraform.io/downloads.html) : extract the binary and move it to /usr/bin or add its path to .profile file


    mv terraform /usr/bin

    nano .profile
    # add the following line
    export PATH="$PATH:<path to terraform binary>
    source .profile
    terraform --veriosn
    terraform -install-autocomplete

Tutorial: 

    mkdir terraform-docker-demo && cd $_ 

Initialize the project, which downloads a plugin that allows Terraform to interact with Docker.

    terraform init

Provision the NGINX server container with apply. When Terraform asks you to confirm type yes and press ENTER

    terraform apply
    docker ps
    lynx localhost:8000

    terraform destroy


## [Build Infrastructure](https://learn.hashicorp.com/terraform/getting-started/build)

The set of files used to describe infrastructure in Terraform is known as a Terraform configuration. We will write a configuration to launch a single AWS EC2 instance.

    mkdir learn-terraform-aws-instance

- [Providers](https://www.terraform.io/docs/providers/aws/index.html)

The provider block is used to configure the named provider, in our case "aws". A provider is responsible for creating and managing resources. A provider is a plugin that Terraform uses to translate the API interactions with the service. A provider is responsible for understanding API interactions and exposing resources. Because Terraform can interact with any API, almost any infrastructure type can be represented as a resource in Terraform.

    provider "aws" {
        region = "us-east-1"
        profile = "default"
    }

    resource "aws_instanece" "example" {
        ami           = "ami-2757f631"
        instance_type = "t2.micro"
    }

- Resources
    - The resource block defines a piece of infrastructure. A resource might be a physical component such as an EC2 instance, or it can be a logical resource such as a Heroku application. 
    - The resource block has two strings before the block: the resource type and the resource name. 
    - The prefix of the type **maps to the provider**. In our case "aws_instance" automatically tells Terraform that it is managed by the "aws" provider.
    - The arguments for the resource are within the resource block.
    - For your EC2 instance, you specified an AMI for Ubuntu, and requested a "t2.micro" instance so you qualify under the free tier.

### Initialization
The first command to run for a **new configuration** -- or after checking out an existing configuration from version control -- is **terraform init**. Subsequent commands will use local settings and data that are initialized by terraform init.
The terraform init command downloads and installs providers used within the configuration, which in this case is the aws provider.

    terraform init

Terraform downloads the aws provider and installs it in a hidden subdirectory of the current working directory.


### Formatting and Validating Configurations
The terraform fmt command enables standardization which automatically updates configurations in the current directory for easy readability and consistency.

    terraform fmt
    terraform validate # this is important to check errors

If you are copying configuration snippets or just want to make sure your configuration is syntactically valid and internally consistent, the built in terraform validate command will check and report errors within modules, attribute names, and value types.

### Apply Changes

    terraform apply

This output shows the execution plan, describing which actions Terraform will take in order to change real infrastructure to match the configuration. 
Terraform also wrote some data into the **terraform.tfstate** file. This state file is extremely important; it keeps track of the IDs of created resources so that Terraform knows what it is managing. This file must be saved and distributed to anyone who might run Terraform.

You can inspect the current state using 

    terraform show

## Change Infrastructure
Infrastructure is continuously evolving, and Terraform was built to help manage and enact that change. As you change Terraform configurations, Terraform builds an execution plan that only modifies what is necessary to reach your desired state.
Let's modify the ami of our instance of the previous example. Edit the aws_instance.example resource under your provider block in your configuration and change it to the following:

    aw_instance.example.ami = "ami-b374d5a5"

We've changed the AMI from being an Ubuntu 16.04 LTS AMI to being an Ubuntu 16.10 AMI. 

The prefix -/+ means that Terraform will destroy and recreate the resource, rather than updating it in-place. While some attributes can be updated in-place (which are shown with the ~ prefix), changing the AMI for an EC2 instance requires recreating it.
As indicated by the execution plan, Terraform first destroyed the existing instance and then created a new one in its place.

    terraform show

## Destroy Infrastructure
The terraform destroy command terminates resources defined in your Terraform configuration. This command is the reverse of terraform apply in that it terminates all the resources specified by the configuration. It does not destroy resources running elsewhere that are not described in the current configuration.

    terraform destroy

Just like with apply, Terraform determines the order in which things must be destroyed.

## Resource Dependencies

**Assigning an Elastic IP**: An Elastic IP address is a static IPv4 address designed for dynamic cloud computing. An Elastic IP address is associated with your AWS account. 
An Elastic IP address is a public **IPv4 address**, which is reachable from the **internet**. If your instance does not have a public IPv4 address, you can associate an Elastic IP address with your instance to enable communication with the internet. For example, this allows you to connect to your instance from your local computer. 

    resource "aws_eip" "ip" {
        vpc = true
        instance = aws_instance.example.id
    }


This should look familiar from the earlier example of adding an EC2 instance resource, except this time we're building an "aws_eip" resource type. This resource type allocates and associates an elastic IP to an EC2 instance.

    terraform apply

As shown above, Terraform created the EC2 instance before creating the Elastic IP address. Due to the interpolation expression that passes the ID of the EC2 instance to the Elastic IP address, Terraform is able to infer a dependency, and knows it must create the instance first.

**»Implicit and Explicit Dependencies**
By studying the resource attributes used in interpolation expressions, Terraform can automatically infer when one resource depends on another. In the example above, the reference to **aws_instance.example.id** creates an implicit dependency on the **aws_instance** named example.
Terraform uses this dependency information to determine the correct order in which to create the different resources. In the example above, Terraform knows that the **aws_instance** must be created before the **aws_eip**.

Sometimes there are dependencies between resources that are not visible to Terraform. The **depends_on** argument is accepted by any resource and accepts a list of resources to create explicit dependencies for.

For example, perhaps an application we will run on our EC2 instance expects to use a specific Amazon S3 bucket, but that dependency is configured inside the application code and thus not visible to Terraform. In that case, we can use depends_on to explicitly declare the dependency:

    # New resource for the S3 bucket our application will use.
    resource "aws_s3_bucket" "example" {
        # NOTE: S3 bucket names must be unique across _all_ AWS accounts, so
        # this name must be changed before applying this example to avoid naming
        # conflicts.
        bucket = "terraform-getting-started-guide"
        acl    = "private"
    }

    # Change the aws_instance we declared earlier to now include "depends_on"
    resource "aws_instance" "example" {
        ami           = "ami-2757f631"
        instance_type = "t2.micro"

        # Tells Terraform that this EC2 instance must be created only after the
        # S3 bucket has been created.
        depends_on = [aws_s3_bucket.example]
    }

## Provisioning
provisioners let you upload files, run shell scripts, or install and trigger other software like configuration management tools, etc.

    resource "aws_instance" "example" {
        ami           = "ami-b374d5a5"
        instance_type = "t2.micro"

        provisioner "local-exec" {
            command = "echo ${aws_instance.example.public_ip} > ip_address.txt"
        }
    }

This adds a provisioner block within the resource block. Multiple provisioner blocks can be added to define multiple provisioning steps. Terraform supports [multiple provisioners](https://www.terraform.io/docs/provisioners/index.html), but for this example we are using the **local-exec** provisioner.

    terraform init
    terraform apply

Observe the local-exec provisioner executing a command locally on your machine running Terraform. The local-exec provisioner you just ran created a file called ip_address.txt on your local machine where you ran your terraform apply command.

Another useful provisioner is **remote-exec** which invokes a script on a remote resource after it is created. This can be used to run a configuration management tool, bootstrap into a cluster, etc. In order to use a **remote-exec** provisioner, you must choose an **ssh** or **winrm** connection in the form of a connection block within the provisioner.

Here is an example of how to use **remote-exec** to install a specific package on a single instance at startup. You should have an ssh key created with appropriate permissions to run the example below. 


Create an ssh key with no passphrase with ssh-keygen -t rsa and use the name terraform. Update the permissions of that key with chmod 400 ~/.ssh/terraform. (This example is for reference and should not be used without testing. If you are running this, create a new Terraform project folder for this example.)

    ssh-keygen -t rsa
    
    chmod 400 ~/.ssh/terraform


**Provisioners are only run when a resource is created. They are not a replacement for configuration management and changing the software of an already-running server, and are instead just meant as a way to bootstrap a server. For configuration management, you should use Terraform provisioning to invoke a real configuration management solution.**

### »Failed Provisioners and Tainted Resources
If a resource successfully creates but fails during provisioning, Terraform will error and mark the resource as "tainted". A resource that is tainted has been physically created, but can't be considered safe to use since provisioning failed.

When you generate your next execution plan, Terraform will not attempt to restart provisioning on the same resource because it isn't guaranteed to be safe. Instead, Terraform will remove any tainted resources and create new resources, attempting to provision them again after creation.
     
### »Manually Tainting Resources

In cases where you want to manually destroy and recreate a resource, Terraform has a built in taint function in the CLI. This command will not modify infrastructure, but does modify the state file in order to mark a resource as tainted. Once a resource is marked as tainted, the next plan will show that the resource will be destroyed and recreated and the next apply will implement this change.

To taint a resource, use the following command:

    terraform taint resource.id

**resource.id** refers to the resource block name and resource ID to taint. Review the resource block we previously created:

    resource "aws_instance" "example" {
        ami           = "ami-b374d5a5"
        instance_type = "t2.micro"
    }

The correct resource and ID to taint this resource would be 

    terraform taint aws_instance.example

### »[Destroy Provisioners](https://www.terraform.io/docs/provisioners/)
Provisioners can also be defined that run only during a destroy operation. These are useful for performing system cleanup, extracting data, etc.

## [Input Variables](https://learn.hashicorp.com/terraform/getting-started/variables)
## [Output Variables](https://learn.hashicorp.com/terraform/getting-started/outputs)