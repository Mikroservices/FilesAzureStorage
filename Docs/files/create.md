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