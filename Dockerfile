FROM swift:4.2
LABEL Description="Letterer Files Azure Storage" Vendor="Marcin Czachurski" Version="1.0"

ADD . /files-azure-storage
WORKDIR /files-azure-storage

RUN swift build --configuration release
EXPOSE 8004
ENTRYPOINT [".build/release/Run", "--port", "8004", "--hostname", "0.0.0.0"]