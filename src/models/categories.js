import db from './db.js';

const getAllCategories = async () => {
    const query = `
        SELECT category_id, name, description
        FROM public.project_categories
        ORDER BY name;
    `;

    const result = await db.query(query);

    return result.rows;
};

export { getAllCategories };
