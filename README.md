# Documentação de Implementação AWS e Configuração Linux

Autor: Kalmax dos Santos Sousa

## **Introdução**

Este documento descreve o processo de configuração do ambiente AWS e configuração de servidores Linux com os serviços solicitados. O objetivo é criar uma instância EC2 com o sistema operacional Amazon Linux 2 que atuará como servidor NFS, e outra instância que será um cliente NFS, responsável por executar um servidor Apache e criar um script de validação.

## **Ambiente AWS**

### **Criação da Infraestrutura**

Aqui estão os passos para criar a infraestrutura necessária na AWS:

**Passo 1: Criação da VPC**

1. Na AWS Console, acesse o serviço "VPC".
2. Clique em "Create VPC" e siga as instruções para criar uma nova Virtual Private Cloud (VPC).

**Passo 2: Criação da Sub-rede Pública**

1. Na AWS Console, ainda no serviço "VPC", clique em "Subnets".
2. Crie uma subnet e associe a sub-rede à VPC criada no Passo 1.

**Passo 3: Criação do Gateway de Internet**

1. Na AWS Console, no serviço "VPC", clique em "Internet Gateways".
2. Clique em "Create internet gateway" e associe-o à VPC criada no Passo 1.

**Passo 4: Configuração da Tabela de Roteamento**

1. Na AWS Console, no serviço "VPC", clique em "Route Tables".
2. Selecione a tabela de roteamento associada à VPC criada no Passo 1.
3. Edite as rotas para permitir o tráfego para a internet adicionando o endereço 0.0.0.0/0 associado ao Internet Gateway criado no passo 3.

**Passo 5: Criação de Duas Instâncias EC2**

1. Na AWS Console, acesse o serviço "EC2".
2. Clique em "Launch Instance" para criar a primeira instância EC2 com as seguintes especificações:
    - Família: t3.small
    - Armazenamento: 16 GB
    - Sistema Operacional: Amazon Linux 2
    - Associe a instância à VPC criada no Passo 1.
    - Crie uma chave pública para acesso SSH e faça o download.
    - Configure as regras do grupo de segurança para permitir o tráfego nas portas: 
    22/TCP (SSH), 111/TCP/UDP e 2049/TCP/UDP (NFS), 80/TCP (HTTP) e 443/TCP (HTTPS).
3. Especifique o número de instâncias a serem criadas.

**Passo 6: Criação de IP Estático**

1. Na AWS Console, no serviço "EC2", clique em "Elastic IPs".
2. Clique em "Allocate new address" e associe o endereço IP estático a uma das instâncias EC2 criadas no Passo 5.

## **Ambiente Linux**

Defina como servidor NFS a instância que não possui o IP Estático

### **Configuração do Servidor NFS**

Aqui estão os passos para configurar o servidor NFS:

1. **Atualização de Pacotes**:
    
    Atualize os pacotes locais na instância escolhida como servidor NFS:
    
    ```bash
    sudo yum update -y
    ```
    
2. **Instalação dos Pacotes NFS**:
    
    Instale os pacotes necessários para NFS:
    
    ```bash
    sudo yum install -y nfs-utils
    ```
    
3. **Criação do Diretório Compartilhado**:
    
    Crie um diretório para compartilhamento:
    
    ```bash
    sudo mkdir -p /mnt/Kalmax
    ```
    
4. **Permissões de Acesso**:
    
    Defina permissões de leitura e gravação para o diretório compartilhado:
    
    ```bash
    sudo chmod 777 /mnt/Kalmax
    ```
    
5. **Configuração do NFS**:
    
    Edite o arquivo de configuração do NFS:
    
    ```bash
    sudo vi /etc/export
    ```
    
    Adicione a seguinte linha para compartilhar o diretório:
    
    ```bash
    /mnt/Kalmax 10.0.0.146(rw,sync,no_root_squash)
    ```
    
6. **Reinicialização do Serviço NFS**:
    
    Reinicialize o serviço NFS para aplicar as alterações:
    
    ```bash
    sudo systemctl restart nfs
    ```
    

### **Configuração do Cliente NFS**

Aqui estão os passos para configurar o cliente NFS:

1. **Atualização de Pacotes**:
    
    Atualize os pacotes na instância cliente:
    
    ```bash
    sudo yum update -y
    ```
    
2. **Instalação dos Pacotes NFS**:
    
    Instale os pacotes NFS:
    
    ```bash
    sudo yum install nfs-utils
    ```
    
