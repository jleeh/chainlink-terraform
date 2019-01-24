# Chainlink Terraform
Basic Terraform module for provisioning a Chainlink EC2 instance.

## Dependencies
- Terraform (https://terraform.io/)

## How to Use

1) Firstly install the Terraform cli from the official website and add it to your PATH:

    https://www.terraform.io/downloads.html
2) Download your AWS programmatic credentials and place them in your user directory `~/.aws`:

    https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-files.html
3) In your AWS console, create a new SSH key pair called `chainlink-tf` and download it
3) Run `terraform init` in this repository directory
4) Run `terraform apply` in this repository directory. Once prompted for confirmation, enter `yes`.
5) If successful, an output similar to below will be shown:
    ```
    Apply complete! Resources: 6 added, 0 changed, 0 destroyed.
    
    Outputs:
    
    public_ip = 1.2.3.4
    ```
6) To then access your node, just SSH into the IP shown with the key pair you downloaded:

    `ssh -i chainlink-tf.pem -L 6688:localhost:6688 ec2-user@1.2.3.4`
7) Credentials are generated randomly and stored in `/root/.chainlink/api_pw`, to get them run:
    
    `cat /root/.chainlink/api_pw`
8) Browse to `http://localhost:6688` on your machine, and then enter the credentials from the file.

All done!

## Configuration

To edit configuration for the Chainlink instance being created, you can edit the defaults found in `variables.tf`.

You can also change the variables when running terraform in your CLI. For example, this would restrict SSH access to 
just your IP:

`terraform apply -var 'allowed_cidr=["1.2.3.4/32"]'`

Or using a previous Chainlink version:

`terraform apply -var 'image_tag=0.5.1'`

Or using a different AWS region:

`terraform apply -var 'region=eu-west-1'`

## Viewing Logs

If you browse to CloudWatch in the AWS console and click "Logs", you should then see a `chainlink-tf` group with logs
inside it for your Chainlink node.

## License
[MIT License](LICENSE.md)