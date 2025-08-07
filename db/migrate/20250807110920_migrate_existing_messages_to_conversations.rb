class MigrateExistingMessagesToConversations < ActiveRecord::Migration[7.2]
  def up
    # Create conversations for each job application that has messages
    safety_assured do
      execute <<~SQL
        INSERT INTO conversations (id, job_application_id, title, created_at, updated_at)
        SELECT 
          gen_random_uuid(),
          job_application_id,
          'Regarding application: ' || v.job_title,
          NOW(),
          NOW()
        FROM messages m
        JOIN job_applications ja ON m.job_application_id = ja.id
        JOIN vacancies v ON ja.vacancy_id = v.id
        GROUP BY job_application_id, v.job_title;
      SQL
      
      # Update messages to reference conversations
      execute <<~SQL
        UPDATE messages 
        SET conversation_id = c.id
        FROM conversations c
        WHERE messages.job_application_id = c.job_application_id;
      SQL
    end
  end
  
  def down
    # No rollback needed - this is data migration only
  end
end
