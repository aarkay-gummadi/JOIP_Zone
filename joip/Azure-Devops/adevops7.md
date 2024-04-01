Install the dotnet6 on ubuntu 22
--------------------------------

* manual steps for the dotnet6 

```
sudo apt install apt-transport-https 
sudo apt update 
sudo apt install dotnet-sdk-6.0 
```

Terms
-----
* Dependency: The libary or framework which your application is relying on for some functionality
* dotnet build commad [refer here](https://learn.microsoft.com/en-us/dotnet/core/install/linux-ubuntu)




```
sudo apt update
sudo apt install dotnet-sdk-7.0
git clone https://github.com/nopSolutions/nopCommerce.git
cd nopcommerce
cd src
dotnet restore NopCommerce.sln
dotnet build NopCommerce.sln
```

* Pipeline created is 
```yaml
---
pool:
  name: "Azure Pipelines"
  vmImage: ubuntu-22.04
  
trigger:
  - master
  
steps:
  - task: DotnetCoreCLI@2
    inputs:
      command: 'build'
      projects: src/NopCommerce.sln      
```
