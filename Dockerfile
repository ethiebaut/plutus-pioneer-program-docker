FROM ubuntu

#######################
# Pre-requisites
#######################
# 1. Exposing port 8009 to access plutus playground from host
EXPOSE 8009

# 2. Set up environment variables
ENV USERNAME=pioneer \
    USER_UID=2001 \
    USER_GID=2001 \
    DEBIAN_FRONTEND=noninteractive \
    BOOTSTRAP_HASKELL_NONINTERACTIVE=yes \
    BOOTSTRAP_HASKELL_NO_UPGRADE=yes

# 3. Update image and install pre-req packages
RUN apt-get update && \
    apt-get install -y --no-install-recommends sed curl gcc git make sudo vim xz-utils libtinfo5 libgmp-dev zlib1g-dev procps lsb-release ca-certificates build-essential libffi-dev libgmp-dev libgmp10 libncurses-dev libncurses5 libtinfo5 libicu-dev libncurses-dev z3

# 4. Create dev user
RUN groupadd --gid $USER_GID $USERNAME && \
    useradd -ms /bin/bash --uid $USER_UID --gid $USER_GID -m $USERNAME && \
    echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME && \
    chmod 0440 /etc/sudoers.d/$USERNAME

# 5. Switch to dev user
USER ${USER_UID}:${USER_GID}
WORKDIR /home/${USERNAME}
ENV PATH="/home/${USERNAME}/.local/bin:/home/${USERNAME}/.cabal/bin:/home/${USERNAME}/.ghcup/bin:/home/${USERNAME}/.nix-profile/bin:$PATH"

# 6. Update dev user's PATH environment variable
RUN echo "" >> /home/${USERNAME}/.profile && \
    echo "#Updated PATH" >> /home/${USERNAME}/.profile && \
    echo "export PATH=$PATH" >> /home/${USERNAME}/.profile

#######################
# Install Haskell
#######################
RUN curl --proto '=https' --tlsv1.2 -sSf https://get-ghcup.haskell.org | sh

#######################
# Install Nix
#######################
# 1. Install Nix
RUN curl -L https://nixos.org/nix/install | sh

# 2. Add Nix script to bashrc
RUN echo ". /home/${USERNAME}/.nix-profile/etc/profile.d/nix.sh" >> /home/${USERNAME}/.bashrc

# 3. Set up caching
RUN mkdir -p /home/${USERNAME}/.config/nix && \
    touch /home/${USERNAME}/.config/nix/nix.conf && \
    printf "substituters        = https://hydra.iohk.io https://iohk.cachix.org https://cache.nixos.org/\ntrusted-public-keys = hydra.iohk.io:f/Ea+s+dFdN+3Y/G+FDgSq+a5NEWhJGzdjvKNGv0/EQ= iohk.cachix.org-1:DpRUyj7h7V830dp/i6Nti+NEO2/nhblbov/8MW7Rqoo= cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=" >> ~/.config/nix/nix.conf && \
    sudo mkdir /etc/nix && \
    sudo touch /etc/nix/nix.conf && \
    cat /home/${USERNAME}/.config/nix/nix.conf | sudo tee -a /etc/nix/nix.conf > /dev/null

#######################
# Set up Plutus Environment
#######################
# 1a. Clone Plutus repo
RUN cd /home/${USERNAME} && \
    git clone https://github.com/input-output-hk/plutus.git && \
    git clone https://github.com/input-output-hk/plutus-pioneer-program.git

# 1b. Set local Plutus repo to a specific commit version
RUN cd /home/${USERNAME}/plutus && \
    git checkout 3746610e53654a1167aeb4c6294c6096d16b0502

# 2. Edit webpack.config.js to allow access to playground client from outside of container
RUN cd /home/${USERNAME}/plutus/plutus-playground-client &&\
    sed -i -e "s/port: 8009/host: '0.0.0.0',\n        port: 8009/g" webpack.config.js

# 3. Build plutus-core
RUN cd /home/${USERNAME}/plutus && \
    nix --extra-experimental-features nix-command build -f default.nix plutus.haskell.packages.plutus-core

# 4. Create scripts to start plutus playground server & client
RUN printf "cd plutus-playground-server\n \
            plutus-playground-server" \
            > /home/${USERNAME}/nix_pp_server_start.sh

RUN printf "cd plutus-playground-client\n \
            npm run start" \
            > /home/${USERNAME}/nix_pp_client_start.sh

RUN printf "echo \"[Updating local Plutus repos...]\"\n \
        echo \"1. Updating Repo: plutus-pioneer-program...\"\n \
        cd /home/${USERNAME}/plutus-pioneer-program && git pull\n \
        echo \"[Running Plutus Playground Server...]\"\n \
        cd /home/${USERNAME}/plutus && nix-shell --run \". /home/${USERNAME}/nix_pp_server_start.sh\"" \
        > /home/${USERNAME}/01_main_pp_server_start.sh

RUN printf "echo \"[Running Plutus Playground Client...]\"\n \
        cd /home/${USERNAME}/plutus && nix-shell --run \". /home/${USERNAME}/nix_pp_client_start.sh\"" \
        > /home/${USERNAME}/02_main_pp_client_start.sh 

#5. Initialise Plutus Playground Server Client
RUN cd /home/${USERNAME}/plutus/ && \
    nix-shell --run "cd plutus-playground-client && npm install && plutus-playground-generate-purs && npm run purs:compile && npm run webpack"

#######################
# Build
#######################

# 1. Build the environment
RUN cd /home/${USERNAME}/plutus-pioneer-program/code/week01 && \
    cabal build || true && \
    sudo apt install -y pkg-config libsodium-dev && \
    cabal build

#######################
# Wrapping up
#######################
# 1. Make container interactive
ENV DEBIAN_FRONTEND=dialog

# 2. Create run-all.sh file
RUN echo ' #!/usr/bin/bash\n\
cd /home/${USERNAME}/plutus\n\
nix-shell --run "cd plutus-playground-client && npm run start" &\n\
nix-shell --run "cd plutus-playground-server && plutus-playground-server"\n' > /home/${USERNAME}/run-all.sh
RUN chmod +x run-all.sh

# 3. Set Entry Point
CMD /home/${USERNAME}/run-all.sh
