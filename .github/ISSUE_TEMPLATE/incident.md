name: Incident Report
about: Report an ongoing incident
title: '[Incident] '
labels: 'incident,status:investigating'
assignees: ''
body:
  - type: markdown
    attributes:
      value: |
        Thanks for reporting an incident. Please fill out the details below.
  - type: input
    id: affected-service
    attributes:
      label: Affected Service
      description: Which service is experiencing issues?
      placeholder: e.g., API, Website, Database
    validations:
      required: true
  - type: textarea
    id: description
    attributes:
      label: Description
      description: Describe the incident in detail
      placeholder: What is happening? What are users experiencing?
    validations:
      required: true
  - type: input
    id: start-time
    attributes:
      label: Estimated Start Time
      description: When did the incident start?
      placeholder: YYYY-MM-DD HH:MM UTC
    validations:
      required: false