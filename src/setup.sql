DO $$
BEGIN
    IF to_regclass('public.projects') IS NULL
       AND to_regclass('public.service_project') IS NOT NULL THEN
        ALTER TABLE public.service_project RENAME TO projects;
        ALTER TABLE public.projects RENAME COLUMN service_project_id TO project_id;
        ALTER TABLE public.projects RENAME COLUMN project_date TO date;
        ALTER TABLE public.projects
            ADD COLUMN location VARCHAR(200) NOT NULL DEFAULT 'Location to be announced';
    END IF;

    IF to_regclass('public.project_categories') IS NULL
       AND to_regclass('public.category') IS NOT NULL THEN
        ALTER TABLE public.category RENAME TO project_categories;
        ALTER TABLE public.project_categories
            ADD COLUMN description TEXT NOT NULL DEFAULT '';
    END IF;

    IF to_regclass('public.organization') IS NOT NULL
       AND EXISTS (
           SELECT 1 FROM information_schema.columns
           WHERE table_schema = 'public'
             AND table_name = 'organization'
             AND column_name = 'logo_filename'
       )
       AND NOT EXISTS (
           SELECT 1 FROM information_schema.columns
           WHERE table_schema = 'public'
             AND table_name = 'organization'
             AND column_name = 'logo'
       ) THEN
        ALTER TABLE public.organization RENAME COLUMN logo_filename TO logo;
    END IF;

    IF to_regclass('public.project_category') IS NOT NULL
       AND EXISTS (
           SELECT 1 FROM information_schema.columns
           WHERE table_schema = 'public'
             AND table_name = 'project_category'
             AND column_name = 'service_project_id'
       )
       AND NOT EXISTS (
           SELECT 1 FROM information_schema.columns
           WHERE table_schema = 'public'
             AND table_name = 'project_category'
             AND column_name = 'project_id'
       ) THEN
        ALTER TABLE public.project_category
            RENAME COLUMN service_project_id TO project_id;
    END IF;
END;
$$;

CREATE TABLE IF NOT EXISTS organization (
    organization_id SERIAL PRIMARY KEY,
    name VARCHAR(150) NOT NULL,
    description TEXT NOT NULL,
    contact_email VARCHAR(255) NOT NULL,
    logo VARCHAR(255) NOT NULL
);

INSERT INTO organization (name, description, contact_email, logo)
SELECT incoming.name, incoming.description, incoming.contact_email, incoming.logo
FROM (
    VALUES
        ('BrightFuture Builders',
         'A nonprofit focused on improving community infrastructure through sustainable construction projects.',
         'info@brightfuturebuilders.org',
         'brightfuture-logo.png'),
        ('GreenHarvest Growers',
         'An urban farming collective promoting food sustainability and education in local neighborhoods.',
         'contact@greenharvest.org',
         'greenharvest-logo.png'),
        ('UnityServe Volunteers',
         'A volunteer coordination group supporting local charities and service initiatives.',
         'hello@unityserve.org',
         'unityserve-logo.png')
) AS incoming (name, description, contact_email, logo)
WHERE NOT EXISTS (
    SELECT 1 FROM organization WHERE organization.name = incoming.name
);

CREATE TABLE IF NOT EXISTS projects (
    project_id SERIAL PRIMARY KEY,
    project_title VARCHAR(200) NOT NULL,
    date DATE NOT NULL,
    location VARCHAR(200) NOT NULL,
    organization_id INTEGER NOT NULL REFERENCES organization (organization_id)
);

INSERT INTO projects (date, project_title, location, organization_id)
SELECT project.date, project.project_title, project.location, organization.organization_id
FROM (
    VALUES
        ('2027-03-06'::DATE, 'Park Trail Restoration', 'Riverside Community Park', 'BrightFuture Builders'),
        ('2027-03-20'::DATE, 'Community Playground Repairs', 'Maple Street Playground', 'BrightFuture Builders'),
        ('2027-04-03'::DATE, 'Neighborhood Accessibility Improvements', 'Downtown Community Center', 'BrightFuture Builders'),
        ('2027-04-17'::DATE, 'Community Garden Path Construction', 'Eastside Community Garden', 'BrightFuture Builders'),
        ('2027-05-01'::DATE, 'Riverwalk Clean-Up and Repair', 'Greenway Riverwalk', 'BrightFuture Builders'),
        ('2027-03-07'::DATE, 'Community Seedling Giveaway', 'GreenHarvest Urban Farm', 'GreenHarvest Growers'),
        ('2027-03-21'::DATE, 'School Garden Planting Day', 'Lincoln Elementary School', 'GreenHarvest Growers'),
        ('2027-04-04'::DATE, 'Neighborhood Compost Workshop', 'Westside Library', 'GreenHarvest Growers'),
        ('2027-04-18'::DATE, 'Urban Orchard Care Day', 'Cedar Avenue Orchard', 'GreenHarvest Growers'),
        ('2027-05-02'::DATE, 'Community Harvest Festival', 'GreenHarvest Urban Farm', 'GreenHarvest Growers'),
        ('2027-03-13'::DATE, 'Food Bank Volunteer Day', 'County Food Bank', 'UnityServe Volunteers'),
        ('2027-03-27'::DATE, 'Senior Center Technology Help', 'Oakwood Senior Center', 'UnityServe Volunteers'),
        ('2027-04-10'::DATE, 'Community Clothing Drive', 'UnityServe Resource Center', 'UnityServe Volunteers'),
        ('2027-04-24'::DATE, 'Youth Mentoring Kickoff', 'Northside Youth Center', 'UnityServe Volunteers'),
        ('2027-05-08'::DATE, 'Neighborhood Resource Fair', 'Central City Plaza', 'UnityServe Volunteers')
) AS project (date, project_title, location, organization_name)
JOIN organization ON organization.name = project.organization_name
WHERE NOT EXISTS (
    SELECT 1
    FROM projects AS existing
    WHERE existing.project_title = project.project_title
      AND existing.organization_id = organization.organization_id
);

