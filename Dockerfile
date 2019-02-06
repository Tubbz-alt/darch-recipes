FROM archlinux/base:latest

RUN echo -e "[aurnar]\nSigLevel = Never\nServer = https://f000.backblazeb2.com/file/aurnar/x86_64" >> /etc/pacman.conf && \
    pacman -Syy --noconfirm && \
    pacman -S --noconfirm backblaze-b2 aurutils

COPY base/aurnar /usr/bin/aurnar

RUN echo -e "#!/bin/bash\nbackblaze-b2 authorize-account \$B2_ACCOUNT_ID \$B2_ACCOUNT_KEY\naurnar sync" > /sync.sh && \
    chmod +x sync.sh

# makepkg doesn't run as root
RUN groupadd -g 1000 runner && useradd -u 1000 -g runner -r -M -s /usr/bin/nologin runner

USER runner

ENTRYPOINT /sync.sh