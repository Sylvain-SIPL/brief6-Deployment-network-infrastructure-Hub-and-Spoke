# installation debian

source "azure-arm" "autogenerated_1"  {
subscription_id                   = "ec907711-acd7-4191-9983-9577afbe3ce1"
build_resource_group_name         = "HbSpkeSylvain"
managed_image_resource_group_name = "HbSpkeSylvain"
managed_image_name                = "Nginx"
os_type                           = "Linux"
image_publisher                   = "Debian"
image_offer                       = "Debian-11"
image_sku                         = "11-backports-gen2"

use_interactive_auth = true

  azure_tags = {
    task = "Image deployment"
  }

  vm_size                           = "Standard_B1ls"
}

build {
  sources = ["source.azure-arm.autogenerated_1"]

 
# copie source et renomme index.html vers repertoire tmp

  provisioner "file"{
    source ="C:/Users/Apprenant/Documents/Déployer une infra réseau Hub-and-Spoke dans Azure/index.html"
    destination = "/tmp/index.html"
  }

# installation nginx

  provisioner "shell" {
    inline= [
      "sudo apt-get update && sudo apt-get upgrade -y",
      "sudo apt-get -y install nginx",
      "sudo systemctl start nginx",
      "sudo systemctl enable nginx",
      # on deplace index.html depuis tmp vers l'emplacement par defaut nginx
      "sudo mv /tmp/index.html /var/www/html/index.html",
      "sudo systemctl restart nginx"
    ]
  }
}















