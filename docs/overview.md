# WebStats Overview

WebStats is an open-source uptime monitoring platform built on GitHub Actions and GitHub Pages. It provides real-time status monitoring for your services with a beautiful terminal-core UI design.

## Purpose

WebStats solves the need for free, reliable uptime monitoring without requiring infrastructure. It leverages GitHub's ecosystem to provide:
- Free hosting on GitHub Pages
- Scheduled monitoring via GitHub Actions
- Automatic incident reporting via GitHub Issues
- Beautiful, developer-friendly UI

## Key Features

### Core Functionality
- **Scheduled Monitoring**: Runs every 5 minutes via GitHub Actions cron
- **HTTP Checks**: Supports GET, POST, and other HTTP methods
- **Assertions**: Validates status codes, response content, and headers
- **Response Times**: Measures and tracks response times
- **Uptime Calculations**: Real-time uptime percentage calculations

### UI/UX Features
- **Terminal-Core Design**: Dark theme following 60-30-10 design rule
- **Responsive Layout**: Works on all device sizes
- **Real-time Data**: Displays latest monitoring results
- **Historical Views**: Shows check history and trends
- **Incident Tracking**: Displays past incidents and resolutions

### Technical Features
- **NDJSON Storage**: Efficient data storage format
- **Static Site Generation**: Fast, secure frontend
- **Custom Domain Support**: Easy custom domain setup
- **GitHub Integration**: Leverages GitHub Actions and Issues
- **Monorepo Architecture**: Organized codebase structure

## Architecture Principles

### Zero Infrastructure
- No servers to manage
- No databases to provision
- No monitoring infrastructure to maintain
- Leverages GitHub's robust infrastructure

### Git-Based Storage
- All monitoring data stored in git repository
- Full history and version control
- Easy backup and recovery
- Collaborative access control

### Scalable Design
- Horizontal scaling through configuration
- Efficient data storage prevents repo bloat
- Modular architecture supports extensibility
- Resource-efficient monitoring engine

## Technology Stack

### Frontend
- **Framework**: Astro
- **Language**: TypeScript, JSX
- **Styling**: Tailwind CSS
- **Components**: Custom-built with terminal-core aesthetic

### Backend/Monitoring
- **Runtime**: Node.js
- **Language**: TypeScript
- **HTTP Client**: Axios
- **Data Format**: NDJSON
- **Configuration**: YAML

### Infrastructure
- **Hosting**: GitHub Pages
- **Scheduling**: GitHub Actions
- **Storage**: Git repository
- **CI/CD**: GitHub Actions workflows

## Design Philosophy

### Terminal-Core Aesthetic
- **Dark Mode First**: Reduces eye strain
- **Monospace Typography**: Familiar to developers
- **Color Hierarchy**: Electric accents for important elements
- **Code-Like Information**: Structured, hierarchical presentation

### Developer Experience
- **Single Config File**: All settings in one place
- **Template Repository**: One-click setup
- **Clear Documentation**: Comprehensive guides
- **Minimal Dependencies**: Lightweight and fast

## Use Cases

### Personal Projects
- Monitor personal websites and APIs
- Track uptime for hobby projects
- Get started with status pages quickly

### Small Teams
- Provide status transparency to users
- Track service reliability metrics
- Automate incident reporting

### Open Source Projects
- Demonstrate service reliability
- Provide transparent status to users
- Maintain professional image