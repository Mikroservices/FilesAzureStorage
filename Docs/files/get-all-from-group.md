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