## Introduction

Teaching Vacancies uses dynamic landing pages to enhance the user experience by offering tailored job searches based on various criteria such as location, organisation, and specific job roles. 
These landing pages are predefined with unique search filters and localised content, allowing users to find relevant job opportunities quickly and efficiently.

This document outlines how landing pages are structured, how the system retrieves them, and how the search process works in conjunction with these pages. 
It also covers the configuration of landing pages through YAML files and explains how to further customise their behavior to suit specific needs.

1. **Routes**  
   Dynamic routes are defined for different types of landing pages:
    - Location-based (`teaching-jobs-in-:location_landing_page_name`)
    - General landing pages (`:landing_page_slug`)
    - Organisation-based landing pages (`/organisations/:organisation_landing_page_name`)  
      These routes map to the `VacanciesController#index` action but are constrained to only match if a corresponding landing page exists.

2. **VacanciesController#index**
    - **Set the landing page:** The `set_landing_page` method is called before the `index` action. It determines if the request matches a landing page by checking the `params[:landing_page_slug]`, `params[:organisation_landing_page_name]`, or `params[:location_landing_page_name]`. Depending on the parameter, it fetches the corresponding landing page from one of the models (`LandingPage`, `OrganisationLandingPage`, or `LocationLandingPage`).
    - **Perform search:** Once the landing page is determined, the search criteria (filters) are either derived from the landing page or directly from user input via the form object. The search criteria are then passed to a `VacancySearch` object to perform the job search.
    - **Pagination and rendering:** The results are paginated using the `pagy` gem, and the search results (vacancies) are rendered along with metadata (e.g., search coordinates, total count, etc.).

3. **LandingPage Model**
    - **Landing page lookup:** The `LandingPage` class is responsible for determining if a landing page exists (`exists?(slug)`) and retrieving the associated search criteria via `LandingPage[slug]`.
    - **Criteria-based search:** The landing page holds pre-configured search criteria (from the YAML configuration file), which is used to generate the filtered job search.
    - **Caching:** The total count of jobs matching the landing page's criteria is cached to optimise performance (`count` method).
    - **I18n for content:** The landing page also uses internationalisation (I18n) for generating the page's title, heading, and meta description, interpolating the total job count into the strings.

4. **YAML Configuration (`config/landing_pages.yml`)**
    - **Static configuration:** The YAML file defines static landing pages by their slug (e.g., `sendco-jobs`, `teacher-jobs`). Each landing page is associated with predefined search criteria (e.g., job roles, subjects, working patterns) that will be used for filtering job listings.
    - **Translation integration:** For each landing page, you also have translation keys in `config/locales/landing_pages.yml` that provide the localised content for the page title, heading, and meta description.  
      The configuration also includes placeholders like `%{count}` to display the total number of jobs for a given landing page.

5. **Localised Content**  
   The landing page titles, headings, and meta descriptions are all localised and customisable through the `config/locales/landing_pages.yml` file. Each landing page has its specific content defined under its slug, making the pages flexible and customisable per landing page.  
   For example, the title for the `assistant-headteacher-jobs` landing page is "Assistant Headteacher Jobs", while the heading dynamically interpolates the job count (e.g., "45 assistant headteacher jobs").

6. **Flow of Landing Page Generation**
    - **Routing:** The request hits the appropriate route (e.g., `:landing_page_slug`).
    - **Landing Page Retrieval:** The `set_landing_page` method in the `VacanciesController` retrieves the landing page from the `LandingPage` model based on the slug in the URL.
    - **Search Criteria:** The landing page's search criteria (from YAML) are passed to the `VacancySearch` class, which performs a job search.
    - **Pagination & Rendering:** The search results are paginated, and the page is rendered using localised content (title, heading, meta description) for that specific landing page.
