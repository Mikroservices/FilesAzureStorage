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

### Create new file

Endpoint for creating new file in Azure storage. Endpoint supports `multipart/form-data` standard.
Thus you can use that endpoint directly from web application (or from directives like [ng2-file-upload](https://valor-software.com/ng2-file-upload/)).

**Request**

```
METHOD: POST
URL: /files
HEADERS:
    "Content-Type": "application/x-www-form-urlencoded"
    "Authorization": "Bearer eyJhbGciOiJSUzUxMi.....Y1f05c9yvA;boundary="boundary"

BODY:
--boundary 
Content-Disposition: form-data; name="field2"; filename="example.txt" 
Content-Type: text/plain

[FILE_CONTENT]
--boundary--
```

**Response**

```
STATUS: 201 (Created)
HEADERS:
    "Location": "/files/mydocuments/kyjbyv0skjmg.png"
    "Content-Type": "application/json; charset=utf-8"
BODY:
{
    "size": 254384,
    "id": "mydocuments/kyjbyv0skjmg.png",
    "name": "example.txt",
    "contentMD5": "H8+4yqZvKIIiZ9WjExlRJw=="
}
```

**Errors**

```
STATUS: 401 (Unauthorized)
```

### Get all user files

Endpoint is responsible for returning all files for specific user (user data are in access token in header).

**Request**

```
METHOD: GET
URL: /files
HEADERS:
    "Authorization": "Bearer eyJhbGciOiJSUzUxMi.....Y1f05c9yvA;boundary="boundary"
```

**Response**

```
STATUS: 200 (Ok)
HEADERS:
    "Content-Type": "application/json; charset=utf-8"
BODY:
[
    {
        "size": 254384,
        "id": "kyjbyv0skjmg.png",
        "name": "architecture.png",
        "contentMD5": "H8+4yqZvKIIiZ9WjExlRJw=="
    },
    {
        "size": 12111,
        "id": "mydocuments/sd33rsff3qfe.png",
        "name": "diagram.png",
        "contentMD5": "w8+4yqasdIiZ9WjEdwdqwd=="
    }
]
```

**Errors**

```
STATUS: 401 (Unauthorized)
```

### Get all user files from specific group

Endpoint is responsible for returning all files for specific user (user data are in access token in header).

**Request**

```
METHOD: GET
URL: /files/{groupName}
HEADERS:
    "Authorization": "Bearer eyJhbGciOiJSUzUxMi.....Y1f05c9yvA;boundary="boundary"
```

**Response**

```
STATUS: 200 (Ok)
HEADERS:
    "Content-Type": "application/json; charset=utf-8"
BODY:
[
    {
        "size": 254384,
        "id": "{groupName}/kyjbyv0skjmg.png",
        "name": "architecture.png",
        "contentMD5": "H8+4yqZvKIIiZ9WjExlRJw=="
    },
    {
        "size": 12111,
        "id": "{groupName}/sd33rsff3qfe.png",
        "name": "diagram.png",
        "contentMD5": "w8+4yqasdIiZ9WjEdwdqwd=="
    }
]
```

**Errors**

```
STATUS: 401 (Unauthorized)
```

### Get specif file

Endpoint is responsible for returning specific user file.

**Request**

```
METHOD: GET
URL: /files/{groupName}/{fileName}
HEADERS:
    "Authorization": "Bearer eyJhbGciOiJSUzUxMi.....Y1f05c9yvA;boundary="boundary"
```

**Response**

```
STATUS: 200 (Ok)
HEADERS:
    "Content-Type": "application/json; charset=utf-8"
BODY:
{
    "size": 12111,
    "id": "{groupName}/sd33rsff3qfe.png",
    "name": "diagram.png",
    "contentMD5": "w8+4yqasdIiZ9WjEdwdqwd=="
}
```

**Errors**

```
STATUS: 401 (Unauthorized)
```

```
STATUS: 404 (NotFound)
```

## Downloading file content

Service (for now) cannot return file content. However in your web application you should use directly Azure
storage API. For example you should have below URL:

```
https://{storageAccountName}.blob.core.windows.net/{userName}/{groupName}/{fileId}
```