# cse340-course-repo

## Running and deploying

Run `src/setup.sql` against the PostgreSQL database before starting the app. It creates or upgrades the schema and inserts the sample organizations, projects, and categories.

Set `DATABASE_URL` (or `DB_URL`) to the PostgreSQL connection string in the deployment environment. Start the server with `npm start`; it listens on Render's assigned port and serves the home, organizations, projects, and categories pages.