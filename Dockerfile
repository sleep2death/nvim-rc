FROM alpine:3.15.3

ENV redis redis://redis:6379
EXPOSE 3000

RUN apk add --no-cache sed \
    && sed -i 's/dl-cdn.alpinelinux.org/mirrors.tuna.tsinghua.edu.cn/g' /etc/apk/repositories \
    && apk add --no-cache curl ripgrep tree-sitter git python3 py3-pip nodejs yarn fish \
    && yarn global add neovim
# Install Neovim from source.
RUN apk add --no-cache build-base cmake automake autoconf libtool pkgconf coreutils curl unzip gettext-tiny-dev \
  && mkdir -p /root/TMP \
  && cd /root/TMP && git clone https://github.com/neovim/neovim \
  && cd /root/TMP/neovim && git checkout stable && make -j4 && make install \
  && rm -rf /root/TMP

COPY ./root/ /root/
VOLUME /root/workspace

RUN curl -fLo /root/.local/share/nvim/site/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

# Install Neovim extensions.
RUN yarn config set registry https://registry.npm.taobao.org/ \
    && nvim --headless +PlugInstall +qall

WORKDIR /root/workspace
ENTRYPOINT [ "fish" ]
