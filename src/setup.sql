CREATE TABLE organization (
    organization_id SERIAL PRIMARY KEY,
    name VARCHAR(150) NOT NULL,
    description TEXT NOT NULL,
    contact_email VARCHAR(255) NOT NULL,
    logo_filename VARCHAR(255) NOT NULL
);

INSERT INTO organization (name, description, contact_email, logo_filename)
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
 'unityserve-logo.png');

SELECT * FROM organization;

CREATE TABLE service_project (
    service_project_id SERIAL PRIMARY KEY,
    project_date DATE NOT NULL,
    project_title VARCHAR(200) NOT NULL,
    organization_id INTEGER NOT NULL REFERENCES organization (organization_id)
);

INSERT INTO service_project (project_date, project_title, organization_id)
SELECT project.project_date, project.project_title, organization.organization_id
FROM (
    VALUES
        ('2027-03-06'::DATE, 'Park Trail Restoration', 'BrightFuture Builders'),
        ('2027-03-20'::DATE, 'Community Playground Repairs', 'BrightFuture Builders'),
        ('2027-04-03'::DATE, 'Neighborhood Accessibility Improvements', 'BrightFuture Builders'),
        ('2027-04-17'::DATE, 'Community Garden Path Construction', 'BrightFuture Builders'),
        ('2027-05-01'::DATE, 'Riverwalk Clean-Up and Repair', 'BrightFuture Builders'),
        ('2027-03-07'::DATE, 'Community Seedling Giveaway', 'GreenHarvest Growers'),
        ('2027-03-21'::DATE, 'School Garden Planting Day', 'GreenHarvest Growers'),
        ('2027-04-04'::DATE, 'Neighborhood Compost Workshop', 'GreenHarvest Growers'),
        ('2027-04-18'::DATE, 'Urban Orchard Care Day', 'GreenHarvest Growers'),
        ('2027-05-02'::DATE, 'Community Harvest Festival', 'GreenHarvest Growers'),
        ('2027-03-13'::DATE, 'Food Bank Volunteer Day', 'UnityServe Volunteers'),
        ('2027-03-27'::DATE, 'Senior Center Technology Help', 'UnityServe Volunteers'),
        ('2027-04-10'::DATE, 'Community Clothing Drive', 'UnityServe Volunteers'),
        ('2027-04-24'::DATE, 'Youth Mentoring Kickoff', 'UnityServe Volunteers'),
        ('2027-05-08'::DATE, 'Neighborhood Resource Fair', 'UnityServe Volunteers')
) AS project (project_date, project_title, organization_name)
JOIN organization ON organization.name = project.organization_name;

SELECT service_project_id, project_date, project_title, organization_id
FROM service_project
ORDER BY project_date, service_project_id;