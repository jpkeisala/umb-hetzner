FROM mcr.microsoft.com/azure-sql-edge:latest

ENV ACCEPT_EULA=Y

USER root

RUN mkdir /var/opt/sqlserver

RUN chown mssql /var/opt/sqlserver

EXPOSE 1433/tcp
COPY setup.sql /
COPY startup.sh /
COPY healthcheck.sh /

# Make scripts executable
RUN chmod +x /healthcheck.sh
RUN chmod +x /startup.sh

ENTRYPOINT [ "/bin/bash", "startup.sh" ]
CMD [ "/opt/mssql/bin/sqlservr" ]