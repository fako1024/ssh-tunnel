FROM alpine:3.12

ARG USER=tunnel
ENV HOME /home/$USER

RUN apk --no-cache --update add openssh-server openssh-client
RUN adduser -u 10000 -D $USER

COPY run.sh /home/$USER/
COPY --chown=$USER sshd_config /home/$USER/

USER $USER
WORKDIR $HOME

CMD ["./run.sh"]
