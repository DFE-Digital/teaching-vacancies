class SampleJobApplication
  class << self
    def sample_job_application # rubocop: disable Metrics/MethodLength
      JobApplication.new(
        first_name: "Jane",
        last_name: "Smith",
        previous_names: "Churchill",
        street_address: "1 House Street",
        city: "Townington",
        postcode: "AB1 2CD",
        country: "England",
        phone_number: "07123456789",
        teacher_reference_number: "1234567",
        qualified_teacher_status: "yes",
        qualified_teacher_status_year: "2021",
        email_address: "jane.smith@gmail.com",
        support_needed: "yes",
        support_needed_details: "I require a wheelchair accessible room for an interview",
        close_relationships: "yes",
        close_relationships_details: "Brother-in-law works at the trust",
        personal_statement:
          "As an English teacher, I am extremely passionate about instilling a love of reading and the written word into young people. I have been interested in a position at your school for a number of years and was thrilled to see this opportunity. I received my QTS in 2019, and have since worked as an English teacher in a secondary school in Sheffield.<br />
    In the classroom, I always strive to modify my approach to suit a range of abilities and motivation. By planning lessons around my students’ interests, I have been able to inspire even the most unmotivated readers into a love of books. For example, teaching descriptive writing by looking at their favourite sports and persuasive writing via marketing materials for their favourite shops. Furthermore, I have worked with dozens of students for whom English is their second language and nothing motivates me more than seeing that lightbulb moment happen when they can see their own progress. Last year, 95% of my GCSE students passed with grade 5 or above, and I have a proven track record for ensuring all of my KS3 students improve by at least two grades over years 7 to 9.<br />
    Moreover, I believe that good teaching doesn’t just happen in the classroom. I am a strong advocate for student wellbeing and pastoral support and have greatly enjoyed leading a morning form class for the last three years. Also, in my current school I have contributed to the English department by running a weekly book club, and organising several school trips to literary locations such as Haworth and Stratford Upon Avon, as well as visits to see plays on the curriculum.<br />
    I really resonate with your school’s ethos around inclusion and leaving no student behind, and I hope to be an asset to your English department, while continuing to grow as a teacher.",
        employment_history_section_completed: true,
        employments:
          [
            Employment.new(
              organisation: "Townington Secondary School",
              job_title: "KS3 Teaching Assistant",
              main_duties: "Pastoral support for students. Managing student behaviour. Monitored students’ progress and gave feedback to teachers.",
              reason_for_leaving: "Moving out of the area",
              subjects: Faker::Educator.subject,
              started_on: Faker::Date.in_date_period(year: 2016),
              current_role: "no",
              ended_on: Faker::Date.in_date_period(year: 2018),
            ),
            Employment.new(
              organisation: "Sheffield Secondary School",
              job_title: "English Teacher",
              main_duties: "Planning and delivering English Literature and Language lessons ro a range of abilities across KS3 and GCSE to prepare them for exams. Contributing to the English department via extra curricular activities, organising trips, and running a reading club.",
              reason_for_leaving: "No opportunities for career advancement",
              subjects: Faker::Educator.subject,
              started_on: Faker::Date.in_date_period(year: 2016),
              current_role: "no",
              ended_on: Faker::Date.in_date_period(year: 2018),
            ),
          ],
        references:
          [
            Reference.new(name: "Laura Davison", organisation: "Townington Secondary School", relationship: "Line manager", email: "l.davison@english.townington.ac.uk"),
            Reference.new(name: "John Thompson", organisation: "Sheffield Secondary School", relationship: "Line manager", email: "john.thompson@english.sheffield.ac.uk"),
          ],
        qualifications:
          [
            Qualification.new(category: 4, year: 2016, subject: "BA English Literature", grade: "2.1"),
            Qualification.new(category: 6, year: 2019, subject: "PGCE English with QTS"),
            Qualification.new(category: 2, year: 2012, qualification_results: [
              QualificationResult.new(subject: "English Literature", grade: "A"),
              QualificationResult.new(subject: "History", grade: "B"),
              QualificationResult.new(subject: "French", grade: "A"),
            ]),
            Qualification.new(category: 0, year: 2010, qualification_results: [
              QualificationResult.new(subject: "Maths", grade: "A"),
              QualificationResult.new(subject: "English Literature", grade: "A"),
              QualificationResult.new(subject: "English Language", grade: "B"),
              QualificationResult.new(subject: "History", grade: "C"),
              QualificationResult.new(subject: "French", grade: "A"),
              QualificationResult.new(subject: "Music", grade: "B"),
              QualificationResult.new(subject: "Geography", grade: "C"),
            ]),
          ],
        vacancy: Vacancy.new(job_roles: ["teacher"]),
      )
    end
  end
end
