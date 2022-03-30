FROM alpine:edge

ENV redis redis://redis:6379
EXPOSE 3000 1234

ARG COC='coc-css coc-pairs coc-html coc-json coc-prettier coc-tsserver coc-yaml'

RUN apk add --no-cache sed \
    && sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories
RUN apk add --no-cache curl ripgrep tree-sitter git python3 py3-pip fd nodejs npm yarn fish neovim g++ make \
    && yarn global add neovim

COPY ./root/ /root/
VOLUME /root/workspace

RUN curl -fLo /root/.local/share/nvim/site/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

# Install Neovim extensions.
RUN yarn config set registry https://registry.npm.taobao.org/ \
    && nvim --headless +PlugInstall +qall
RUN nvim --headless +"TSInstallSync maintained" +qall
RUN nvim --headless +"CocInstall $COC -sync" +qall

WORKDIR /root/workspace

# Avoid container exit.
CMD ["tail", "-f", "/dev/null"]
