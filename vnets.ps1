#
# Some variables in the beginning
#

$myrg = "msassi-vnet"
$myvnet= "vnet-nebo"
$snetprivate= "snet-private"
$snetpublic= "snet-public"
$nsgname = "mynsg"
$vm1 ="VM1"
$vm2 = "VM2"
$mypip ="mypip"

#
# Create resource group
#

az group create --name $myrg --location eastus 

#
# create network security group
#

az network nsg create `
    -g $myrg `
    -n $nsgname

#
# Create nsg rule to allow inbound on port 22 (ssh)
#

az network nsg rule create `
    -g $myrg `
    -n allow_ssh `
    --nsg-name $nsgname `
    --priority 101 `
    --destination-port-ranges 22

#
# Create Vnet
#

az network vnet create `
    --name $myvnet `
    --resource-group $myrg `
    --address-prefix 10.0.0.0/16`

# 
# Create a public subnet and asssociate to it nsg
#

az network vnet subnet create `
    -g $myrg `
    -n $snetpublic `
    --vnet-name $myvnet `
    --address-prefix 10.0.0.0/17 `
    --network-security-group $nsgname

# 
# Create a private subnet
#


az network vnet subnet create `
    -g $myrg `
    -n $snetprivate `
    --vnet-name $myvnet `
    --address-prefix 10.0.128.0/17


#
# Create a vm in the public subnet
#

az vm create `
    -g $myrg `
    -n $vm1 `
    --image Ubuntu2204 `
    --size Standard_DS2_v2 `
    --admin-username azureuser `
    --generate-ssh-keys `
    --subnet $snetpublic `
    --vnet-name $myvnet

#
# Create a public IP
#

az network public-ip create --resource-group $myrg --name $mypip

#
# Update a vm associate a public IP
#

az vm update `
    -g $myrg `
    -n $vm1 `
    --public-ip $mypip


#
# Create a vm in the private subnet
#

az vm create `
    -g $myrg `
    -n $vm2 `
    --image Ubuntu2204 `
    --size Standard_DS2_v2 `
    --admin-username azureuser `
    --generate-ssh-keys `
    --subnet $snetprivate `
    --vnet-name $myvnet


# VM1 in public subnet can talk to VM2 in private subnet (private ip)
# VM1 in public subnet can't talk with VM2 (public IP) (Traffic not allowed)
# ping and rout -n commands used

