FROM httpd:2.4
RUN apt-get update && \
    apt-get install -y perl libcgi-pm-perl build-essential libmariadb-dev-compat libmariadb-dev  && \
    rm -rf /var/lib/apt/lists/*

    # Instalar módulos Perl con cpan
RUN cpan CGI && \
    cpan CGI::Session && \
    cpan JSON::XS && \
    cpan JSON && \
    cpan DBI && \
    cpan DBD::MariaDB
# Copiar el script y configuración CGI
COPY ./crud-scripts/ /usr/local/apache2/cgi-bin/
COPY ./conf/httpd-cgi.conf /usr/local/apache2/conf/extra/

# Incluir la configuración CGI en httpd.conf
RUN echo "Include conf/extra/httpd-cgi.conf" >> /usr/local/apache2/conf/httpd.conf

# Dar permisos ejecutables al script Perl
RUN chmod -R +x /usr/local/apache2/cgi-bin/

# Exponer el puerto 80
EXPOSE 80