UPDATE projects
SET location = sample.location
FROM (
    VALUES
        ('Park Trail Restoration', 'Riverside Community Park'),
        ('Community Playground Repairs', 'Maple Street Playground'),
        ('Neighborhood Accessibility Improvements', 'Downtown Community Center'),
        ('Community Garden Path Construction', 'Eastside Community Garden'),
        ('Riverwalk Clean-Up and Repair', 'Greenway Riverwalk'),
        ('Community Seedling Giveaway', 'GreenHarvest Urban Farm'),
        ('School Garden Planting Day', 'Lincoln Elementary School'),
        ('Neighborhood Compost Workshop', 'Westside Library'),
        ('Urban Orchard Care Day', 'Cedar Avenue Orchard'),
        ('Community Harvest Festival', 'GreenHarvest Urban Farm'),
        ('Food Bank Volunteer Day', 'County Food Bank'),
        ('Senior Center Technology Help', 'Oakwood Senior Center'),
        ('Community Clothing Drive', 'UnityServe Resource Center'),
        ('Youth Mentoring Kickoff', 'Northside Youth Center'),
        ('Neighborhood Resource Fair', 'Central City Plaza')
) AS sample (project_title, location)
WHERE projects.project_title = sample.project_title
  AND projects.location = 'Location to be announced';

CREATE TABLE IF NOT EXISTS project_categories (
    category_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT NOT NULL
);

INSERT INTO project_categories (name, description)
VALUES
    ('Environmental', 'Projects that care for and improve the natural environment.'),
    ('Educational', 'Projects that support learning, teaching, and skill development.'),
    ('Community Service', 'Projects that strengthen and support the local community.'),
    ('Health and Wellness', 'Projects that promote physical, mental, and social well-being.'),
    ('Food Security', 'Projects that improve access to nutritious food.')
ON CONFLICT (name) DO UPDATE
SET description = EXCLUDED.description;

CREATE TABLE IF NOT EXISTS project_category (
    project_id INTEGER NOT NULL
        REFERENCES projects (project_id) ON DELETE CASCADE,
    category_id INTEGER NOT NULL
        REFERENCES project_categories (category_id) ON DELETE CASCADE,
    PRIMARY KEY (project_id, category_id)
);

INSERT INTO project_category (project_id, category_id)
SELECT projects.project_id, project_categories.category_id
FROM (
    VALUES
        ('Park Trail Restoration', 'Environmental'),
        ('Park Trail Restoration', 'Community Service'),
        ('Community Playground Repairs', 'Community Service'),
        ('Community Playground Repairs', 'Health and Wellness'),
        ('Neighborhood Accessibility Improvements', 'Community Service'),
        ('Neighborhood Accessibility Improvements', 'Health and Wellness'),
        ('Community Garden Path Construction', 'Environmental'),
        ('Community Garden Path Construction', 'Community Service'),
        ('Riverwalk Clean-Up and Repair', 'Environmental'),
        ('Riverwalk Clean-Up and Repair', 'Community Service'),
        ('Community Seedling Giveaway', 'Environmental'),
        ('Community Seedling Giveaway', 'Food Security'),
        ('School Garden Planting Day', 'Environmental'),
        ('School Garden Planting Day', 'Educational'),
        ('Neighborhood Compost Workshop', 'Environmental'),
        ('Neighborhood Compost Workshop', 'Educational'),
        ('Urban Orchard Care Day', 'Environmental'),
        ('Urban Orchard Care Day', 'Food Security'),
        ('Community Harvest Festival', 'Community Service'),
        ('Community Harvest Festival', 'Health and Wellness'),
        ('Food Bank Volunteer Day', 'Community Service'),
        ('Food Bank Volunteer Day', 'Health and Wellness'),
        ('Food Bank Volunteer Day', 'Food Security'),
        ('Senior Center Technology Help', 'Educational'),
        ('Senior Center Technology Help', 'Community Service'),
        ('Community Clothing Drive', 'Community Service'),
        ('Youth Mentoring Kickoff', 'Educational'),
        ('Youth Mentoring Kickoff', 'Community Service'),
        ('Neighborhood Resource Fair', 'Community Service'),
        ('Neighborhood Resource Fair', 'Health and Wellness')
) AS assignment (project_title, category_name)
JOIN projects ON projects.project_title = assignment.project_title
JOIN project_categories
  ON project_categories.name = assignment.category_name
ON CONFLICT DO NOTHING;
