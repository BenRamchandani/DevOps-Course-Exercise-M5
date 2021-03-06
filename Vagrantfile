# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|

  config.vm.box = "hashicorp/bionic64"

  config.vm.network "forwarded_port", guest: 5000, host: 5000
  

  config.vm.provision :shell, privileged: false, inline: <<-SHELL
    sudo apt-get update

    # https://github.com/pyenv/pyenv/wiki/common-build-problems
    sudo apt-get install -y build-essential libssl-dev zlib1g-dev libbz2-dev \
    libreadline-dev libsqlite3-dev wget curl llvm libncurses5-dev libncursesw5-dev \
    xz-utils tk-dev libffi-dev liblzma-dev python-openssl git

    # pyenv setup
    echo 'Installing pyenv...'
    rm -rf ~/.pyenv
    git clone https://github.com/pyenv/pyenv.git ~/.pyenv
    echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.profile
    echo 'export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.profile
    echo 'eval "$(pyenv init -)"' >> ~/.profile
    source ~/.profile

    # Configure python 3.8.5
    echo 'Configuring pyenv...'
    pyenv install 3.8.5
    pyenv global 3.8.5

    # Install poetry
    echo 'Installing poetry...'
    curl -sSL https://raw.githubusercontent.com/python-poetry/poetry/master/get-poetry.py | python
  SHELL


  config.trigger.after :up do |trigger|
    trigger.name = "Launching App"
    trigger.info = "Running the TODO app setup script"
    trigger.run_remote = {privileged: false, inline: <<-SHELL
      cd /vagrant
      poetry install
      export `cat .env | grep '^[A-Z]' | xargs`
      poetry run gunicorn --bind 0.0.0.0:5000 --daemon "todo_app.app:create_app()"
    SHELL
  }
  end
end
