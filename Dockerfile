FROM java:openjdk-7-jdk
MAINTAINER Andrew Tongen atongen@gmail.com

RUN apt-get update && apt-get install -y \
  build-essential \
  git

# install ruby-install
RUN cd /tmp && \
  wget -O ruby-install-0.5.0.tar.gz https://github.com/postmodern/ruby-install/archive/v0.5.0.tar.gz && \
  tar -xzvf ruby-install-0.5.0.tar.gz && \
  cd ruby-install-0.5.0/ && \
  make install && \
  rm -Rf /tmp/ruby-install-0.5.0

RUN ruby-install jruby 1.7.21

COPY config/docker /

RUN export uid=1000 gid=1000 && \
  mkdir -p /home/app && \
  echo "app:x:${uid}:${gid}:app,,,:/home/app:/bin/false" >> /etc/passwd && \
  echo "app:x:${uid}:" >> /etc/group

ENV PATH /opt/rubies/jruby-1.7.21/lib/ruby/gems/shared/bin:/opt/rubies/jruby-1.7.21/bin:$PATH
RUN gem install bundler
ADD . /home/app
RUN chown -R app:app /home/app

USER app
ENV HOME /home/app
WORKDIR /home/app

ENV PATH /home/app/.gem/jruby/1.9.3/bin:$PATH
ENV GEM_HOME /home/app/.gem/jruby/1.9.3
ENV GEM_PATH /home/app/.gem/jruby/1.9.3:/opt/rubies/jruby-1.7.21/lib/ruby/gems/shared
ENV GEM_ROOT /opt/rubies/jruby-1.7.21/lib/ruby/gems/shared

RUN bundle install
ENTRYPOINT ["foreman", "start"]
EXPOSE 5000
