# README

Chat Jurídico API

Intelligent legal chat platform built with Ruby on Rails (API-only)

This project is part of a legal office's solution to streamline client communication using a guided question flow and AI-generated responses, validated by legal professionals.

🚀 Overview

Clients access a private chat interface where they are guided through predefined questions to help formulate their legal inquiries. These are then processed by an AI (ChatGPT-based), and reviewed by attorneys before being sent back to the client.

Staff users (Admins, Managers, Assistants) access a dashboard where they:

View and filter conversations

Review AI responses

Validate, edit or fully rewrite responses

📃 Technologies

Ruby on Rails 8 (API Mode)

PostgreSQL (Relational database)

BCrypt for password encryption

Role-based access (admin, manager, assistant)

JWT (future) for secure API authentication

Next.js (frontend) [not included in this repo]

🚧 Project Structure

app/models — business logic (e.g. User, Client, Message)

app/controllers — API endpoints (RESTful)

config/routes.rb — API routes

db/migrate — database structure via migrations

.env / master.key — (ignored) contains API keys and secrets

✨ Getting Started

Requirements:

Ruby 3.2+

Rails 8+

PostgreSQL 12+

Install dependencies:

git clone https://github.com/your-user/chat_juridico_api.git
cd chat_juridico_api
bundle install
rails db:create db:migrate

Run development server:

rails s

🔐 Access Control

Users have one of the following roles:

Admin — Full control. Can create/delete users, assign access, view all clients.

Manager — Can see all clients and assign assistants. Cannot delete/create users.

Assistant — Only sees conversations from assigned clients.

🤖 AI Integration (Planned)

Integration with OpenAI ChatGPT for answer generation

Feedback mechanism to train and improve responses over time

👤 Author

Gabriel Ribeiro Pires

Feel free to open issues, ask questions or contribute.
