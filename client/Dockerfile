FROM alpine:3.20

RUN apk --no-cache --update add openssh-server openssh-client
RUN sed -i s/root:!/"root:*"/g /etc/shadow

COPY run.sh /
COPY tunnel /bin/
COPY sshd_config /etc/ssh/

EXPOSE 2222

CMD ["/run.sh"]

