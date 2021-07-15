# geo-tasks
Geo-based tasks tracker

Build an API to work with geo-based tasks. Use Elixir and PostgreSQL (recommended). All API endpoints should work with json body (not form-data). The result should be available as Github repo with commit history and the code covered by tests. Please commit the significant step to git, and we want to see how you evolved the source code.

Each request needs to be **authorized by token**. You can use pre-defined tokens stored on the backend side. Operate with tokens for two types of users:

1. Manager
1. Driver

Create tokens for more drivers and managers, not just 1-1.

Each task can be in 3 states:

1. New (Created task)
1. Assigned (The driver has picked this task)
1. Done (Task marked as completed by the driver)

### Access

* Manager can create tasks with two geo locations pickup and delivery
* Driver can get the list of tasks nearby (sorted by distance) by sending his current location 
* Driver can change the status of the task (to assigned/done). 
* Drivers can't create/delete tasks. 
* Managers can't change task status.

### Workflow:

1. The manager creates a task with location pickup [lat1, long1] and delivery [lat2,long2]
1. The driver gets the list of the nearest tasks by submitting current location [lat, long]
1. Driver picks one task from the list (the task becomes assigned)
1. Driver finishes the task (becomes done)

### Setup:

```bash
mix do deps.get, deps.compile
mix ecto.setup
mix phx.server
```

### Endpoints:

#### POST http://localhost:4000/api/tasks

Request:
```json
{
    "task": {
        "pickup": {"lat": 23, "lon": -63},
        "delivery": {"lat": 28, "lon": -60}
    }
}
```

Response:
```json
{
    "delivery": {
        "lat": 28,
        "lon": -60
    },
    "id": "9c2288c2-d04c-4463-be24-c8a80704a1e6",
    "inserted_at": "2021-07-15T15:28:33",
    "pickup": {
        "lat": 23,
        "lon": -63
    },
    "status": "new",
    "updated_at": "2021-07-15T15:28:33",
    "user_id": null
}
```

Status: **201 (Created)**

#### GET http://localhost:4000/api/tasks?lat=-23&lon=6.5&first=5

Request: *no body*

Respomse:
```json
{
    "tasks": [
        {
            "delivery": {
                "lat": -63.0,
                "lon": 108.0
            },
            "id": "16eb1cdd-dc70-4652-9e8a-bc39626dd8fd",
            "inserted_at": "2021-07-14T15:55:00",
            "pickup": {
                "lat": -60.0,
                "lon": 12.0
            },
            "status": "new",
            "updated_at": "2021-07-14T15:55:00",
            "user_id": null
        },
        {
            "delivery": {
                "lat": -43.0,
                "lon": 30.0
            },
            "id": "eb4eea9b-2c7d-40bf-b9ce-f3711c4b68f3",
            "inserted_at": "2021-07-14T15:55:00",
            "pickup": {
                "lat": 25.0,
                "lon": 22.0
            },
            "status": "new",
            "updated_at": "2021-07-14T15:55:00",
            "user_id": null
        }
    ]
}
```

Status: **200 (OK)**

#### PUT http://localhost:4000/api/tasks/:id

Request:
```json
{
    "task": {
        "status": "assigned"
    }
}
```

Response:
```json
{
    "delivery": {
        "lat": 76.0,
        "lon": 171.0
    },
    "id": "d8ec8527-01c5-40ec-9cad-84b4b1ce4136",
    "inserted_at": "2021-07-14T15:55:00",
    "pickup": {
        "lat": -50.0,
        "lon": -106.0
    },
    "status": "assigned",
    "updated_at": "2021-07-14T15:58:20",
    "user_id": "d9d2e52f-e28d-4124-befa-136bd70d66e5"
}
```

Status: **200 (OK)**

#### GET http://localhost:4000/api/tasks/:id

Request: *no body*

Response:
```json
{
    "delivery": {
        "lat": 76.0,
        "lon": 171.0
    },
    "id": "d8ec8527-01c5-40ec-9cad-84b4b1ce4136",
    "inserted_at": "2021-07-14T15:55:00",
    "pickup": {
        "lat": -50.0,
        "lon": -106.0
    },
    "status": "assigned",
    "updated_at": "2021-07-14T15:58:20",
    "user_id": "d9d2e52f-e28d-4124-befa-136bd70d66e5"
}
```
Status: **200 (OK)**

#### DELETE http://localhost:4000/api/tasks/:id

Request: *no body*

Response: *no body*

Status: **204 (No Content)**

### Headers:

`Authorization: Bearer <token>`
