# Pinpoint HiBob Integration API

## Overview

This application serves as an integration bridge between Pinpoint (an applicant tracking system) and HiBob (an HR management system). It automates the employee onboarding process by creating employee records in HiBob when candidates are hired through Pinpoint.

## System Architecture

The application follows a standard Rails architecture with the following key components:

### APIs

- **PinpointApi**: Interfaces with Pinpoint's API to fetch application data and create comments on applications
- **HibobApi**: Interfaces with HiBob's API to create employees and upload documents

### Services

- **Pinpoint::ApplicationHiredHibobService**: Processes hired candidates from Pinpoint and creates corresponding employee records in HiBob, including CV uploads
- **Pinpoint::VerifyWebhook**: Authenticates incoming webhook requests from Pinpoint using HMAC validation

### Controllers

- **WebhooksController**: Receives webhook notifications from Pinpoint, verifies them, and enqueues processing jobs

## Main Workflow

1. Pinpoint sends a webhook when a candidate is hired
2. The webhook is authenticated and recorded
3. A background job processes the event
4. The service fetches detailed application data from Pinpoint
5. An employee record is created in HiBob with the candidate's information
6. If available, the candidate's CV is uploaded to HiBob
7. A confirmation comment is posted back to the Pinpoint application

## Setup

### Ruby Version
- Ruby 3.4.2

### System Dependencies
- SQLite

### Configuration
1. Clone the repository
2. Run `bundle install`
3. Create and fill config/master.key

### Database Setup
```
rails db:create
rails db:migrate
```

## Running the Application

### Development
```
rails server
```

## Testing
```
bundle exec rspec
```

## Webhook Endpoints
- Pinpoint webhook: POST /webhooks/pinpoint
