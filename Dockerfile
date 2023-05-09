FROM ubuntu:20.04

RUN ln -fs /usr/share/zoneinfo/Europe/London /etc/localtime
RUN sed -i 's/# \(.*multiverse$\)/\1/g' /etc/apt/sources.list && \
    apt update && \
    apt -y upgrade && \
    apt install -y apt-utils && \
    apt install -y sudo && \
    apt install -y make cmake ninja-build git && \
    apt install -y python-is-python3 pip python3-serial python3-future python3-cryptography && \
    apt install -y  wget &&\
    python -m pip install --upgrade pip && \
    python -m pip install --upgrade setuptools && \
    python -m pip install 'pyparsing>=2.0.3,<2.4.0' && \
    apt-get clean

# Create new user `build` and disable
# password and gecos for later
# --gecos explained well here:
# https://askubuntu.com/a/1195288/635348
RUN adduser --disabled-password --gecos '' build

#  Add new user build to sudo group
RUN adduser build sudo

# Ensure sudo group users are not
# asked for a password when using
# sudo command by ammending sudoers file
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

RUN mkdir /home/build/Downloads
RUN mkdir /home/build/esp
#COPY ./xtensa-esp32-elf-linux64-1.22.0-80-g6c4433a-5.2.0.tar.gz /home/build/Downloads/xtensa-esp32-elf-linux64-1.22.0-80-g6c4433a-5.2.0.tar.gz
RUN cd /home/build/esp
RUN wget https://dl.espressif.com/dl/xtensa-esp32-elf-linux64-1.22.0-80-g6c4433a-5.2.0.tar.gz
RUN ls
RUN tar xzf /home/build/Downloads/xtensa-esp32-elf-linux64-1.22.0-80-g6c4433a-5.2.0.tar.gz --directory /home/build/esp/
RUN rm -rf /home/build/Downloads

COPY ./docker-entrypoint.sh /home/build/docker-entrypoint.sh

ENV PATH="/home/build/esp/xtensa-esp32-elf/bin:${PATH}"
RUN /bin/bash -c 'echo ${PATH}' | tee -a /etc/profile.d/env-setup.sh

USER build

ENTRYPOINT ["/home/build/docker-entrypoint.sh"]
CMD ["/bin/bash"]
