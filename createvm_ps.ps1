# Comprobamos que tenemos la conexion hecha con Azure
function check_conn ()
{
    try
    { 
        $connection=Get-AzSubscription -ErrorAction Stop |Where-Object State -EQ "Enabled"
        Write-Host "Hay conexion con Azure con subsripcion activa" $connection.Name -ForegroundColor Gray
    }
    catch
    {
        Write-Host "No estas conectado necesitas conectarte con Connect-AzAccount"
        Break
    }
}

check_conn


$VMLocalAdminUser="yagovm"
$VMLocalAdminSecurePassword = ConvertTo-SecureString "PassWord1234" -AsPlainText -Force
$Credential = New-Object System.Management.Automation.PSCredential ($VMLocalAdminUser, $VMLocalAdminSecurePassword);
$NAMERG="PruebaPS"


Write-Host "Creamos grupor de recursos $NAMERG"
New-AzResourceGroup -Name $NAMERG -Location EastUS

Write-Host "Creamos red Virtual"
$Subnetvn1  = New-AzVirtualNetworkSubnetConfig -Name mysubnet  -AddressPrefix "192.168.10.0/24"
New-AzVirtualNetwork -ResourceGroupName PruebaPS -Name MyVN1 -AddressPrefix 192.168.0.0/16 -Subnet $Subnetvn1 -Location EastUS-PublicIpAddressName


Write-Host "Creamos Maquina Virtual de Windopws"
New-AzVM -ResourceGroupName PruebaPS -Name myPSVM -VirtualNetworkName MyVN1 -SubnetName mysubnet -Image Win2019Datacenter -Size Standard_DS2_v2 -DataDiskSizeInGb 10 -Credential $Credential -PublicIpSku Basic -PublicIpAddressName pip-testvm -AllocationMethod Dynamic
