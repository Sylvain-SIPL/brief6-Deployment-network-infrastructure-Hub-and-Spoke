# installation debian

source "azure-arm" "autogenerated_1"  {
subscription_id                   = "ec907711-acd7-4191-9983-9577afbe3ce1"
build_resource_group_name         = "HbSpkeSylvain"
managed_image_resource_group_name = "HbSpkeSylvain"
managed_image_name                = "Windows10"
os_type                           = "Windows"
image_publisher                   = "MicrosoftVisualStudio"
image_offer                       = "Windows"
image_sku                         = "Windows-10-N-x64"

use_interactive_auth = true

  azure_tags = {
    task = "Image deployment"
  }

  vm_size                           = "Standard_B1ls"
}

build {
  sources = ["source.azure-arm.autogenerated_1"]

    provisioner "windows-restart" {
    restart_check_command = "powershell -command \"& {Write-Output 'restarted.'}\""
}

}















