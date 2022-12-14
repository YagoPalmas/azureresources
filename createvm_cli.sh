#! /bin/bash



if [ $# -ne 1 ];then
	# Pedimos el grupo de Recursos
	echo "Vamos crear un grupo de recursos en East US:"
	read -p "Dame el nombre del grupo de recursos:" NAMERG
else
	NAMERG="$1"
fi

set -u

# Comprobamos si hay subscripcion activa por defecto
if az account show|grep "state.: .Enabled" > /dev/null;then
	echo "Estas conectado con subscripcion activa"
	 az account show
else
	echo "Haz login con su susbscripcion activa o cambia de subscripcion con "
	echo "az account set -s id_ssubscripcion"
	exit 1
fi


az group create --name $NAMERG --location eastus
if [ $? -ne 0 ];then
	echo "Hubo un error al crear el recurso"
	exit 2
fi

# Creamos la red virtual
az network vnet list --query '[].{"Name":name,"ResourceGroup":resourceGroup}' --resource-group $NAMERG --output table
echo "Creamos red virtual en el grupo de recurso $NAMERG con subred 192.168.10.0/24"
echo "az network vnet create -g $NAMERG -n myvn1 --address-prefix 192.168.0.0/16 --subnet-name MySubnet --subnet-prefix 192.168.10.0/24"
az network vnet create -g $NAMERG -n myvn1 --address-prefix 192.168.0.0/16 --subnet-name MySubnet --subnet-prefix 192.168.10.0/24
if [ $? -ne 0 ];then
	echo "Hubo un error al crear el recurso"
	exit 3
fi

# Creamos maquina virtual
echo "Creamos maquina virtual en el grupo de recurso $NAMERG en la subred 192.168.10.0/24"
echo "az vm create -n MyVm -g  $NAMERG --image Centos --subnet MySubnet --vnet-name myvn1  --data-disk-sizes-gb 10 --size Standard_DS1_v2   --admin-username yagovm  --ssh-key-values /home/yago/.ssh/id_rsa.pub --public-ip-sku Standard"
az vm create -n MyVm -g  $NAMERG --image Centos --subnet MySubnet --vnet-name myvn1  --data-disk-sizes-gb 10 --size Standard_DS1_v2   --admin-username yagovm  --ssh-key-values /home/yago/.ssh/id_rsa.pub --public-ip-sku Standard > /tmp/vm_create.json
if [ $? -ne 0 ];then
	echo "Hubo un error al crear el recurso"
	exit 5
fi


echo "Probamos a conectarnos por ssh"

#Sacamos la IP del JSON de salida
IP_PUBLICA=$(cat /tmp/vm_create.json |grep publicIpAddress|cut -d\: -f2|grep -Eo "[0-9.]*")


#Comprobamos que hay conexion ssh sacando el hostname
sleep 5
echo "Comprobamos que tenemos conexion ssh con la IP publica $IP_PUBLICA"
ssh -p22  -o StrictHostKeyChecking=no -i /home/yago/.ssh/id_rsa yagovm@$IP_PUBLICA  "hostname -f"
