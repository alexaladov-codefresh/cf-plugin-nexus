FROM alpine

RUN apk add --update --virtual builddeps \
    build-base libffi-dev openssl-dev python-dev \
&&  apk add --update \
    bash \ 
    python py-pip \  
    nodejs nodejs-npm \         
    ruby ruby-rdoc\                      
&&  pip install --upgrade pip \
&&  pip install nexus3-cli setuptools wheel twine \
&&  gem install nexus \
&&  apk del builddeps \
&&  rm -f /var/cache/apk/* \
&&  rm -rf /root/.cache/pip/

COPY script.sh /script.sh
RUN chmod +x /script.sh

CMD ["/script.sh"]
