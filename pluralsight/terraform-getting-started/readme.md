# [Terraform - Getting Started](https://app.pluralsight.com/course-player?clipId=6ee9f344-c758-468e-b262-924da39b3388)

github [repo](https://github.com/ned1313/Getting-Started-Terraform)

## 3 Deploying Terraform Configuration

Topics:
- Automating infrastructure
- Real world scenario
- Terraform: "Hello world"

Automating Infrastructure Deployment key concepts:
- Provisioning Resources
- Planing Updatescd 
- Using Source Control
- Reusing Templates


### 3.1 Provisioning Resources

Scenario:
- provisioning a development environment that's gonna be part of a new line-of-business app
- two tier application
    - web frontend
    - database backend
    - public DNS record
- deploying AWS
- use IsC

**Terraform Components** at high level:
- **Terraform executable** written in Go. For installation just put it in the path variable
- The configuration that will be deployed will be contained in **one  or more** Terraform **.tf** files. During the run time if there are multiple **.tf** files, Terraform stitches a configuration together on the basis of the contents of those files.  
- **Terraform plugins** since Terraform is an executable by itself, it makes use of a number of different plugins to interact with the **providers**. 
- **Terraform state**: once resources have been created, terraform likes to keep track of what is going on, so it has a state file, which has the current state of the configuration within it. During environment updates, terraform compares the new configuration with the current state and makes the necessary changes so that the state matches the desired configuration.

Creating Terraform **variables** to store sensible data:

    # variables
    variable "aws_access_key" {}
    variable "aws_secret_key"{}
    variable "aws_region"{
        default = "us-east-1"
    }

    # provider
    provider "aws" {
        access_key = "var.access_key"
        secret_key = "var.secret_key"
        region = "var.aws_region"
    }

Once we have connected to AWS, we may want to get some information about the resources exist at AWS to use them. For example to get all the Amazon Linux AMIs AMI for the region we are using so we can select on to create an EC2 instance. We can do it by pulling a data source

    # data
    data "aws_ami" "alx" {
        most_recent = true
        owners = ["amazon"]
        filter{}
    }

We are going to create a server to host the web the database components which is called a **resource**. In this case we are deploying
- EC2 instance
- we're giving it an AMI that we we got from our data source
- instance type t2.micro

        # resources
        resource "aws_instance" "ex" {
            ami = "data.aws_ami.alx.id"
                instance_type = "t2.micro"
        }

Finally, we might want to get some output information out of our deployment like the public IP address of the web server

    # Output
    output "aws_public_ip" {
        value = "aws_instance.ex.public_dns"
    }
