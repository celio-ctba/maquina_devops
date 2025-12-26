#!/bin/bash
set -e
#1. Atualize seus pacotes de sistema
echo "Updating system packages..."
sudo apt update && sudo apt upgrade -y
###
#2.Instale ferramentas essenciais de DevOps
#Docker, Git, curl, unzip; esses são seus drivers diários.
echo "Installing essential tools..."
sudo apt update && sudo apt install -y \
    git curl wget unzip htop xclip \
    docker.io docker-compose-v2 \
    docker-compose
echo "Essential tools installed."
###
#3. Adicione sua chave SSH ao GitHub/GitLab
echo "Generating SSH key..."

mkdir -p ~/.ssh
if [ -f ~/.ssh/id_ed25519 ]; then
    echo "SSH key already exists at ~/.ssh/id_ed25519. Aborting to avoid overwrite."
    exit 1
fi

read -p "Enter your email for SSH key: " email
ssh-keygen -t ed25519 -C "$email" -f ~/.ssh/id_ed25519 -N ""

if ! command -v xclip &> /dev/null; then
    sudo apt install -y xclip
fi

xclip -selection clipboard < ~/.ssh/id_ed25519.pub

echo "SSH key copied to clipboard. Paste it into GitHub/GitLab > SSH settings."
##################
#4. Adicione seu usuário ao grupo Docker
echo "Adding user to Docker group..."
sudo usermod -aG docker "$(whoami)"

echo "Você foi adicionado ao grupo Docker."
echo " Pode ser necessário fazer logout ou executar: newgrp docker
###
#5. Instale o Oh My Zsh + Prompt do Powerlevel10k
echo "Installing Zsh..."
sudo apt install -y zsh fonts-powerline

echo "Installing Oh My Zsh..."
export RUNZSH=no
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

echo "Installing Powerlevel10k theme..."
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git \
  ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k

echo "Setting theme in .zshrc..."
sed -i 's|^ZSH_THEME=.*|ZSH_THEME="powerlevel10k/powerlevel10k"|' ~/.zshrc

echo "Oh My Zsh and Powerlevel10k installed."
echo "  Run 'chsh -s $(which zsh)' to make Zsh your default shell."
###
#6. Configurar padrões do Git
echo "Configuring Git..."

read -p "Enter your Git name: " name
read -p "Enter your Git email: " email

git config --global user.name "$name"
git config --global user.email "$email"
git config --global init.defaultBranch main
git config --global pull.rebase true
git config --global color.ui auto

echo "Git configured."
###
#7. Crie uma estrutura de pastas DevOps padrão
echo "Creating standard DevOps folder structure..."
mkdir -p ~/devops/{projects,scripts,logs,tools}
echo "Folders created at ~/devops/"
###
#8. Instale o Terraform e a AWS CLI
echo "Installing Terraform..."
if ! command -v terraform &> /dev/null; then
    wget -q https://releases.hashicorp.com/terraform/1.14.3/terraform_1.14.3_linux_amd64.zip -O terraform.zip
    unzip terraform.zip
    sudo mv terraform /usr/local/bin/
    rm terraform.zip
    echo "Terraform installed."
else
    echo "Terraform already installed. Skipping."
fi

echo "Installing AWS CLI..."
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
rm -rf aws awscliv2.zip
echo "AWS CLI installed."
###
#9. Exibir uma lista de verificação pós-instalação
echo "DevOps Workstation Setup Complete!"
echo ""
echo "Next Steps:"
echo "1. Log out and back in or run 'newgrp docker' for Docker access."
echo "2. Run 'chsh -s \$(which zsh)' to set Zsh as your default shell."
echo "3. Open ~/.zshrc and customize Powerlevel10k if needed."
echo "4. Install VSCode, Neovim, or your favorite IDE."
echo "5. Set up GPG keys for Git commit signing (optional)."

