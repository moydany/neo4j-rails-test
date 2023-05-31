# Metrics API

Metrics API is a Ruby on Rails application that exposes a RESTful API to create, retrieve, and delete metrics. It uses a Neo4j database to store data and leverages Docker for easy setup and deployment.

## Application Functionality

1. The Metrics API allows for the creation of metrics via a POST request to the '/metric/{key}' endpoint. A metric consists of a name, a key, a value, and a timestamp.
2. Metrics can be fetched in multiple ways:
   - Fetch all metrics: GET '/metrics/all'
   - Fetch a metric by key: GET '/metric/key/{key}'
   - Fetch a metric by name: GET '/metric/name/{name}'
3. Metrics can be deleted by sending a DELETE request to '/metric/{key}'.
4. An aggregate endpoint is available to fetch the total of metrics within the last hour grouped by name: GET '/metrics/aggregate'

### Create Function

The `create` function handles the creation of a metric object based on the provided parameters. The `name` parameter is optional, and if not defined, the function generates a name based on the index of the metric. Here's how it works:

1. `metric_params` is extracted from the `params` object, containing only the permitted `value` parameter.
2. `metric_attributes` is created by merging `metric_params` with additional attributes, such as the current timestamp (`Time.now.to_i`) and the `key` parameter from `params`.
3. The variable `next_index` is calculated by adding 1 to the count of existing metrics in the database (`Metric.count`). This is used to generate a default name if `params.dig(:metric, :name)` is not provided.
4. If `params.dig(:metric, :name)` is not defined, the `metric_name` variable is set to a default name format using the `next_index`.
5. The `name` attribute in `metric_attributes` is assigned the value of `metric_name`.
6. It checks if a metric with the same `key` already exists in the database. If so, it returns an error message with a `:conflict` status.
7. If no conflicting metric exists, a new `Metric` object is created with `metric_attributes`.
8. If the metric is successfully saved, it returns the metric object with a `:created` status. Otherwise, it returns any validation errors with an `:unprocessable_entity` status.

### Aggregate Function

The `aggregate` function retrieves all metrics with timestamps within the past one hour. It uses a query to select metrics where the timestamp is greater than the value of `one_hour_ago`, which is calculated as 1 hour ago in Unix timestamp format (`1.hour.ago.to_i`).

The retrieved metrics are then grouped by their `name` attribute using `group_by`. For each unique metric name, the function calculates the total value by summing the `value` attribute of each metric.

Finally, the aggregated metrics are formatted as an array of objects, each containing the `name` and `total` attributes. The result is returned as a JSON response using `render json: aggregated_metrics`.

These functions can be used to create and aggregate metrics in the Metric Logging and Reporting Service, providing a way to track and summarize metric data over time.


## Getting Started

To run the Metrics API, you will need Docker installed on your machine. If you don't have Docker installed, you can download it [here](https://www.docker.com/products/docker-desktop).

Once Docker is installed, navigate to the root directory of the project and run the following command:

```
docker-compose up
```

This command will build the Docker images and start the containers based on the `docker-compose.yml` and `Dockerfile` specifications. The API will be accessible at `localhost:3000`.

## Testing

### Unit Tests

Unit tests are written using the Rails testing framework. To run the tests, uncomment the line in the `docker-compose.yml` file that starts with `bundle exec rails test && exit 0`. Then, run `docker-compose up` again.

### Postman Tests

I provide a collection of Postman tests. To run these tests:

1. Install [Postman](https://www.postman.com/downloads/) if you haven't already.
2. Go to the following URL and import the collection: [Postman Collection](https://www.postman.com/restless-shadow-8821/workspace/valid-eval/collection/4494437-9a57cff5-c00c-4586-8620-ca9e189f7533?action=share&creator=4494437).
3. Make sure your Metrics API server is running.
4. In Postman, select the collection you just imported and click "Run".

## Accessing Neo4j Web App

The Metric Logging and Reporting Service utilizes Neo4j as the underlying database. To access the Neo4j web app for further administration and data visualization, follow these steps:

1. Make sure the Metric Logging and Reporting Service and Neo4j are running.
2. Open a web browser and navigate to [http://0.0.0.0:7474/browser/](http://0.0.0.0:7474/browser/).
3. You will be prompted to enter the login credentials. By default, the username is set to `neo4j` and password to `password`.
4. Once logged in, you can interact the Neo4j web app.

Please note that accessing the Neo4j web app requires both the Metric Logging and Reporting Service and Neo4j to be running simultaneously.