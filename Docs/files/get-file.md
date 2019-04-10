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