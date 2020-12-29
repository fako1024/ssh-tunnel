FROM alpine:3.12

RUN apk --no-cache --update add openssh-server openssh-client
RUN sed -i s/root:!/"root:*"/g /etc/shadow

COPY run.sh /
COPY sshd_config /etc/ssh/

CMD ["/run.sh"]