3. **Criação do Diretório de Montagem**:
    
    Crie um diretório para montar o compartilhamento do servidor (use o mesmo caminho):
    
    ```bash
    sudo mkdir -p /mnt/Kalmax
    ```
    
4. **Montagem do Diretório do Servidor NFS**:
    
    Monte o diretório compartilhado do servidor no diretório criado:
    
    ```bash
    sudo mount -t nfs 10.0.0.98:/mnt/Kalmax /mnt/Kalmax
    ```
    
5. **Montagem Automática na Inicialização**:
    
    Para montar automaticamente o diretório na inicialização, adicione a seguinte linha ao arquivo **/etc/fstab**:
    
    ```bash
    10.0.0.98:/mnt/Kalmax /mnt/Kalmax nfs defaults 0 0
    ```
    
    Em seguida, execute o comando:
    
    ```bash
    sudo mount -a
    ```
    

### **Configuração do Servidor Apache**

Aqui estão os passos para configurar o servidor Apache:

1. **Instalação do Apache**:
    
    Instale o Apache na instância com IP estático associado:
    
    ```bash
    sudo yum install httpd
    ```
    
2. **Verificação do Status do Apache**:
    
    Verifique o status do serviço Apache e inicie-o se não estiver ativo:
    
    ```bash
    sudo systemctl status httpd # Verifica o status
    sudo systemctl start httpd  # Inicializa o serviço
    ```
    
3. **Criação da Página Web**:
    
    Crie uma página web personalizada dentro do diretório **/var/www/html/hello**:
    
    ```bash
    sudo mkdir -p /var/www/html/hello
    ```
    
    Crie o arquivo **`index.html`** com o conteúdo desejado. O conteúdo adicionado foi:
    
    ```html
    <!DOCTYPE html>
    <html>
    <head>
        <title>Hello!</title>
        <meta charset="UTF-8">
    </head>
    <body>
        <h1>Hello!</h1>
        <p>Hora atual: <span id="hora"></span></p>
    
        <script>
            function obterHora() {
                const dataAtual = new Date();
                const hora = dataAtual.toLocaleTimeString();
                return hora;
            }
    
            function atualizarHora() {
                document.getElementById('hora').textContent = obterHora();
            }
    
            atualizarHora();
            setInterval(atualizarHora, 1000);
        </script>
    </body>
    </html>
    ```
    
4. **Configuração do Virtual Host**:
    
    Crie um arquivo de configuração para o virtual host em **/etc/httpd/conf.d/hello.conf** com as seguintes configurações:
    
    ```bash
    <VirtualHost *:80>
        ServerAdmin webmaster@localhost
        ServerName localhost
        DocumentRoot /var/www/html/hello
        ErrorLog /var/log/httpd/hello.com_error.log
        CustomLog /var/log/httpd/hello.com-access.log combined
    </VirtualHost>
    
    ```
    

### **Alteração do Fuso-Horário da Instância EC2**

Para alterar o fuso horário da instância Amazon Linux 2 para a timezone de Fortaleza, execute o seguinte comando:

```bash
sudo timedatectl set-timezone America/Fortaleza
```

### **Arquivo de Monitoramento do Funcionamento do Servidor Apache**

Aqui está o processo para criar e configurar o arquivo de monitoramento do servidor Apache:

1. **Criação do Script de Monitoramento**:
    
    Crie a pasta **/scripts** na raiz e dentro dela crie o arquivo **check_apache.sh**:
    
    ```bash
    vi /scripts/check_apache.sh
    ```
    
    Adicione o seguinte código ao arquivo:
    
    ```bash
    bashCopy code
    #!/bin/bash
    timestamp=$(date +"%Y-%m-%d %T")
    service_name="Apache"
    status=""
    
    if systemctl is-active --quiet httpd; then # Verifica se o Apache está funcionando
        status="Online"
    else
        status="Offline"
    fi
    
    # Cria/Atualiza arquivo de status
    echo "$timestamp - $service_name - Status: $status" >> /mnt/Kalmax/status_$status.txt
    
    ```
    
2. **Tornar o Script Executável**:
    
    Torne o script executável:
    
    ```bash
    sudo chmod +x /scripts/check_apache.sh
    ```
    
3. **Configuração do Cron**:
    
    Use o cron para agendar a execução do script a cada 5 minutos:
    
    ```bash
    sudo crontab -e
    ```
    
    Adicione a seguinte linha ao arquivo:
    
    ```bash
    */5 * * * * /bin/bash /scripts/check_apache.sh
    
    ```
    

Com essas configurações, seu ambiente AWS com servidores Linux estará configurado e pronto para uso.