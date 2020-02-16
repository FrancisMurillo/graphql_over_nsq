## GraphQL over NSQ

An exploration of using a message queue as a GraphQL transport via
`elixir`, `absinthe`, `conduit` and `nsq`. Checkout the [corresponding
article](https://francismurillo.github.io/2020-02-17-Elixir-Musing-GraphQL-Over-A-Message-Queue/)
for more context.

## Setup

This uses `docker-compose` to set everything up:

```
docker-compose up
```

Take note that everytime the services are up, do note it also resets the
data so subsequent runs might require different ids.

## Ports

The exposed ports to visit:

- `http://localhost:14151/stats`    - NSQ Daemon Statistics
- `http://localhost:14000/graphiql` - Main API Gateway GraphiQL

- `http://localhost:15000/graphiql` - Account Service GraphiQL
- `http://localhost:16000/graphiql` - Product Service GraphiQL
- `http://localhost:17000/graphiql` - Transaction Service GraphiQL

## GraphiQL

When using the `api_gateway`, you can execute the following queries:

### List Users

List available users. By default, 5 random users are seeded.

```
query {
  users {
    id
    email
    firstName
    lastName
  }
}
```

### Register User

Register a user.

```
mutation {
  registerUser($email: String!, $firstName: String!, $lastName: String!)
  {
    errors {
      field
      message
    }
    user {
      id
      email
      firstName
      lastName
    }
  }
}
```

Variables:

```
{
  "email": "my@email.com",
  "firstName": "MY,
  "lastName": "NAME
}
```

### List Products

List products. By default, 10 random products are seeded.

```
query {
  products {
    id
    code
    name
    price
  }
}
```

### Create Transaction

Given an user and products, create a transaction for that person. The
most complicated operation in this list.

To pretend we have authentication, we will use an user's email
(`$USER_EMAIL`) from the `users` query as an OAuth token. In the
GraphiQL interface

1. Click the `Standard` > `OAuth 2 Bearer Token`
2. In the dialog box, put the `$USER_EMAIL` after the `Bearer ` text.
   You should have something like this.

```
Name:    Authorization
Value:   Bearer my@email.com
```

```
mutation($items: [CreateTransactionItem!]!) {
  create_transaction(
    input: {
      items: $items
    }
  ) {
    errors {
      field
      message
    }
    transaction {
      id
      code
      items {
        id
        product_id
        price
        quantity
      }
    }
  }
}
```

Variables:

Replace `$PRODUCT_ID` with a `Product.id` from the `products` query.

```
{
  "itens": [
    {
      "productId": "$PRODUCT_ID",
      "quantity": 1
    }
  ]
}
```

### User Transactions

Like listing all users, this also includes their transactions made.

```
query {
  users {
    id
    email
    transactions {
      id
      code
      items {
        product {
          id
          code
          name
          price
        }
        price
        quantity
      }
    }
  }
}
```
