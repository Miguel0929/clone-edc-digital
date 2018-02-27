class CreateTriggerUserTracker < ActiveRecord::Migration
  def up
    execute 'CREATE OR REPLACE FUNCTION user_tracker() RETURNS trigger AS
      $$
      BEGIN
           INSERT INTO user_trackers("old_group", "user_id", "action", "created_at", "updated_at")
           VALUES(NEW.group_id,NEW.id,\'INSERT\',now(),now());
   
        RETURN NEW;
      END;
      $$
      LANGUAGE "plpgsql";'

    execute "CREATE TRIGGER user_create_trigger
        AFTER INSERT
        ON users
        FOR EACH ROW
        EXECUTE PROCEDURE user_tracker();" 

    execute 'CREATE OR REPLACE FUNCTION user_tracker_update() RETURNS trigger AS
      $$
      BEGIN
        CASE 
          WHEN OLD.group_id != NEW.group_id THEN
            INSERT INTO user_trackers("old_group", "user_id", "action", "created_at", "updated_at")
            VALUES(OLD.group_id,NEW.id,\'UPDATE\',now(),now());
          ELSE  
        END CASE;
        RETURN NEW;
      END;
      $$
      LANGUAGE "plpgsql";'

    execute "CREATE TRIGGER user_update_trigger
        AFTER UPDATE
        ON users
        FOR EACH ROW
        EXECUTE PROCEDURE user_tracker_update();"   


  end
 
  def down
    execute "DROP TRIGGER user_create_trigger ON users;"
    execute "DROP FUNCTION IF EXISTS user_tracker();"
    
    execute "DROP TRIGGER user_update_trigger ON users;"
    execute "DROP FUNCTION IF EXISTS user_tracker_update();"
  end
end
