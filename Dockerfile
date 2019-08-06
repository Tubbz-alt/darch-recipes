FROM archlinux/base:latest

RUN echo -e "[aurnar]\nSigLevel = Never\nServer = https://f000.backblazeb2.com/file/aurnar/x86_64" >> /etc/pacman.conf && \
    yes | pacman -Suyy && \
    pacman -S --noconfirm backblaze-b2 aurutils base-devel python-dateutil

COPY base/aurnar /usr/bin/aurnar

RUN echo -e "#!/bin/bash\nbackblaze-b2 authorize-account \$B2_ACCOUNT_ID \$B2_ACCOUNT_KEY\naurnar sync --noconfirm" > /sync.sh && \
    chmod +x sync.sh

# makepkg doesn't run as root
RUN groupadd -g 1000 runner && \
    useradd -u 1000 -g runner -m -s /usr/bin/nologin runner && \
    echo "runner ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/runner

# Make GPG auto pull keys
RUN mkdir /home/runner/.gnupg && \
    echo -e "keyserver hkps://pgp.mit.edu\nkeyserver hkps://hkps.pool.sks-keyservers.net\nkeyserver-options auto-key-retrieve\nrequire-cross-certification\nkeyring /etc/pacman.d/gnupg/pubring.gpg" > /home/runner/.gnupg/gpg.conf && \
    chown -R runner:runner /home/runner/.gnupg && \
    chmod 700 /home/runner/.gnupg && \
    chmod 600 /home/runner/.gnupg/gpg.conf

USER runner

ENTRYPOINT /sync.sh
