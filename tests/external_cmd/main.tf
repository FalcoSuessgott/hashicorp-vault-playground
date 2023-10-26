terraform {
  required_version = ">= 1.6.0"

  required_providers {
    shell = {
      source  = "scottwinkler/shell"
      version = "1.7.10"
    }
  }
}

variable "command" {
  type = string
}

# tflint-ignore: terraform_unused_declarations
data "shell_script" "command" {
  lifecycle_commands {
    read = <<EOT
sleep 5 && echo "$(${var.command})"
EOT
  }
}
