# aws_ec2_alb
Two EC2 instances behinds an ALB. One instance running Nginx and the last one running Apache

# Deploy Infrastructure
* Create your SSH Public and Private Key.
* Clone the repository `git clone https://github.com/adecchi/aws_ec2_alb.git`
* Go to the folder `cd aws_ec2_alb`
* Configure your aws profile in `variables.tf`
* Run `terraform init`
* Run `terraform validate`
* Run `terraform plan -out tienda.plan`
* Run `terraform apply tienda.plan`
* Once deployed the infrastructure, Terraform will show the ALB ENDPOINT

# Destroy Infrastructure
* Run `terraform destroy`

# Creating SSH Key Pair:
The simplest way to generate a key pair is to run ssh-keygen without arguments. In this case, it will prompt for the file in which to store keys. Here's an example:
```bash
adecchi (12:39) ~>ssh-keygen -t rsa
Generating public/private rsa key pair.
Enter file in which to save the key (/home/adecchi/.ssh/id_rsa): 
Enter passphrase (empty for no passphrase): 
Enter same passphrase again: 
Your identification has been saved in /home/adecchi/.ssh/id_rsa.
Your public key has been saved in /home/adecchi/.ssh/id_rsa.pub.
The key fingerprint is:
SHA256:Up68jbnEV4Hgfo75YM303QdQsK3Z0aT90z0DoirrW+c adecchi@tita_gama
The key's randomart image is:
+---[RSA 2048]----+
|    .      ..oo..|
|   . . .  . .o.X.|
|    . . o.  ..+ B|
|   .   o.o  .+ ..|
|    ..o.S   o..  |
|   . %o=      .  |
|    @.B...     . |
|   o.=. o. . .  .|
|    .oo  E. . .. |
+----[SHA256]-----+
adecchi (12:40) ~>
```
It will generate the following keys:
```bash
$HOME/.ssh/id_rsa > contains your private key.
$HOME/.ssh/id_rsa.pub > contain your public key.
```

# Generate Public Key, Specifying the File Name
```bash
ssh-keygen -f ~/adecchi-pk -t rsa -b 4096
```