# AWS Provider Configuration
provider "aws" {
  access_key = "myAccessKey"
  secret_key = "mySecretKey"
  region     = "us-east-1"  
}

# Vault Provider Configuration
provider "vault" {
  address          = "localhost:8200"  # 
  skip_child_token = true

  auth_login {
    path = "auth/approle/login"

    parameters = {
      role_id   = "6a11d787-235c-6037-1854-4d37558002e7"  
      secret_id = "c66cf4c3-0551-40d4-ef0f-e6180202b72e"  
    }
  }
}

# Variables
variable "instance_type" {
  description = "value"
  type        = map(string)
  default     = {
    "dev"   = "t2.micro"
    "stage" = "t2.medium"
    "prod"  = "t2.xlarge"
  }
}

# AWS Instance Resource Configuration
resource "aws_instance" "webserver" {
  ami           = "ami-0ca77f0088718ec1f"
  instance_type = var.instance_type[terraform.workspace]  
  key_name      = "TerraformYnov"
  security_groups = ["default"]

  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = filebase64("C:/Users/Noor/.ssh/TerraformYnov.pem")
    host        = self.public_ip
  }

  provisioner "file" {
    source      = "C:\\Users\\Noor\\Desktop\\Terraform\\10_hello_files\\app.py"
    destination = "/home/ec2-user/app.py"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /home/ec2-user/app.py",
      "/home/ec2-user/app.py &",
    ]
  }

  tags = {
    Name   = "test"
    Secret = data.vault_kv_secret_v2.example.data["foo"]
  }
}

# Vault Secret Data Configuration
data "vault_kv_secret_v2" "Gladiator" {
  mount = "secret"   
  name  = "test-secret"  
}
