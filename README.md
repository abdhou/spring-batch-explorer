# Spring Batch Explorer

Spring Batch Explorer is a standalone application designed to provide a user-friendly interface for monitoring 
and exploring existing Spring Batch metadata databases. 
It allows developers and operators to easily track job execution statuses, 
view execution details, and manage batch jobs without directly querying the database.

## Features

- **Connect to Existing Databases**: Seamlessly connects to your existing Spring Batch metadata schema.
- **Job Instance Exploration**: List and paginate through job instances.
- **Execution Status Tracking**: View the latest execution status and total execution count for each job instance.
- **Filtering**: Search for specific jobs by name.
- **Dashboard**: Overview of total, completed, and failed jobs.
- **Detailed Execution View**: Deep dive into specific job executions, including start/end times and exit codes.

## Tech Stack

- **Backend**:
  - Java 25
  - Spring Boot 4
  - jOOQ
- **Frontend**:
  - Angular 21
  - Angular Material

## Getting Started

### Prerequisites

- Java 25 or higher
- Node.js and npm
- An existing Spring Batch metadata database (Currently, only PostgreSQL is supported)

### Environment Variables

The backend requires the following environment variables to connect to your database:

- `BATCH_DB_URL`: The JDBC URL of your Spring Batch database (e.g., `jdbc:postgresql://localhost:5432/batch_db`)
- `BATCH_DB_USERNAME`: Database username
- `BATCH_DB_PASSWORD`: Database password

### Installation & Running

#### Backend
1. Navigate to the `backend` directory.
2. Build and run using Maven:
   ```bash
   ./mvnw spring-boot:run
   ```

#### Frontend
1. Navigate to the `frontend` directory.
2. Install dependencies:
   ```bash
   npm install
   ```
3. Run the development server:
   ```bash
   npm start
   ```
   The frontend is configured to proxy API requests to `http://localhost:8080`.

## API Endpoints

- `GET /api/job-instances`: Fetch a paginated list of job instances. Supports `jobName` filter and `index`/`size` pagination parameters.
