import db from './db.js';

const getAllProjects = async () => {
    const query = `
        SELECT projects.project_id,
               projects.date,
               projects.location,
               projects.project_title,
               organization.name AS organization_name
        FROM public.projects
        JOIN public.organization
          ON projects.organization_id = organization.organization_id
        ORDER BY projects.date, projects.project_id;
    `;

    const result = await db.query(query);

    return result.rows;
};

export { getAllProjects };
