# :open_file_folder: Files Azure Storage

[![Build Status](https://travis-ci.org/Mikroservices/FilesAzureStorage.svg?branch=master)](https://travis-ci.org/Mikroservices/FilesAzureStorage) [![Swift 4.0](https://img.shields.io/badge/Swift-4.0-orange.svg?style=flat)](ttps://developer.apple.com/swift/) [![Platforms OS X | Linux](https://img.shields.io/badge/Platforms-OS%20X%20%7C%20Linux%20-lightgray.svg?style=flat)](https://developer.apple.com/swift/)

Service responsible for storage files into Azure Storage.

## Getting started

First you need to have [Swift](https://swift.org) installed on your computer. 
Next you should run following commands:

```bash
$ git clone https://github.com/Mikroservices/FilesAzureStorage.git
$ cd FilesAzureStorage
$ swift package update
$ swift build
```

If application successfully builds you need to set up all required environment variables: 

| Variable                                | Description                                |
|-----------------------------------------|--------------------------------------------|
| MIKROSERVICE_JWT_PUBLIC_KEY             | JWT public key for validation access token |
| MIKROSERVICE_AZURE_STORAGE_SECRET_KEY   | Secret key for Azure storage               |
| MIKROSERVICE_AZURE_STORAGE_ACCOUNT_NAME | Account name for Azure storage             |

JWT key must be public key from pair private/public keys which is used in `User` microservice.
Private key is used for signing-in JWT access token.

You can set up this variable as:

1. environment variable in your system
2. environment variable in XCode

Now you can run the application:

```bash
$ .build/debug/Run --port 8004
```

If application starts open following link in your browser: [http://localhost:8004](http://localhost:8004).
You should see blank page with text: *Service is up and running!*. Now you can use API which is described below.


## API

Service provides simple RESTful API. Below there is a description of each endpoint.

- [`POST /files`](Docs/files/create.md) - create new file
- [`GET /files`](Docs/files/get-all.md) - get all user files
- [`GET /files/{groupName}`](Docs/files/get-all-from-group.md) - get all user files from specific group
- [`/files/{groupName}/{fileName}`](Docs/files/get-file.md) - get file data

## Downloading file content

Service (for now) cannot return file content. However in your web application you should use directly Azure
storage API. For example you should have below URL:

```
https://{storageAccountName}.blob.core.windows.net/{userName}/{groupName}/{fileId}
```