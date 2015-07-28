FROM postgres:9.4
MAINTAINER Andrew Tongen atongen@gmail.com

RUN localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8
ENV LANG en_US.utf8

RUN pg_createcluster 9.4 main
RUN /etc/init.d/postgresql start
RUN cat /etc/postgresql/9.4/main/postgresql.conf

USER postgres
RUN createuser --superuser docker
RUN createdb -O docker chat_development
RUN createdb -O docker chat_test
RUN createdb -O docker chat_production
RUN psql -c "alter user docker with password 'docker';"
